import { Theme } from '../design-system/Theme'
import { QuestMedia } from '../../services/QuestMedia'

@Component
export struct CoverHero {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop coverKey: string = 'hero_discover'
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop heroHeight: number = 200

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(QuestMedia.cover(this.coverKey))
        .width('100%')
        .height(this.heroHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Column()
        .width('100%')
        .height(110)
        .linearGradient({
          angle: 180,
          colors: [['rgba(15,10,40,0)', 0], ['rgba(15,10,40,0.82)', 1]]
        })
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(13)
            .fontColor('#FFFFFF')
        }
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(this.heroHeight)
    .borderRadius(Theme.radius.md)
    .clip(true)
  }
}

@Component
export struct MapGridCard {
  @Prop title: string = ''
  @Prop coverKey: string = 'hero_discover'
  @Prop meta: string = ''
  @Prop done: boolean = false
  onTap: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(QuestMedia.cover(this.coverKey))
          .width('100%')
          .height(110)
          .objectFit(ImageFit.Cover)
        if (this.done) {
          Text('已通关')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().success)
            .borderRadius(Theme.radius.xs)
            .margin(8)
        }
      }
      .width('100%')
      .height(110)
      .clip(true)
      Text(this.title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 8, left: 10, right: 10 })
      Text(this.meta)
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .margin({ left: 10, right: 10, bottom: 10, top: 2 })
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .onClick(() => this.onTap())
  }
}

@Component
export struct StatChip {
  @Prop label: string = ''
  @Prop value: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(this.label)
        .fontSize(11)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
