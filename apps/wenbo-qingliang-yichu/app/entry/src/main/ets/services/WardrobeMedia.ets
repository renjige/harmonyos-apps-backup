import { AppIconName } from '../components/design-system/AppIcon'

export class WardrobeColorBadge {
  name: string = ''
  hex: string = '#8FB8DE'
  textHex: string = '#1F2927'

  constructor(name: string, hex: string, textHex: string = '#1F2927') {
    this.name = name
    this.hex = hex
    this.textHex = textHex
  }
}

export type PresetColor = WardrobeColorBadge

export class WardrobeMedia {
  static readonly PRESET_COLORS: WardrobeColorBadge[] = [
    new WardrobeColorBadge('白色', '#FFFFFF', '#1F2927'),
    new WardrobeColorBadge('浅蓝', '#8FB8DE', '#1F2927'),
    new WardrobeColorBadge('薄荷绿', '#A8DADC', '#1F2927'),
    new WardrobeColorBadge('米白', '#F3EFE6', '#1F2927'),
    new WardrobeColorBadge('浅灰', '#D3D7D9', '#1F2927'),
    new WardrobeColorBadge('深蓝', '#1D3557', '#FFFFFF'),
    new WardrobeColorBadge('黑色', '#222222', '#FFFFFF'),
    new WardrobeColorBadge('燕麦色', '#E8D8C8', '#1F2927'),
    new WardrobeColorBadge('淡粉', '#F4C2C2', '#1F2927'),
    new WardrobeColorBadge('鼠尾草绿', '#9CAF88', '#FFFFFF'),
  ]

  static readonly CATEGORIES: string[] = ['全部', '上装', '下装', '连衣裙', '外套', '鞋履', '配饰']
  static readonly SEASONS: string[] = ['春季', '夏季', '秋季', '冬季', '四季']
  static readonly SCENES: string[] = ['日常', '通勤', '约会', '休闲', '运动']
  static readonly STYLES: string[] = ['清爽', '简约', '休闲', '优雅']
  static readonly WEATHERS: string[] = ['晴', '多云', '阴', '雨']

  static resolveColorHex(colorName: string): string {
    for (const c of WardrobeMedia.PRESET_COLORS) {
      if (c.name === colorName) {
        return c.hex
      }
    }
    if (colorName.includes('蓝')) return '#8FB8DE'
    if (colorName.includes('绿')) return '#A8DADC'
    if (colorName.includes('白')) return '#F3EFE6'
    if (colorName.includes('黑')) return '#222222'
    if (colorName.includes('灰')) return '#D3D7D9'
    if (colorName.includes('米') || colorName.includes('杏')) return '#F3EFE6'
    if (colorName.includes('粉')) return '#F4C2C2'
    return '#8FB8DE'
  }

  static getCategoryIcon(category: string): AppIconName {
    if (category === '上装') return 'hanger'
    if (category === '下装') return 'wardrobe'
    if (category === '连衣裙') return 'star'
    if (category === '外套') return 'hanger'
    if (category === '鞋履') return 'wardrobe'
    if (category === '配饰') return 'sparkle'
    return 'wardrobe'
  }

  static getWeatherIcon(weather: string): AppIconName {
    if (weather === '晴') return 'weather_sun'
    if (weather === '多云' || weather === '阴') return 'weather_cloud'
    if (weather === '雨') return 'weather_rain'
    return 'weather_sun'
  }
}
