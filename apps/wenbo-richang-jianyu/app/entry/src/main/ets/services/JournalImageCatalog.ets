/** 相册/笺语配图：内置资源 key + 本地相册 local: 前缀 */

export class JournalImageOption {
  key: string = ''
  label: string = ''

  constructor(key: string, label: string) {
    this.key = key
    this.label = label
  }
}

export class JournalImageCatalog {
  static albumPresetOptions(): JournalImageOption[] {
    return [
      new JournalImageOption('hero_morning_coffee', '晨光咖啡'),
      new JournalImageOption('hero_rain_walk', '雨后散步'),
      new JournalImageOption('hero_kitchen', '厨房小确幸'),
      new JournalImageOption('hero_bookstore', '旧书店'),
      new JournalImageOption('hero_plants', '窗台绿植'),
      new JournalImageOption('hero_postcard', '旅途明信片'),
      new JournalImageOption('album_season_table', '四季餐桌'),
      new JournalImageOption('album_city_walk', '城市漫步'),
      new JournalImageOption('album_nature', '自然光影'),
      new JournalImageOption('album_scrapbook', '手账剪贴')
    ]
  }

  static toLocalKey(uri: string): string {
    return `local:${uri}`
  }

  static isLocalKey(key: string): boolean {
    return key.startsWith('local:')
  }

  static localUriFromKey(key: string): string {
    if (JournalImageCatalog.isLocalKey(key)) {
      return key.substring(6)
    }
    return ''
  }
}
