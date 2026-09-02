import { http } from '@kit.NetworkKit'
import {
  AiAnalyzeResponse,
  AiChatRequest,
  AiChatResponse,
  AiGenerateResponse,
  ApiResponse,
  EmptyPayload,
  LoginRequest,
  LoginResponse,
  RegisterRequest
} from '../models/ApiModels'
import { CreateTaskBody, PatchTaskBody } from '../models/FamilyTaskModels'

/**
 * HTTPS client. Network failure falls back to local mock.
 * 认证：encodeBody + Object header（禁止 Map，否则 X-Tenant-Id 丢失 → 401）。
 */
export class HttpClient {
  static getBaseUrl(): string {
    const v = AppStorage.get<string>('apiBaseUrl')
    return v && v.length > 0 ? v : 'https://api.example.com/api/v1'
  }

  static getToken(): string {
    return AppStorage.get<string>('accessToken') ?? ''
  }

  static tenantId(): string {
    return AppStorage.get<string>('tenantId') ?? ''
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
      return HttpClient.mockResponse<T>(path, body)
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
    if (body instanceof AiChatRequest) {
      return `{"prompt":${JSON.stringify(body.prompt)},"context":${JSON.stringify(body.context)}}`
    }
    if (body instanceof CreateTaskBody) {
      return body.toJsonString()
    }
    if (body instanceof PatchTaskBody) {
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

  private static mockResponse<T>(path: string, body?: object): ApiResponse<T> {
    if ((path === '/auth/login' || path === '/auth/register') &&
      (body instanceof LoginRequest || body instanceof RegisterRequest)) {
      if (path === '/auth/register' && body instanceof RegisterRequest) {
        return HttpClient.wrapLogin<T>(HttpClient.mockRegister(body))
      }
      return HttpClient.wrapLogin<T>(HttpClient.mockLogin(body))
    }
    if (path === '/ai/chat' && body instanceof AiChatRequest) {
      return HttpClient.wrapChat<T>(HttpClient.mockChat(body))
    }
    if (path === '/ai/analyze') {
      return HttpClient.wrapAnalyze<T>(HttpClient.mockAnalyze())
    }
    if (path === '/ai/generate') {
      return HttpClient.wrapGenerate<T>(HttpClient.mockGenerate())
    }
    if (path === '/privacy/delete-data' || path === '/privacy/account') {
      const res = new ApiResponse<T>()
      res.code = 0
      res.message = 'ok'
      res.data = new EmptyPayload() as T
      return res
    }
    return HttpClient.fail<T>(new EmptyPayload() as T, '网络不可用')
  }

  private static mockLogin(body: LoginRequest | RegisterRequest): ApiResponse<LoginResponse> {
    const res = new ApiResponse<LoginResponse>()
    if (body.username.length > 0 && body.password.length > 0) {
      const data = new LoginResponse()
      data.accessToken = `offline_${body.username}`
      res.code = 0
      res.message = 'ok'
      res.data = data
    } else {
      res.code = 50001
      res.message = 'invalid credentials'
      res.data = new LoginResponse()
    }
    return res
  }

  private static mockRegister(body: RegisterRequest): ApiResponse<LoginResponse> {
    const res = new ApiResponse<LoginResponse>()
    if (body.username.length < 3 || body.password.length < 6 ||
      body.realName.length === 0 || body.phone.length !== 11) {
      res.code = 40001
      res.message = '注册失败，请检查姓名、手机号或账号'
      res.data = new LoginResponse()
      return res
    }
    const data = new LoginResponse()
    data.accessToken = `offline_reg_${body.username}`
    res.code = 0
    res.message = 'ok'
    res.data = data
    return res
  }

  private static mockChat(body: AiChatRequest): ApiResponse<AiChatResponse> {
    const data = new AiChatResponse()
    const preview = body.prompt.length > 60 ? body.prompt.substring(0, 60) : body.prompt
    data.reply = `【离线演示】已收到：${preview}。`
    const res = new ApiResponse<AiChatResponse>()
    res.code = 0
    res.message = 'ok'
    res.data = data
    return res
  }

  private static mockAnalyze(): ApiResponse<AiAnalyzeResponse> {
    const data = new AiAnalyzeResponse()
    data.summary = '本月经营概况良好，待办任务需优先闭环。'
    data.highlight1 = '营收环比上升'
    data.highlight2 = '高优待办 2 项'
    const res = new ApiResponse<AiAnalyzeResponse>()
    res.code = 0
    res.message = 'ok'
    res.data = data
    return res
  }

  private static mockGenerate(): ApiResponse<AiGenerateResponse> {
    const data = new AiGenerateResponse()
    data.content = '# 经营周报\n\n## 概况\n本周业务平稳推进。\n\n## 建议\n优先处理高优待办。'
    const res = new ApiResponse<AiGenerateResponse>()
    res.code = 0
    res.message = 'ok'
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

  private static wrapChat<T>(source: ApiResponse<AiChatResponse>): ApiResponse<T> {
    const res = new ApiResponse<T>()
    res.code = source.code
    res.message = source.message
    res.data = source.data as T
    return res
  }

  private static wrapAnalyze<T>(source: ApiResponse<AiAnalyzeResponse>): ApiResponse<T> {
    const res = new ApiResponse<T>()
    res.code = source.code
    res.message = source.message
    res.data = source.data as T
    return res
  }

  private static wrapGenerate<T>(source: ApiResponse<AiGenerateResponse>): ApiResponse<T> {
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
