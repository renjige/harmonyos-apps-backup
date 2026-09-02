import { http } from '@kit.NetworkKit'
import {
  ApiResponse,
  EmptyPayload,
  LoginRequest,
  LoginResponse,
  RegisterRequest
} from '../models/ApiModels'
import { ApiConfig } from '../config/ApiConfig'

/**
 * HTTPS client. Network or API failures return an error response; business pages render empty states.
 * 认证：encodeBody + Object header（禁止 Map，否则 X-Tenant-Id 丢失 → 401）。
 */
export class HttpClient {
  static getBaseUrl(): string {
    const v = AppStorage.get<string>('apiBaseUrl')
    return v && v.length > 0 ? v : ApiConfig.baseUrl()
  }

  static getToken(): string {
    return AppStorage.get<string>('accessToken') ?? ''
  }

  static tenantId(): string {
    return AppStorage.get<string>('tenantId') ?? ApiConfig.TENANT_ID
  }

  static async request<T>(method: string, path: string, body?: object): Promise<ApiResponse<T>> {
    const base = HttpClient.getBaseUrl()
    if (!base.startsWith('https://')) {
      return HttpClient.fail<T>(new EmptyPayload() as T, '仅支持 HTTPS')
    }
    const url = `${base}${path}`
    const token = HttpClient.getToken()
    const options = new HttpRequestOptions()
    options.header = HttpClient.buildHeaderObject(HttpClient.tenantId(), token)

    try {
      const client = http.createHttp()
      let reqMethod: http.RequestMethod = http.RequestMethod.POST
      if (method === 'GET') {
        reqMethod = http.RequestMethod.GET
      } else if (method === 'PUT') {
        reqMethod = http.RequestMethod.PUT
      } else if (method === 'DELETE') {
        reqMethod = http.RequestMethod.DELETE
      }
      options.method = reqMethod
      const payload = HttpClient.encodeBody(body)
      if (payload.length > 0) {
        options.extraData = payload
      }
      const res = await client.request(url, options.toRequestConfig())
      client.destroy()
      if (res.responseCode >= 200 && res.responseCode < 300) {
        if (path === '/auth/login' || path === '/auth/register') {
          return HttpClient.parseAuthResponse<T>(res.result as string)
        }
        return HttpClient.parseResponse<T>(res.result as string)
      }
      return HttpClient.failFromHttpError<T>(res.responseCode, res.result as string)
    } catch {
      return HttpClient.fail<T>(new EmptyPayload() as T, '网络不可用，请稍后重试')
    }
  }

  /** NetworkKit：header 必须是 Object，不能传 Map。用 JSON.parse 避免匿名字面量报错。 */
  private static buildHeaderObject(tenantId: string, token: string): Object {
    if (token.length > 0) {
      const auth = `Bearer ${token}`
      return JSON.parse(
        `{"Content-Type":"application/json","X-Tenant-Id":${JSON.stringify(tenantId)},"Authorization":${JSON.stringify(auth)}}`
      ) as Object
    }
    return JSON.parse(
      `{"Content-Type":"application/json","X-Tenant-Id":${JSON.stringify(tenantId)}}`
    ) as Object
  }

  private static failFromHttpError<T>(status: number, raw: string): ApiResponse<T> {
    let message = `HTTP ${status}`
    try {
      const err = JSON.parse(raw) as NestHttpError
      if (err.message !== undefined && err.message !== null && err.message.length > 0) {
        message = err.message
      }
    } catch {
      // keep
    }
    return HttpClient.fail<T>(new EmptyPayload() as T, message)
  }

  private static encodeBody(body?: object): string {
    if (body === undefined) {
      return ''
    }
    if (body instanceof RegisterRequest) {
      return body.toJsonString()
    }
    if (body instanceof LoginRequest) {
      return body.toJsonString()
    }
    return JSON.stringify(body)
  }

  private static parseResponse<T>(raw: string): ApiResponse<T> {
    const parsed = JSON.parse(raw) as ApiResponse<T>
    return parsed
  }

  private static parseAuthResponse<T>(raw: string): ApiResponse<T> {
    const res = new ApiResponse<LoginResponse>()
    try {
      const root = JSON.parse(raw) as AuthWireRoot
      res.code = root.code
      if (root.message !== undefined && root.message !== null) {
        res.message = root.message
      } else {
        res.message = ''
      }
      const data = new LoginResponse()
      if (root.data !== undefined && root.data !== null) {
        const token = root.data.accessToken
        if (token !== undefined && token !== null) {
          data.accessToken = token
        }
      }
      res.data = data
    } catch {
      res.code = 50001
      res.message = '响应解析失败'
      res.data = new LoginResponse()
    }
    return HttpClient.wrapLogin<T>(res)
  }

  private static fail<T>(data: T, message: string): ApiResponse<T> {
    const res = new ApiResponse<T>()
    res.code = 50001
    res.message = message
    res.data = data
    return res
  }

  private static wrapLogin<T>(source: ApiResponse<LoginResponse>): ApiResponse<T> {
    const res = new ApiResponse<T>()
    res.code = source.code
    res.message = source.message
    res.data = source.data as T
    return res
  }

  static get<T>(path: string): Promise<ApiResponse<T>> {
    return HttpClient.request<T>('GET', path)
  }

  static post<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return HttpClient.request<T>('POST', path, body)
  }

  static put<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return HttpClient.request<T>('PUT', path, body)
  }

  static patch<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return HttpClient.request<T>('PUT', path, body)
  }

  static delete<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return HttpClient.request<T>('DELETE', path, body)
  }
}

class EmptyHeaderObject {
}

class NestHttpError {
  message: string = ''
  statusCode: number = 0
}

class AuthWireData {
  accessToken: string = ''
}

class AuthWireRoot {
  code: number = 50001
  message: string = ''
  data: AuthWireData | null | undefined = undefined
}

class HttpRequestOptions {
  method: http.RequestMethod = http.RequestMethod.GET
  header: Object = new EmptyHeaderObject()
  extraData: string = ''
  expectDataType: http.HttpDataType = http.HttpDataType.STRING
  connectTimeout: number = 15000
  readTimeout: number = 15000

  toRequestConfig(): http.HttpRequestOptions {
    const config = new HttpRequestConfig()
    config.method = this.method
    config.header = this.header
    config.extraData = this.extraData.length > 0 ? this.extraData : undefined
    config.expectDataType = this.expectDataType
    config.connectTimeout = this.connectTimeout
    config.readTimeout = this.readTimeout
    return config
  }
}

class HttpRequestConfig implements http.HttpRequestOptions {
  method: http.RequestMethod = http.RequestMethod.GET
  header: Object = new EmptyHeaderObject()
  extraData?: string
  expectDataType: http.HttpDataType = http.HttpDataType.STRING
  connectTimeout: number = 15000
  readTimeout: number = 15000
}
