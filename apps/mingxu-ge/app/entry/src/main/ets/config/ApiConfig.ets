/**
 * 平台 API — 同事独立站 saas16
 */
export class ApiConfig {
  static readonly DEV_HOST: string = 'saas16.qianqi.online'
  static readonly USE_HTTPS: boolean = true
  static readonly TENANT_ID: string = 'mingxu-ge'

  static tenantId(): string {
    return ApiConfig.TENANT_ID
  }

  static baseUrl(): string {
    const scheme = ApiConfig.USE_HTTPS ? 'https' : 'http'
    return `${scheme}://${ApiConfig.DEV_HOST}/api/v1`
  }
}
