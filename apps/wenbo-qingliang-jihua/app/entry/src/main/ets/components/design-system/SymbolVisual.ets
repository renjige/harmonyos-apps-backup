import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

/** 清凉计划 — 分类 / 封面键 → Symbol 渐变视觉（冰泉青气质） */
export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#1F6B5E'
  gradEnd: string = '#2D8B7A'
  iconTint: string = '#F5FAF8'
}

export class SymbolVisualUtil {
  static resolve(category: string, coverKey: string): CategoryVisual {
    const v = new CategoryVisual()
    if (coverKey.indexOf('breath_calm') >= 0 || category === '平静呼吸') {
      v.iconName = 'heart'
      v.gradStart = '#1A4A42'
      v.gradEnd = '#2D8B7A'
      return v
    }
    if (coverKey.indexOf('breath_focus') >= 0 || category === '专注呼吸') {
      v.iconName = 'sparkle'
      v.gradStart = '#1A3A52'
      v.gradEnd = '#4A9E9E'
      return v
    }
    if (coverKey.indexOf('breath_sleep') >= 0 || category === '睡前呼吸') {
      v.iconName = 'clock'
      v.gradStart = '#2A3A5A'
      v.gradEnd = '#5A7A9A'
      v.iconTint = '#E8F4F8'
      return v
    }
    if (coverKey.indexOf('tea') >= 0) {
      v.iconName = 'book'
      v.gradStart = '#2A5248'
      v.gradEnd = '#7EC8B0'
      return v
    }
    if (coverKey.indexOf('leaf') >= 0 || coverKey.indexOf('morning') >= 0) {
      v.iconName = 'sparkle'
      v.gradStart = '#1F6B5E'
      v.gradEnd = '#A8D5BA'
      return v
    }
    if (category === '语录' || coverKey.indexOf('mist') >= 0) {
      v.iconName = 'book'
      v.gradStart = '#1A2A2A'
      v.gradEnd = '#4A9E9E'
      return v
    }
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop category: string = ''
  @Prop coverKey: string = 'hero_mist_lake'
  @Prop tileSize: number = 72
  @Prop cornerRadius: number = Theme.radius.md

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
        .backgroundColor('rgba(255,255,255,0.14)')
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

@Component
export struct SymbolHero {
  @Prop category: string = ''
  @Prop coverKey: string = 'hero_mist_lake'
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
          colors: [['rgba(26,42,42,0)', 0], ['rgba(26,42,42,0.88)', 1]]
        })

      if (this.title.length > 0 || this.overline.length > 0) {
        Column({ space: 6 }) {
          if (this.overline.length > 0) {
            Text(this.overline)
              .fontSize(Theme.type.overline)
              .fontColor('#A8D5BA')
          }
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(this.compact ? Theme.type.title3 : Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F5FAF8')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
    }
    .width('100%')
    .height(this.bannerHeight)
  }
}
