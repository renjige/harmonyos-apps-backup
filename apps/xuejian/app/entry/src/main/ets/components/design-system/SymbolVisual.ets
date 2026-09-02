import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#1A2A4A'
  gradEnd: string = '#121C32'
  iconTint: string = '#FFFFFF'
}

export class SymbolVisualUtil {
  static resolve(category: string): CategoryVisual {
    const v = new CategoryVisual()
    if (category === '数学') {
      v.iconName = 'chart'
      v.gradStart = '#1A2A4A'
      v.gradEnd = '#3D4F73'
    } else if (category === '英语') {
      v.iconName = 'book'
      v.gradStart = '#2A4060'
      v.gradEnd = '#1A2A4A'
    } else if (category === '编程') {
      v.iconName = 'grid'
      v.gradStart = '#1A2A4A'
      v.gradEnd = '#0E1628'
    } else if (category === '职场') {
      v.iconName = 'biz'
      v.gradStart = '#3A2A12'
      v.gradEnd = '#1A2A4A'
    } else if (category === '方法') {
      v.iconName = 'clock'
      v.gradStart = '#C48A1A'
      v.gradEnd = '#1A2A4A'
    } else {
      v.iconName = 'bookmark'
      v.gradStart = '#1A2A4A'
      v.gradEnd = '#121C32'
    }
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop category: string = '其他'
  @Prop tileSize: number = 72

  build() {
    Column() {
      AppIcon({
        name: SymbolVisualUtil.resolve(this.category).iconName,
        iconSize: 22,
        color: '#FFFFFF'
      })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .justifyContent(FlexAlign.Center)
    .borderRadius(Theme.radius.sm)
    .linearGradient({
      angle: 135,
      colors: [
        [SymbolVisualUtil.resolve(this.category).gradStart, 0],
        [SymbolVisualUtil.resolve(this.category).gradEnd, 1]
      ]
    })
  }
}

@Component
export struct SymbolHero {
  @Prop category: string = '其他'
  @Prop bannerHeight: number = 180
  @Prop overline: string = ''
  @Prop title: string = ''

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height(this.bannerHeight)
        .linearGradient({
          angle: 135,
          colors: [
            [SymbolVisualUtil.resolve(this.category).gradStart, 0],
            [SymbolVisualUtil.resolve(this.category).gradEnd, 1]
          ]
        })
      Column({ space: 8 }) {
        AppIcon({
          name: SymbolVisualUtil.resolve(this.category).iconName,
          iconSize: 28,
          color: '#FFFFFF'
        })
        if (this.overline.length > 0) {
          Text(this.overline)
            .fontSize(Theme.type.caption)
            .fontColor('#FDF0D5')
        }
        if (this.title.length > 0) {
          Text(this.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
    }
    .width('100%')
    .height(this.bannerHeight)
    .borderRadius(Theme.radius.md)
    .clip(true)
  }
}
