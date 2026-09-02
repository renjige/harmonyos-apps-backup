import { ApiResponse, EmptyPayload } from '../models/ApiModels'

/** 跃动新章为纯本地 App，不引用 NetworkKit */
export class HttpClient {
  static lastError: string = '本应用无需联网'

  static async get<T>(path: string): Promise<ApiResponse<T>> {
    return HttpClient.fail<T>(new EmptyPayload() as T, HttpClient.lastError)
  }

  static async post<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return HttpClient.fail<T>(new EmptyPayload() as T, HttpClient.lastError)
  }

  static async put<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return HttpClient.fail<T>(new EmptyPayload() as T, HttpClient.lastError)
  }

  static async patch<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return HttpClient.fail<T>(new EmptyPayload() as T, HttpClient.lastError)
  }

  static async delete<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return HttpClient.fail<T>(new EmptyPayload() as T, HttpClient.lastError)
  }

  private static fail<T>(data: T, message: string): ApiResponse<T> {
    const res = new ApiResponse<T>()
    res.code = -1
    res.message = message
    res.data = data
    HttpClient.lastError = message
    return res
  }
}
