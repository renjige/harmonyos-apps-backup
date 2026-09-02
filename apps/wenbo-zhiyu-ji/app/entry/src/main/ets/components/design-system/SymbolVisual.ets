import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#1A2A3A'
  gradEnd: string = '#3D5266'
  iconTint: string = '#F7F5F0'
}

export class SymbolVisualUtil {
  static resolve(category: string, coverKey: string): CategoryVisual {
    const v = new CategoryVisual()
    if (category === '人生哲思') {
      v.iconName = 'user'
      v.gradStart = '#1A2A3A'
      v.gradEnd = '#2A4A3A'
      return v
    }
    if (category === '文学之美') {
      v.iconName = 'book'
      v.gradStart = '#1A2A3A'
      v.gradEnd = '#6B5344'
      v.iconTint = '#F7F5F0'
      return v
    }
    if (category === '处世智慧') {
      v.iconName = 'biz'
      v.gradStart = '#1A2A3A'
      v.gradEnd = '#4A4A62'
      return v
    }
    if (category === '情感共鸣') {
      v.iconName = 'heart'
      v.gradStart = '#3D2A32'
      v.gradEnd = '#7A5560'
      return v
    }
    if (category === '励志前行') {
      v.iconName = 'star'
      v.gradStart = '#1A2A3A'
      v.gradEnd = '#8B7355'
      v.iconTint = '#F7F5F0'
      return v
    }
    if (category === '古典雅韵') {
      v.iconName = 'book'
      v.gradStart = '#121820'
      v.gradEnd = '#5C4A32'
      v.iconTint = '#C9A96E'
      return v
    }
    if (coverKey.indexOf('wisdom') >= 0) {
      v.iconName = 'biz'
      v.gradStart = '#1A2A3A'
      v.gradEnd = '#3D5266'
    }
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop category: string = ''
  @Prop coverKey: string = 'cover_wisdom_ink'
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

@Component
export struct SymbolHero {
  @Prop category: string = ''
  @Prop coverKey: string = 'cover_wisdom_ink'
  @Prop bannerHeight: number = 220
  @Prop overline: string = ''
  @Prop title: string = ''
  @Prop subtitle: string = ''

  private visual(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.category, this.coverKey)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 160,
            colors: [[this.visual().gradStart, 0], [this.visual().gradEnd, 1]]
          })
        Column({ space: Theme.space.s2 }) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(64)
              .height(64)
              .backgroundColor('rgba(255,255,255,0.10)')
              .borderRadius(32)
            AppIcon({
              name: this.visual().iconName,
              iconSize: 32,
              color: this.visual().iconTint
            })
          }
          if (this.overline.length > 0) {
            Text(this.overline)
              .fontSize(Theme.type.overline)
              .fontColor('#F7F5F0')
          }
        }
      }
      .width('100%')
      .height(96)

      Stack({ alignContent: Alignment.TopStart }) {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 180,
            colors: [[this.visual().gradEnd, 0], ['rgba(15,24,32,0.96)', 1]]
          })
        Column({ space: Theme.space.s2 }) {
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F7F5F0')
              .lineHeight(30)
              .maxLines(5)
          }
          if (this.subtitle.length > 0) {
            Text(this.subtitle)
              .fontSize(Theme.type.caption)
              .fontColor('#E8E8E8')
          }
        }
        .width('100%')
        .padding({
          left: Theme.space.s4,
          right: Theme.space.s4,
          top: Theme.space.s3,
          bottom: Theme.space.s4
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height(this.bannerHeight)
    .borderRadius(Theme.radius.md)
    .clip(true)
  }
}
