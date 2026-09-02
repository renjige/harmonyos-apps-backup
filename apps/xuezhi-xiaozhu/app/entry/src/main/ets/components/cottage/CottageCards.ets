import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CottageMedia } from '../../services/CottageMedia'

@Component
export struct PathListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop meta: string = ''
  @Prop coverKey: string = ''
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(CottageMedia.resource(this.coverKey))
        .width(88)
        .height(88)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
        Text(this.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
        if (this.meta.length > 0) {
          Text(this.meta)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onOpen())
  }
}

@Component
export struct CardGridTile {
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = ''
  onOpen: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(CottageMedia.resource(this.coverKey))
          .width('100%')
          .height(110)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(110)
          .linearGradient({
            angle: 180,
            colors: [['rgba(18,32,58,0.05)', 0.35], ['rgba(18,32,58,0.78)', 1]]
          })
        Text(this.title)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F8FAFC')
          .maxLines(2)
          .padding({ left: 10, right: 10, bottom: 10 })
      }
      .width('100%')
      .clip(true)
      Text(this.summary)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .padding({ left: 10, right: 10, top: 8, bottom: 10 })
        .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onOpen())
  }
}
