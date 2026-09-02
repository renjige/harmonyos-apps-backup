import { Theme } from '../components/design-system/Theme'
import { LineArtCatalog } from '../services/LineArtCatalog'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onOpenFreeDraw: () => void = () => {}
  onOpenSticker: () => void = () => {}
  onOpenWorkshop: () => void = () => {}
  onOpenGallery: () => void = () => {}
  onOpenSteps: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_studio'))
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.xl)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0.0], ['rgba(74,74,74,0.75)', 1.0]]
            })
          Column({ space: Theme.space.s1 }) {
            Text('今天想画什么呀？')
              .fontSize(Theme.type.titleL)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('自由涂鸦 · 魔法贴纸 · 创意工坊')
              .fontSize(Theme.type.bodyM)
              .fontColor('#FFFFFF')
          }
          .padding(Theme.space.s5)
        }
        .width('100%')

        Row({ space: Theme.space.s4 }) {
          Image(LineArtCatalog.mediaResource('card_doodle'))
            .width(88).height(88).borderRadius(Theme.radius.lg).objectFit(ImageFit.Cover)
          Column({ space: Theme.space.s2 }) {
            Text('自由涂鸦').fontSize(Theme.type.titleM).fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('蜡笔、水彩、马克笔等五种笔触').fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        }
        .width('100%').padding(Theme.space.s5).backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 12, color: 'rgba(74,74,74,0.08)', offsetY: 4, offsetX: 0 })
        .onClick((): void => { this.onOpenFreeDraw() })

        Row({ space: Theme.space.s4 }) {
          Image(LineArtCatalog.mediaResource('card_fill'))
            .width(88).height(88).borderRadius(Theme.radius.lg).objectFit(ImageFit.Cover)
          Column({ space: Theme.space.s2 }) {
            Text('魔法贴纸').fontSize(Theme.type.titleM).fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('选贴纸、点画布，星星爱心小鱼任你贴').fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        }
        .width('100%').padding(Theme.space.s5).backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 12, color: 'rgba(74,74,74,0.08)', offsetY: 4, offsetX: 0 })
        .onClick((): void => { this.onOpenSticker() })

        Row({ space: Theme.space.s4 }) {
          Image(LineArtCatalog.mediaResource('card_workshop'))
            .width(88).height(88).borderRadius(Theme.radius.lg).objectFit(ImageFit.Cover)
          Column({ space: Theme.space.s2 }) {
            Text('创意工坊').fontSize(Theme.type.titleM).fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('点对点、拇指画、形状与滚珠').fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        }
        .width('100%').padding(Theme.space.s5).backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 12, color: 'rgba(74,74,74,0.08)', offsetY: 4, offsetX: 0 })
        .onClick((): void => { this.onOpenWorkshop() })

        Row() {
          Text('智慧引导 · 简笔画步骤')
            .fontSize(Theme.type.bodyL)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .layoutWeight(1)
          Text('查看')
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { this.onOpenSteps() })

        Row() {
          Text('我的画廊')
            .fontSize(Theme.type.bodyL)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.onOpenGallery() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }
}
