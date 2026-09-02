export class BrandIdentity {
  static appName(): string {
    return '筑科材料验收'
  }

  static developer(): string {
    return '齐齐哈尔筑科建筑工程有限责任公司'
  }

  static operator(): string {
    return '齐齐哈尔筑科建筑工程有限责任公司'
  }

  static company(): string {
    return '筑科建筑工程有限公司'
  }

  static version(): string {
    return '1.0.0'
  }

  static tagline(): string {
    return '让每一次材料验收都有据可查'
  }

  static legalHeader(): string {
    return `应用名称：${BrandIdentity.appName()}\n开发者：${BrandIdentity.developer()}\n运营者：${BrandIdentity.operator()}\n`
  }

  static aboutLine(): string {
    return `应用名称：${BrandIdentity.appName()}　开发者：${BrandIdentity.developer()}`
  }
}
