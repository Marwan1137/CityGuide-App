import { errorResponse } from "./http.ts";

export const requireBearerToken = (request: Request): Response | null => {
  const authorization = request.headers.get("authorization") ?? "";
  return authorization.startsWith("Bearer ")
    ? null
    : errorResponse("unauthorized", "Authentication is required.", 401);
};
