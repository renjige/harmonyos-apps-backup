/**
 * 平台 SaaS API（公网统一入口 · HTTPS）。
 * TENANT_ID 必须与 platform/tenants/zhuke-jianzhu.json 一致。
 * 公网站点：saas16.qianqi.online（同事 D 独立站）
 */
export class ApiConfig {
  static readonly DEV_HOST: string = 'saas16.qianqi.online'
  static readonly DEV_PORT: number = 443
  static readonly USE_HTTPS: boolean = true
  static readonly USE_LOCAL_DEV: boolean = false
  static readonly TENANT_ID: string = 'zhuke-jianzhu'

  static devBaseUrl(): string {
    if (ApiConfig.USE_HTTPS) {
      return `https://${ApiConfig.DEV_HOST}/api/v1`
    }
    return `http://${ApiConfig.DEV_HOST}/api/v1`
  }

  static tenantId(): string {
    return ApiConfig.TENANT_ID
  }

  static isDevHttpAllowed(url: string): boolean {
    return url.startsWith('http://')
  }
}
