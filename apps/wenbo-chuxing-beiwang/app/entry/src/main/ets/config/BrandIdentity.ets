/**
 * 与 AppGallery Connect 提交信息保持一致：
 * 应用名称 = 出行备忘；开发者 / 运营者 = 魏文波。
 */
export class BrandIdentity {
  static appName(): string {
    return '出行备忘'
  }

  static developer(): string {
    return '承德锐泓科技信息有限公司'
  }

  static operator(): string {
    return '承德锐泓科技信息有限公司'
  }

  static version(): string {
    return '1.1.0'
  }

  static legalHeader(): string {
    return `应用名称：${BrandIdentity.appName()}\n开发者：${BrandIdentity.developer()}\n运营者：${BrandIdentity.operator()}\n更新日期：2026年8月21日\n`
  }
}
