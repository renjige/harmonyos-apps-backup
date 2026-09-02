import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'sparkle'
  gradStart: string = '#1B4332'
  gradEnd: string = '#52B788'
  iconTint: string = '#FFFFFF'
}

export class SymbolVisualUtil {
  static resolve(category: string, coverKey: string): CategoryVisual {
    const v = new CategoryVisual()
    if (category === 'nature' || coverKey.indexOf('nature') >= 0) {
      v.iconName = 'sparkle'
      v.gradStart = '#143728'
      v.gradEnd = '#40916C'
      return v
    }
    if (category === 'life') {
      v.iconName = 'home'
      v.gradStart = '#2D3142'
      v.gradEnd = '#6B705C'
      return v
    }
    if (category === 'science') {
      v.iconName = 'chart'
      v.gradStart = '#1A2F4A'
      v.gradEnd = '#457B9D'
      return v
    }
    if (category === 'culture') {
      v.iconName = 'book'
      v.gradStart = '#3D2C2E'
      v.gradEnd = '#8B5E3C'
      v.iconTint = '#F5F0E8'
      return v
    }
    if (category === 'fun') {
      v.iconName = 'heart'
      v.gradStart = '#4A1942'
      v.gradEnd = '#9D4EDD'
      return v
    }
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop category: string = 'nature'
  @Prop coverKey: string = ''
  @Prop tileSize: number = 80
  @Prop cornerRadius: number = Theme.radius.xl

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
      AppIcon({
        name: this.visual().iconName,
        iconSize: Math.floor(this.tileSize * 0.34),
        color: this.visual().iconTint
      })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .borderRadius(this.cornerRadius)
  }
}

@Component
export struct SymbolHero {
  @Prop category: string = 'nature'
  @Prop coverKey: string = ''
  @Prop bannerHeight: number = 200
  @Prop overline: string = ''
  @Prop title: string = ''
  @Prop subtitle: string = ''

  private visual(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.category, this.coverKey)
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height(this.bannerHeight)
        .linearGradient({
          angle: 135,
          colors: [[this.visual().gradStart, 0], [this.visual().gradEnd, 1]]
        })
      Column()
        .width('100%')
        .height(this.bannerHeight)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0.1], ['rgba(8,28,21,0.82)', 1.0]]
        })
      Column({ space: 6 }) {
        if (this.overline.length > 0) {
          Text(this.overline)
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
        }
        if (this.title.length > 0) {
          Text(this.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .maxLines(2)
        }
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .height(this.bannerHeight)
  }
}
