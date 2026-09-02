import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#15803D'
  gradEnd: string = '#16A34A'
  iconTint: string = '#FAFAF5'
}

export class SymbolVisualUtil {
  static resolve(category: string, coverKey: string): CategoryVisual {
    const v = new CategoryVisual()
    if (coverKey.indexOf('guide_tent') >= 0 || coverKey.indexOf('tpl') >= 0) {
      v.iconName = 'home'
      v.gradStart = '#15803D'
      v.gradEnd = '#22C55E'
      return v
    }
    if (coverKey.indexOf('rain') >= 0) {
      v.iconName = 'alert'
      v.gradStart = '#334155'
      v.gradEnd = '#64748B'
      return v
    }
    if (coverKey.indexOf('cook') >= 0) {
      v.iconName = 'gear'
      v.gradStart = '#7C2D12'
      v.gradEnd = '#FB923C'
      return v
    }
    if (coverKey.indexOf('stars') >= 0 || coverKey.indexOf('altitude') >= 0) {
      v.iconName = 'sparkle'
      v.gradStart = '#0F172A'
      v.gradEnd = '#334155'
      v.iconTint = '#FB923C'
      return v
    }
    if (coverKey.indexOf('kids') >= 0 || category === '亲子露营') {
      v.iconName = 'heart'
      v.gradStart = '#166534'
      v.gradEnd = '#4ADE80'
      return v
    }
    if (category === '团队露营') {
      v.iconName = 'biz'
      v.gradStart = '#14532D'
      v.gradEnd = '#15803D'
      return v
    }
    if (category === 'solo露营') {
      v.iconName = 'bag'
      v.gradStart = '#1E3A2A'
      v.gradEnd = '#16A34A'
      return v
    }
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop category: string = ''
  @Prop coverKey: string = 'guide_tent'
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
  @Prop coverKey: string = 'guide_tent'
  @Prop bannerHeight: number = 220
  @Prop overline: string = ''
  @Prop title: string = ''

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
          colors: [['rgba(21,128,61,0)', 0.05], ['rgba(21,128,61,0.82)', 1.0]]
        })
      Column() {
        AppIcon({
          name: this.visual().iconName,
          iconSize: Theme.icon.xl,
          color: this.visual().iconTint
        })
      }
      .width('100%')
      .height(this.bannerHeight - 80)
      .justifyContent(FlexAlign.Center)
      if (this.title.length > 0 || this.overline.length > 0) {
        Column({ space: 6 }) {
          if (this.overline.length > 0) {
            Text(this.overline)
              .fontSize(Theme.type.caption)
              .fontColor('#FB923C')
              .width('100%')
          }
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FAFAF5')
              .width('100%')
          }
        }
        .padding(16)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .height(this.bannerHeight)
    .clip(true)
    .borderRadius(Theme.radius.card)
  }
}
