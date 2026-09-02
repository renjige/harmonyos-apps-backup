/**
 * 与 AppGallery Connect 提交信息保持一致：
 * 应用名称 = 购物备忘；开发者 / 运营者 = 魏文波。
 */
export class BrandIdentity {
  static appName(): string {
    return '购物备忘'
  }

  static developer(): string {
    return '承德锐泓科技信息有限公司'
  }

  static operator(): string {
    return '承德锐泓科技信息有限公司'
  }

  static version(): string {
    return '1.2.0'
  }

  static legalHeader(): string {
    return `应用名称：${BrandIdentity.appName()}\n开发者：${BrandIdentity.developer()}\n运营者：${BrandIdentity.operator()}\n`
  }

  static aboutLine(): string {
    return `应用名称：${BrandIdentity.appName()}　开发者：${BrandIdentity.developer()}`
  }
}
