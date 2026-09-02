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
import { InspirationListPayload, InspirationWire } from '../models/LanguageCraftModels'

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
    if (path.indexOf('/biz/language-craft/inspirations') === 0) {
      return HttpClient.wrapInspirations<T>(path)
    }
    return HttpClient.fail<T>(new EmptyPayload() as T, '网络不可用')
  }

  private static wrapInspirations<T>(path: string): ApiResponse<T> {
    const res = new ApiResponse<T>()
    res.code = 0
    res.message = 'ok'
    const idMatch = path.match(/\/inspirations\/([^?]+)$/)
    if (idMatch !== null && idMatch[1] !== undefined && idMatch[1].indexOf('?') < 0) {
      const row = HttpClient.mockInspirationById(idMatch[1])
      if (row === undefined) {
        res.code = 40401
        res.message = '灵感不存在'
        res.data = new InspirationWire() as T
        return res
      }
      res.data = row as T
      return res
    }
    const payload = new InspirationListPayload()
    payload.list = HttpClient.mockInspirationList(path)
    res.data = payload as T
    return res
  }

  private static mockInspirationList(path: string): InspirationWire[] {
    const all = HttpClient.seedInspirations()
    const q = path.indexOf('category=')
    if (q < 0) {
      return all
    }
    const encoded = path.substring(q + 9)
    let category = encoded
    try {
      category = decodeURIComponent(encoded)
    } catch {
      category = encoded
    }
    const out: InspirationWire[] = []
    for (const row of all) {
      if (row.category === category) {
        out.push(row)
      }
    }
    return out
  }

  private static mockInspirationById(id: string): InspirationWire | undefined {
    for (const row of HttpClient.seedInspirations()) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  private static seedInspirations(): InspirationWire[] {
    const list: InspirationWire[] = []
    const add = (id: string, title: string, category: string, cover: string, summary: string, body: string, example: string): void => {
      const w = new InspirationWire()
      w.id = id
      w.title = title
      w.category = category
      w.coverMedia = cover
      w.summary = summary
      w.body = body
      w.example = example
      list.push(w)
    }
    add('lc_in_01', '会议纪要怎样开场才清楚', '职场沟通', 'cover_meeting',
      '先写结论，再写待办主人与截止时间。',
      '会议纪要不是录音转写。最短可用的三件事：这次决定了什么、谁负责下一步、何时检查。',
      '本次对齐了 Q3 排期：方案 A 于 9 月 12 日前由李华提交初稿，周五例会复核。')
    add('lc_in_02', '婉拒协作请求的稳妥写法', '职场沟通', 'cover_email',
      '先认请求的价值，再给边界，最后给替代路径。',
      '直接说「没空」容易伤协作。可按三步：感谢与理解 → 当前优先级与时间边界 → 可提供的替代。',
      '谢谢把我列入讨论。本周我在收口现有交付，无法按周四节点深度参与。')
    add('lc_in_04', '论文摘要的四段骨架', '学术写作', 'cover_academic',
      '问题、方法、发现、意义，各用一句。',
      '摘要不是引言缩写。按「研究什么问题 → 用什么方法 → 得到什么结果 → 对谁有何意义」写。',
      '针对小型团队会议纪要难以执行的问题，本文提出三要素框架。')
    add('lc_in_07', '道歉：说明事实，不自我贬低', '日常表达', 'cover_daily',
      '承认影响、说明将如何补救，少说「我这个人就是…」。',
      '有效道歉指向具体行为与影响，而不是人格判决。',
      '昨天约定的资料我晚发了两小时，耽误了你准备材料。我已经把完整版发到邮箱。')
    add('lc_in_10', '产品卖点压成一句人话', '创意文案', 'cover_creative',
      '谁、在什么场合、少了什么麻烦。',
      '卖点句避免堆形容词。用场景替换「高效智能」。',
      '把一段绕口的工作邮件，三步收成同事愿意回的短消息。')
    add('lc_in_12', '品牌故事开篇：从一件小事进', '创意文案', 'cover_story',
      '从一个具体瞬间起笔，再落到你为何做这件事。',
      '开篇不要公司简介。从一个被卡住的句子、一封发不出去的信写起。',
      '有一封邮件在草稿箱里躺了两天。不是没写完，是写完了仍不敢点发送。')
    return list
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
    data.reply = `【离线演示】已收到：${preview}。连接后端后将返回真实 AI 结果。`
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
