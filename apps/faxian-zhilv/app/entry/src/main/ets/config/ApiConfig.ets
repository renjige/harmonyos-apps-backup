/** 发现之旅 — 公网 SaaS API（saas16） */
export class ApiConfig {
  static readonly DEV_HOST: string = 'saas16.qianqi.online'
  static readonly USE_HTTPS: boolean = true
  static readonly TENANT_ID: string = 'faxian-zhilv'

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
