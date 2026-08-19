import { createClient } from "npm:@supabase/supabase-js@2.95.0";
import { requireBearerToken } from "../_shared/auth.ts";
import {
  errorResponse,
  jsonResponse,
  requireMethod,
} from "../_shared/http.ts";

type GeocodingResult = {
  place_id: string;
  formatted_address: string;
  address_components: Array<{
    long_name: string;
    types: string[];
  }>;
  geometry: {
    location: { lat: number; lng: number };
  };
};

type GeocodingResponse = {
  status: string;
  results: GeocodingResult[];
};

const egyptBounds = {
  minLatitude: 21.7,
  maxLatitude: 31.8,
  minLongitude: 24.7,
  maxLongitude: 36.9,
};

Deno.serve(async (request: Request): Promise<Response> => {
  const methodError = requireMethod(request, "POST");
  if (methodError) return methodError;

  const authError = requireBearerToken(request);
  if (authError) return authError;

  const authorization = request.headers.get("authorization") ?? "";
  const token = authorization.slice("Bearer ".length);
  const publishableKeysValue = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  if (!publishableKeysValue || !supabaseUrl) {
    console.error("geocode-city auth_configuration_missing");
    return errorResponse(
      "configuration_missing",
      "City search is temporarily unavailable.",
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
      "City search is temporarily unavailable.",
      503,
    );
  }

  if (!publishableKey) {
    return errorResponse(
      "configuration_missing",
      "City search is temporarily unavailable.",
      503,
    );
  }

  const supabase = createClient(supabaseUrl, publishableKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: authData, error: userError } = await supabase.auth.getUser(
    token,
  );
  if (userError || !authData.user) {
    return errorResponse(
      "unauthorized",
      "A valid CityGuide session is required.",
      401,
    );
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return errorResponse("invalid_json", "A JSON body is required.", 400);
  }

  const query = typeof body === "object" && body !== null &&
      "query" in body && typeof body.query === "string"
    ? body.query.trim()
    : "";

  if (query.length < 2 || query.length > 80) {
    return errorResponse(
      "invalid_city_query",
      "City query must contain between 2 and 80 characters.",
      400,
    );
  }

  const apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY");
  if (!apiKey) {
    console.error("geocode-city configuration_missing");
    return errorResponse(
      "configuration_missing",
      "City search is temporarily unavailable.",
      503,
    );
  }

  const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
  url.searchParams.set("address", `${query}, Egypt`);
  url.searchParams.set("components", "country:EG");
  url.searchParams.set("region", "eg");
  url.searchParams.set("language", "en");
  url.searchParams.set("key", apiKey);

  let providerResponse: Response;
  try {
    providerResponse = await fetch(url, {
      signal: AbortSignal.timeout(8_000),
    });
  } catch (error) {
    const isTimeout = error instanceof DOMException &&
      error.name === "TimeoutError";
    console.error(
      `geocode-city provider_failure timeout=${isTimeout} query_length=${query.length}`,
    );
    return errorResponse(
      isTimeout ? "provider_timeout" : "provider_unavailable",
      isTimeout
        ? "City search took too long."
        : "City search is temporarily unavailable.",
      isTimeout ? 504 : 502,
    );
  }

  if (!providerResponse.ok) {
    console.error(
      `geocode-city provider_http_error status=${providerResponse.status} query_length=${query.length}`,
    );
    return errorResponse(
      "provider_unavailable",
      "City search is temporarily unavailable.",
      502,
    );
  }

  const provider = await providerResponse.json() as GeocodingResponse;
  if (provider.status === "OVER_QUERY_LIMIT") {
    return errorResponse(
      "geocoding_quota_exceeded",
      "City search is busy right now.",
      429,
    );
  }
  if (provider.status === "ZERO_RESULTS" || provider.results.length === 0) {
    return errorResponse(
      "city_not_found",
      "No matching city was found inside Egypt.",
      404,
    );
  }
  if (provider.status !== "OK") {
    console.error(
      `geocode-city provider_status status=${provider.status} query_length=${query.length}`,
    );
    return errorResponse(
      "provider_rejected_request",
      "City search is temporarily unavailable.",
      502,
    );
  }

  const result = provider.results[0];
  const { lat, lng } = result.geometry.location;
  const insideEgypt = lat >= egyptBounds.minLatitude &&
    lat <= egyptBounds.maxLatitude &&
    lng >= egyptBounds.minLongitude &&
    lng <= egyptBounds.maxLongitude;
  if (!insideEgypt) {
    return errorResponse(
      "outside_egypt",
      "The result is outside Egypt.",
      404,
    );
  }

  const name = result.formatted_address.split(",")[0].trim() || query;
  const governorate = result.address_components.find((component) =>
    component.types.includes("administrative_area_level_1")
  )?.long_name ?? "";
  const containsArabic = /[\u0600-\u06FF]/.test(query);

  console.info(`geocode-city success query_length=${query.length}`);
  return jsonResponse({
    data: {
      id: `google:${result.place_id}`,
      name_en: name,
      name_ar: containsArabic ? query : "",
      governorate_en: governorate,
      governorate_ar: "",
      latitude: lat,
      longitude: lng,
      aliases: [],
      is_remote_result: true,
    },
  });
});
