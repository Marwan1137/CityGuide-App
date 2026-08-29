import { createClient } from "npm:@supabase/supabase-js@2.95.0";
import { requireBearerToken } from "../_shared/auth.ts";
import {
  errorResponse,
  jsonResponse,
  requireMethod,
} from "../_shared/http.ts";

type DetailsRequest = {
  placeId: string;
};

type GooglePhoto = {
  name?: string;
  authorAttributions?: { displayName?: string }[];
};

type GoogleOpeningHours = {
  openNow?: boolean;
  weekdayDescriptions?: string[];
  nextCloseTime?: string;
};

type GooglePlaceDetails = {
  id?: string;
  displayName?: { text?: string };
  formattedAddress?: string;
  rating?: number;
  priceLevel?: string;
  currentOpeningHours?: GoogleOpeningHours;
  photos?: GooglePhoto[];
};

type RateWindow = { startedAt: number; count: number };

const rateWindows = new Map<string, RateWindow>();
const rateLimit = 30;
const rateWindowMs = 60_000;
const providerTimeoutMs = 8_000;
const maxPhotos = 5;

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
      "Place details is busy. Please wait a moment and try again.",
      429,
    );
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return errorResponse("invalid_json", "A JSON body is required.", 400);
  }

  const detailsRequest = parseDetailsRequest(body);
  if (detailsRequest instanceof Response) return detailsRequest;

  const apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY");
  if (!apiKey) {
    console.error("places-details configuration_missing");
    return errorResponse(
      "configuration_missing",
      "Place details is temporarily unavailable.",
      503,
    );
  }

  let providerResponse: Response;
  try {
    providerResponse = await fetch(
      `https://places.googleapis.com/v1/places/${detailsRequest.placeId}`,
      {
        method: "GET",
        headers: {
          "X-Goog-Api-Key": apiKey,
          "X-Goog-FieldMask": [
            "id",
            "displayName",
            "formattedAddress",
            "rating",
            "priceLevel",
            "currentOpeningHours",
            "photos",
          ].join(","),
        },
        signal: AbortSignal.timeout(providerTimeoutMs),
      },
    );
  } catch (error) {
    const timedOut = error instanceof DOMException &&
      error.name === "TimeoutError";
    console.error(`places-details provider_failure timeout=${timedOut}`);
    return errorResponse(
      timedOut ? "provider_timeout" : "provider_unavailable",
      timedOut
        ? "Place details took too long."
        : "Place details is temporarily unavailable.",
      timedOut ? 504 : 502,
    );
  }

  if (!providerResponse.ok) {
    console.error(
      `places-details provider_http_error status=${providerResponse.status}`,
    );
    if (providerResponse.status === 429) {
      return errorResponse(
        "places_quota_exceeded",
        "Place details is busy. Please try again later.",
        429,
      );
    }
    return errorResponse(
      "provider_unavailable",
      "Place details is temporarily unavailable.",
      502,
    );
  }

  let provider: GooglePlaceDetails;
  try {
    provider = await providerResponse.json() as GooglePlaceDetails;
  } catch {
    return errorResponse(
      "provider_invalid_response",
      "Place details is temporarily unavailable.",
      502,
    );
  }

  const photos = await resolvePhotos(
    provider.photos ?? [],
    apiKey,
  );

  console.info(`places-details success place_id=${detailsRequest.placeId}`);
  return jsonResponse({
    data: {
      id: provider.id ?? detailsRequest.placeId,
      name: provider.displayName?.text?.trim() ?? null,
      address: provider.formattedAddress?.trim() ?? null,
      rating: typeof provider.rating === "number" ? provider.rating : null,
      price_level: provider.priceLevel ?? null,
      open_now: provider.currentOpeningHours?.openNow ?? null,
       weekly_hours: provider.currentOpeningHours?.weekdayDescriptions ?? [],
       next_close_time: provider.currentOpeningHours?.nextCloseTime ?? null,
      photos,
    },
  });
});

const resolvePhotos = async (
  photos: GooglePhoto[],
  apiKey: string,
): Promise<{ url: string; attribution: string | null }[]> => {
  const selected = photos.slice(0, maxPhotos).filter((photo) => photo.name);
  const resolved = await Promise.all(selected.map(async (photo) => {
    try {
      const response = await fetch(
        `https://places.googleapis.com/v1/${photo.name}/media` +
          "?maxHeightPx=800&skipHttpRedirect=true",
        {
          headers: { "X-Goog-Api-Key": apiKey },
          signal: AbortSignal.timeout(providerTimeoutMs),
        },
      );
      if (!response.ok) return null;
      const json = await response.json() as { photoUri?: string };
      if (!json.photoUri) return null;
      return {
        url: json.photoUri,
        attribution: photo.authorAttributions?.[0]?.displayName ?? null,
      };
    } catch {
      return null;
    }
  }));
  return resolved.filter((photo) => photo !== null);
};

const authenticateUser = async (
  request: Request,
): Promise<{ id: string } | Response> => {
  const authorization = request.headers.get("authorization") ?? "";
  const token = authorization.slice("Bearer ".length);
  const publishableKeysValue = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  if (!publishableKeysValue || !supabaseUrl) {
    console.error("places-details auth_configuration_missing");
    return errorResponse(
      "configuration_missing",
      "Place details is temporarily unavailable.",
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
      "Place details is temporarily unavailable.",
      503,
    );
  }

  if (!publishableKey) {
    return errorResponse(
      "configuration_missing",
      "Place details is temporarily unavailable.",
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

const parseDetailsRequest = (body: unknown): DetailsRequest | Response => {
  if (typeof body !== "object" || body === null) {
    return errorResponse("invalid_request", "Invalid details request.", 400);
  }
  const value = body as Record<string, unknown>;
  const placeId = value.place_id;
  if (typeof placeId !== "string" || placeId.trim().length === 0) {
    return errorResponse("invalid_place_id", "A place_id is required.", 400);
  }
  return { placeId: placeId.trim() };
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