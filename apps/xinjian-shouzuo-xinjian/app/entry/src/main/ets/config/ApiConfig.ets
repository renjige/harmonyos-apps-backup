/** 手作心笺 — 公网 SaaS API（同事独立站 saas16） */
export class ApiConfig {
  static readonly DEV_HOST: string = 'saas16.qianqi.online'
  static readonly USE_HTTPS: boolean = true
  static readonly TENANT_ID: string = 'xinjian-shouzuo-xinjian'

  static baseUrl(): string {
    if (ApiConfig.USE_HTTPS) {
      return `https://${ApiConfig.DEV_HOST}/api/v1`
    }
    return `http://${ApiConfig.DEV_HOST}/api/v1`
  }

  static tenantId(): string {
    return ApiConfig.TENANT_ID
  }
}
