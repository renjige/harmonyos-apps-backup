import { Theme } from '../design-system/Theme'
import { XingyuMedia } from '../../services/XingyuMedia'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NarrativeCard {
  @Prop title: string = ''
  @Prop dateKey: string = ''
  @Prop statusLabel: string = ''
  @Prop preview: string = ''
  @Prop coverKey: string = 'cover_life'
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(XingyuMedia.image(this.coverKey))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
      Column({ space: 4 }) {
        Row() {
          Text(this.title.length > 0 ? this.title : '未命名叙事')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .maxLines(1)
            .layoutWeight(1)
          Text(this.statusLabel)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
        }
        .width('100%')
        Text(DateHelper.displayDate(this.dateKey))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text(this.preview)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(() => this.onOpen())
  }
}

@Component
export struct ThemeCard {
  @Prop title: string = ''
  @Prop coverKey: string = 'cover_life'
  @Prop countLabel: string = ''
  @Prop updatedLabel: string = ''
  onOpen: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(XingyuMedia.image(this.coverKey))
          .width('100%')
          .height(128)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(72)
          .linearGradient({
            angle: 180,
            colors: [['rgba(18,24,43,0)', 0], ['rgba(18,24,43,0.78)', 1]]
          })
        Column({ space: 2 }) {
          Text(this.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F6F3EC')
          Text(this.countLabel)
            .fontSize(Theme.type.caption)
            .fontColor('#D4CFC4')
        }
        .padding(Theme.space.s3)
        .width('100%')
      }
      .width('100%')
      .borderRadius(Theme.radius.md)
      .clip(true)
      if (this.updatedLabel.length > 0) {
        Text(this.updatedLabel)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .padding({ left: Theme.space.s1, top: Theme.space.s2 })
          .width('100%')
      }
    }
    .width('100%')
    .onClick(() => this.onOpen())
  }
}
