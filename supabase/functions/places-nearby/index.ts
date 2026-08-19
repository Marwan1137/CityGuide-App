import { createClient } from "npm:@supabase/supabase-js@2.95.0";
import { requireBearerToken } from "../_shared/auth.ts";
import {
  errorResponse,
  jsonResponse,
  requireMethod,
} from "../_shared/http.ts";

type NearbyRequest = {
  latitude: number;
  longitude: number;
  category: "cafe" | "restaurant" | "pharmacy";
  radiusMeters: number;
  maxResults: number;
};

type GooglePlace = {
  id?: string;
  displayName?: { text?: string };
  formattedAddress?: string;
  location?: { latitude?: number; longitude?: number };
  rating?: number;
};

type GoogleNearbyResponse = {
  places?: GooglePlace[];
};

type RateWindow = { startedAt: number; count: number };

const rateWindows = new Map<string, RateWindow>();
const rateLimit = 30;
const rateWindowMs = 60_000;
const providerTimeoutMs = 8_000;
const allowedCategories = new Set(["cafe", "restaurant", "pharmacy"]);

Deno.serve(async (request: Request): Promise<Response> => {
  const methodError = requireMethod(request, "POST");
  if (methodError) return methodError;

  const authError = requireBearerToken(request);
  if (authError) return authError;

  const authResult = await authenticateUser(request);
  if (authResult instanceof Response) return authResult;

  if (!consumeRateLimit(authResult.id)) {
    return errorResponse(
      "rate_limited",
      "Nearby search is busy. Please wait a moment and try again.",
      429,
    );
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return errorResponse("invalid_json", "A JSON body is required.", 400);
  }

  const nearbyRequest = parseNearbyRequest(body);
  if (nearbyRequest instanceof Response) return nearbyRequest;

  const apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY");
  if (!apiKey) {
    console.error("places-nearby configuration_missing");
    return errorResponse(
      "configuration_missing",
      "Nearby search is temporarily unavailable.",
      503,
    );
  }

  let providerResponse: Response;
  try {
    providerResponse = await fetch(
      "https://places.googleapis.com/v1/places:searchNearby",
      {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "X-Goog-Api-Key": apiKey,
          "X-Goog-FieldMask": [
            "places.id",
            "places.displayName",
            "places.formattedAddress",
            "places.location",
            "places.rating",
          ].join(","),
        },
        body: JSON.stringify({
          includedTypes: [nearbyRequest.category],
          maxResultCount: nearbyRequest.maxResults,
          rankPreference: "POPULARITY",
          languageCode: "en",
          regionCode: "EG",
          locationRestriction: {
            circle: {
              center: {
                latitude: nearbyRequest.latitude,
                longitude: nearbyRequest.longitude,
              },
              radius: nearbyRequest.radiusMeters,
            },
          },
        }),
        signal: AbortSignal.timeout(providerTimeoutMs),
      },
    );
  } catch (error) {
    const timedOut = error instanceof DOMException &&
      error.name === "TimeoutError";
    console.error(`places-nearby provider_failure timeout=${timedOut}`);
    return errorResponse(
      timedOut ? "provider_timeout" : "provider_unavailable",
      timedOut
        ? "Nearby search took too long."
        : "Nearby search is temporarily unavailable.",
      timedOut ? 504 : 502,
    );
  }

  if (!providerResponse.ok) {
    console.error(
      `places-nearby provider_http_error status=${providerResponse.status}`,
    );
    if (providerResponse.status === 429) {
      return errorResponse(
        "places_quota_exceeded",
        "Nearby search is busy. Please try again later.",
        429,
      );
    }
    return errorResponse(
      "provider_unavailable",
      "Nearby search is temporarily unavailable.",
      502,
    );
  }

  let provider: GoogleNearbyResponse;
  try {
    provider = await providerResponse.json() as GoogleNearbyResponse;
  } catch {
    return errorResponse(
      "provider_invalid_response",
      "Nearby search is temporarily unavailable.",
      502,
    );
  }

  const places = (provider.places ?? []).flatMap((place) => {
    const latitude = place.location?.latitude;
    const longitude = place.location?.longitude;
    const name = place.displayName?.text?.trim();
    if (!place.id ||
      !name ||
      typeof latitude !== "number" ||
      typeof longitude !== "number") {
      return [];
    }
    return [{
      id: place.id,
      name,
      category: nearbyRequest.category,
      latitude,
      longitude,
      address: place.formattedAddress?.trim() || null,
      rating: typeof place.rating === "number" ? place.rating : null,
      photo_url: null,
      distance_meters: distanceMeters(
        nearbyRequest.latitude,
        nearbyRequest.longitude,
        latitude,
        longitude,
      ),
    }];
  });

  console.info(
    `places-nearby success category=${nearbyRequest.category} radius=${nearbyRequest.radiusMeters} count=${places.length}`,
  );
  return jsonResponse({ data: { places } });
});

const authenticateUser = async (
  request: Request,
): Promise<{ id: string } | Response> => {
  const authorization = request.headers.get("authorization") ?? "";
  const token = authorization.slice("Bearer ".length);
  const publishableKeysValue = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  if (!publishableKeysValue || !supabaseUrl) {
    console.error("places-nearby auth_configuration_missing");
    return errorResponse(
      "configuration_missing",
      "Nearby search is temporarily unavailable.",
      503,
    );
  }

  let publishableKey: string;
  try {
    const publishableKeys = JSON.parse(publishableKeysValue) as Record<
      string,
      string
    >;
    publishableKey = publishableKeys.default;
  } catch {
    return errorResponse(
      "configuration_missing",
      "Nearby search is temporarily unavailable.",
      503,
    );
  }

  if (!publishableKey) {
    return errorResponse(
      "configuration_missing",
      "Nearby search is temporarily unavailable.",
      503,
    );
  }

  const supabase = createClient(supabaseUrl, publishableKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data.user) {
    return errorResponse(
      "unauthorized",
      "A valid CityGuide session is required.",
      401,
    );
  }
  return { id: data.user.id };
};

const parseNearbyRequest = (body: unknown): NearbyRequest | Response => {
  if (typeof body !== "object" || body === null) {
    return errorResponse("invalid_request", "Invalid nearby request.", 400);
  }
  const value = body as Record<string, unknown>;
  const latitude = value.latitude;
  const longitude = value.longitude;
  const category = value.category;
  const radiusMeters = value.radius_meters;
  const maxResults = value.max_results;

  if (typeof latitude !== "number" ||
    !Number.isFinite(latitude) ||
    latitude < -90 ||
    latitude > 90 ||
    typeof longitude !== "number" ||
    !Number.isFinite(longitude) ||
    longitude < -180 ||
    longitude > 180) {
    return errorResponse(
      "invalid_coordinates",
      "Valid latitude and longitude are required.",
      400,
    );
  }
  if (typeof category !== "string" || !allowedCategories.has(category)) {
    return errorResponse(
      "invalid_category",
      "Category must be cafe, restaurant, or pharmacy.",
      400,
    );
  }
  if (typeof radiusMeters !== "number" ||
    !Number.isInteger(radiusMeters) ||
    radiusMeters < 100 ||
    radiusMeters > 10000) {
    return errorResponse(
      "invalid_radius",
      "Radius must be between 100 and 10000 meters.",
      400,
    );
  }
  if (typeof maxResults !== "number" ||
    !Number.isInteger(maxResults) ||
    maxResults < 1 ||
    maxResults > 20) {
    return errorResponse(
      "invalid_result_count",
      "Result count must be between 1 and 20.",
      400,
    );
  }

  return {
    latitude,
    longitude,
    category: category as NearbyRequest["category"],
    radiusMeters,
    maxResults,
  };
};

const consumeRateLimit = (userId: string): boolean => {
  const now = Date.now();
  const current = rateWindows.get(userId);
  if (!current || now - current.startedAt >= rateWindowMs) {
    rateWindows.set(userId, { startedAt: now, count: 1 });
    return true;
  }
  if (current.count >= rateLimit) return false;
  current.count += 1;
  return true;
};

const distanceMeters = (
  fromLatitude: number,
  fromLongitude: number,
  toLatitude: number,
  toLongitude: number,
): number => {
  const earthRadiusMeters = 6_371_000;
  const toRadians = (degrees: number) => degrees * Math.PI / 180;
  const latitudeDelta = toRadians(toLatitude - fromLatitude);
  const longitudeDelta = toRadians(toLongitude - fromLongitude);
  const a = Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(toRadians(fromLatitude)) *
      Math.cos(toRadians(toLatitude)) *
      Math.sin(longitudeDelta / 2) ** 2;
  return Math.round(
    earthRadiusMeters * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)),
  );
};
