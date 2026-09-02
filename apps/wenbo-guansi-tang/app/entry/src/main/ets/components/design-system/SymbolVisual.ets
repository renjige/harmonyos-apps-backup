import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

/** 分类 / 封面键 → Symbol 渐变视觉 */
export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#2D2D3F'
  gradEnd: string = '#6B6B7B'
  iconTint: string = '#F8F6F3'
}

export class SymbolVisualUtil {
  static resolve(category: string, coverKey: string): CategoryVisual {
    const v = new CategoryVisual()
    if (coverKey === 'cover_topic_daily') {
      v.iconName = 'sparkle'
      v.gradStart = '#1A1A2E'
      v.gradEnd = '#3D3D52'
      v.iconTint = '#C9A96E'
      return v
    }
    if (category === '职场') {
      v.iconName = 'biz'
      v.gradStart = '#1A1A2E'
      v.gradEnd = '#4A4A62'
      return v
    }
    if (category === '人生') {
      v.iconName = 'user'
      v.gradStart = '#2A3D38'
      v.gradEnd = '#5C7A72'
      return v
    }
    if (category === '阅读') {
      v.iconName = 'book'
      v.gradStart = '#2D2D3F'
      v.gradEnd = '#8B7355'
      v.iconTint = '#F5F0E8'
      return v
    }
    if (category === '情感') {
      v.iconName = 'heart'
      v.gradStart = '#3D2A32'
      v.gradEnd = '#7A5560'
      return v
    }
    if (category === '灵感') {
      v.iconName = 'sparkle'
      v.gradStart = '#2D2D3F'
      v.gradEnd = '#8B7A4A'
      v.iconTint = '#E8DFD0'
      return v
    }
    if (coverKey.indexOf('reading') >= 0) {
      v.iconName = 'book'
      v.gradStart = '#2D2D3F'
      v.gradEnd = '#6B6B7B'
      return v
    }
    if (coverKey.indexOf('wisdom') >= 0) {
      v.iconName = 'biz'
      v.gradStart = '#1A1A2E'
      v.gradEnd = '#5C5C6E'
      return v
    }
    return v
  }
}

/** 列表缩略图：渐变底 + 居中 Symbol */
@Component
export struct SymbolCover {
  @Prop category: string = ''
  @Prop coverKey: string = 'cover_wisdom'
  @Prop tileSize: number = 72
  @Prop cornerRadius: number = Theme.radius.sm

  private visual(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.category, this.coverKey)
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
      Column()
        .width(this.tileSize * 0.55)
        .height(this.tileSize * 0.55)
        .backgroundColor('rgba(255,255,255,0.12)')
        .borderRadius(this.tileSize * 0.275)
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

/** 详情 / 议题 Hero：Symbol 主视觉 + 底部标题 */
@Component
export struct SymbolHero {
  @Prop category: string = ''
  @Prop coverKey: string = 'cover_wisdom'
  @Prop bannerHeight: number = 200
  @Prop overline: string = ''
  @Prop title: string = ''
  @Prop compact: boolean = false

  private visual(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.category, this.coverKey)
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
          .backgroundColor('rgba(255,255,255,0.10)')
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
          colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.85)', 1]]
        })

      if (this.title.length > 0 || this.overline.length > 0) {
        Column({ space: 6 }) {
          if (this.overline.length > 0) {
            Text(this.overline)
              .fontSize(Theme.type.overline)
              .fontColor('#C9A96E')
          }
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(this.compact ? Theme.type.title3 : Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F8F6F3')
              .maxLines(3)
          }
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
      }
    }
    .width('100%')
    .height(this.bannerHeight)
    .borderRadius(Theme.radius.card)
    .clip(true)
  }
}
