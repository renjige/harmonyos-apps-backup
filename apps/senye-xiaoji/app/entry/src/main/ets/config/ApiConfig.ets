/** 森野小记 — 公网 SaaS（登录/注册；记录数据本机存储） */
export class ApiConfig {
  static readonly DEV_HOST: string = 'saas16.qianqi.online'
  static readonly USE_HTTPS: boolean = true
  static readonly TENANT_ID: string = 'senye-xiaoji'

  static baseUrl(): string {
    const custom = AppStorage.get<string>('apiBaseUrl')
    if (custom !== undefined && custom.length > 0) {
      return custom
    }
    const scheme = ApiConfig.USE_HTTPS ? 'https' : 'http'
    return `${scheme}://${ApiConfig.DEV_HOST}/api/v1`
  }

  static tenantId(): string {
    return ApiConfig.TENANT_ID
  }

  static applyToAppStorage(): void {
    AppStorage.setOrCreate('apiBaseUrl', ApiConfig.baseUrl())
    AppStorage.setOrCreate('tenantId', ApiConfig.TENANT_ID)
    AppStorage.setOrCreate('allowDevHttp', false)
  }
}
