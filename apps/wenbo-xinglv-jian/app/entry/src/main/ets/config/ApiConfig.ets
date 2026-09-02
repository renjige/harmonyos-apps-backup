/** 行旅笺 — 公网 SaaS API（可选登录与消息） */
export class ApiConfig {
  static readonly DEV_HOST: string = 'saas1.qianqi.online'
  static readonly USE_HTTPS: boolean = true
  static readonly TENANT_ID: string = 'wenbo-xinglv-jian'

  static baseUrl(): string {
    const scheme = ApiConfig.USE_HTTPS ? 'https' : 'http'
    return `${scheme}://${ApiConfig.DEV_HOST}/api/v1`
  }

  static applyToAppStorage(): void {
    AppStorage.setOrCreate('apiBaseUrl', ApiConfig.baseUrl())
    AppStorage.setOrCreate('tenantId', ApiConfig.TENANT_ID)
    AppStorage.setOrCreate('allowDevHttp', false)
  }
}
