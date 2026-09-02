import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

/** 节气 / 功效 → Symbol 渐变视觉（贴士缺图时 fallback） */
export class CategoryVisual {
  iconName: AppIconName = 'sparkle'
  gradStart: string = '#E8833A'
  gradEnd: string = '#3A7D44'
  iconTint: string = '#FFFFFF'
}

export class SymbolVisualUtil {
  static resolve(solarTerm: string, effect: string): CategoryVisual {
    const v = new CategoryVisual()
    if (effect === '清热') {
      v.iconName = 'sparkle'
      v.gradStart = '#3A7D44'
      v.gradEnd = '#5BA86A'
      return v
    }
    if (effect === '温补') {
      v.iconName = 'heart'
      v.gradStart = '#C45A20'
      v.gradEnd = '#E8833A'
      return v
    }
    if (solarTerm.indexOf('春') >= 0) {
      v.iconName = 'sparkle'
      v.gradStart = '#3A7D44'
      v.gradEnd = '#6BAF72'
      return v
    }
    if (solarTerm.indexOf('夏') >= 0) {
      v.iconName = 'calendar'
      v.gradStart = '#E8833A'
      v.gradEnd = '#D4A373'
      return v
    }
    if (solarTerm.indexOf('秋') >= 0) {
      v.iconName = 'book'
      v.gradStart = '#8B5A2B'
      v.gradEnd = '#C4884A'
      return v
    }
    if (solarTerm.indexOf('冬') >= 0 || solarTerm.indexOf('寒') >= 0) {
      v.iconName = 'heart'
      v.gradStart = '#2C2420'
      v.gradEnd = '#5C5048'
      v.iconTint = '#F5F0E8'
      return v
    }
    return v
  }
}

/** 列表缩略图 fallback：渐变底 + Symbol */
@Component
export struct SymbolCover {
  @Prop solarTerm: string = ''
  @Prop effect: string = ''
  @Prop tileSize: number = 72
  @Prop cornerRadius: number = Theme.radius.sm

  private visual(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.solarTerm, this.effect)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [[this.visual().gradStart, 0], [this.visual().gradEnd, 1]]
        })
      AppIcon({
        name: this.visual().iconName,
        iconSize: Math.floor(this.tileSize * 0.36),
        color: this.visual().iconTint
      })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .borderRadius(this.cornerRadius)
    .clip(true)
  }
}

/** 详情 Hero：渐变底 + 居中 Symbol + 底部标题（贴士等短内容 fallback） */
@Component
export struct SymbolHero {
  @Prop solarTerm: string = ''
  @Prop effect: string = ''
  @Prop bannerHeight: number = 200
  @Prop overline: string = ''
  @Prop title: string = ''
  @Prop compact: boolean = false

  private visual(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.solarTerm, this.effect)
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height(this.bannerHeight)
        .linearGradient({
          angle: 160,
          colors: [[this.visual().gradStart, 0], [this.visual().gradEnd, 0.72]]
        })

      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.compact ? 72 : 88)
          .height(this.compact ? 72 : 88)
          .backgroundColor('rgba(255,255,255,0.12)')
          .borderRadius(this.compact ? 36 : 44)
        AppIcon({
          name: this.visual().iconName,
          iconSize: this.compact ? 36 : 44,
          color: this.visual().iconTint
        })
      }
      .width('100%')
      .height(this.bannerHeight)

      Column()
        .width('100%')
        .height(this.compact ? 100 : 120)
        .linearGradient({
          angle: 180,
          colors: [['rgba(44,36,32,0)', 0], ['rgba(44,36,32,0.88)', 1]]
        })

      if (this.title.length > 0 || this.overline.length > 0) {
        Column({ space: 6 }) {
          if (this.overline.length > 0) {
            Text(this.overline)
              .fontSize(Theme.type.overline)
              .fontColor('#F5F0E8')
          }
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(this.compact ? Theme.type.title3 : Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .maxLines(3)
          }
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
      }
    }
    .width('100%')
    .height(this.bannerHeight)
    .borderRadius(Theme.radius.md)
    .clip(true)
  }
}
