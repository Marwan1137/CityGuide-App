export const jsonResponse = (body: unknown, status = 200): Response =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
    },
  });

export const errorResponse = (
  code: string,
  message: string,
  status: number,
): Response => jsonResponse({ error: { code, message } }, status);

export const requireMethod = (request: Request, method: string): Response | null =>
  request.method === method
    ? null
    : errorResponse("method_not_allowed", "Method not allowed.", 405);
