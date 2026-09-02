import { Theme } from '../design-system/Theme'

@Component
export struct DetailShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop cover: Resource = $r('app.media.cover_scroll')
  @Prop heroHeight: number = 220
  onClose: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(this.cover)
          .width('100%')
          .height(this.heroHeight)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(this.heroHeight)
          .linearGradient({
            angle: 180,
            colors: [['rgba(28,40,51,0.08)', 0], ['rgba(28,40,51,0.82)', 1]]
          })
        Row() {
          Text('返回')
            .fontSize(15)
            .fontColor('#F8F4ED')
            .padding({ left: 4, right: 12, top: 8, bottom: 8 })
            .onClick(() => this.onClose())
          Blank()
        }
        .width('100%')
        .padding({ left: 12, right: 16, top: 12 })
        .align(Alignment.TopStart)
        .position({ x: 0, y: 0 })
        Column({ space: 6 }) {
          Text(this.title)
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F8F4ED')
            .maxLines(2)
        }
        .padding({ left: 20, right: 20, bottom: 18 })
      }
      .clip(true)
      .width('100%')
    }
    .width('100%')
  }
}

@Component
export struct DetailMetaRow {
  @Prop text: string = ''

  build() {
    Text(this.text)
      .fontSize(13)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .fontWeight(FontWeight.Medium)
      .width('100%')
  }
}

@Component
export struct DetailSection {
  @Prop heading: string = ''
  @Prop body: string = ''

  build() {
    Column({ space: 8 }) {
      Text(this.heading)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.body.length > 0 ? this.body : '暂无')
        .fontSize(15)
        .lineHeight(26)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(20)
  }
}
