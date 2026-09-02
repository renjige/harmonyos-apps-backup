/** 星座物候 — 公网栏目 API（saas16），日记与收藏走本机 */
export class ApiConfig {
  static readonly DEV_HOST: string = 'saas16.qianqi.online'
  static readonly USE_HTTPS: boolean = true
  static readonly TENANT_ID: string = 'guanshi-xingzuo-wuhou'

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
