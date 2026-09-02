/** 旅行相册 / 日记配图：内置资源 key */

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
      new JournalImageOption('hero_mountain_lake', '洱海晨雾'),
      new JournalImageOption('hero_coastal_sunset', '海岸日落'),
      new JournalImageOption('hero_ancient_city', '古城街巷'),
      new JournalImageOption('hero_forest_path', '森林步道'),
      new JournalImageOption('hero_snow_mountain', '雪山远峰'),
      new JournalImageOption('hero_desert_dunes', '沙漠星夜'),
      new JournalImageOption('album_sakura_temple', '樱花寺庙'),
      new JournalImageOption('album_mediterranean', '地中海蓝'),
      new JournalImageOption('album_aurora', '极光之夜'),
      new JournalImageOption('album_tropical_island', '热带岛屿')
    ]
  }
}
