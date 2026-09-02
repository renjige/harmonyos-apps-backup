export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  requestId: string;
}

export function ok<T>(data: T, requestId = ''): ApiResponse<T> {
  return { code: 0, message: 'ok', data, requestId: requestId || cryptoRandom() };
}

export function fail(code: number, message: string, requestId = ''): ApiResponse<null> {
  return { code, message, data: null, requestId: requestId || cryptoRandom() };
}

function cryptoRandom(): string {
  return `req_${Date.now()}_${Math.random().toString(16).slice(2)}`;
}

export const ErrorCode = {
  BAD_REQUEST: 40001,
  UNAUTHORIZED: 40101,
  FORBIDDEN: 40301,
  NOT_FOUND: 40401,
  CONFLICT: 40901,
  RATE_LIMIT: 42901,
  INTERNAL: 50001,
  AI_UPSTREAM: 50021,
} as const;
