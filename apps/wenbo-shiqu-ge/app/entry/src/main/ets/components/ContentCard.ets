import { Theme } from './design-system/Theme'
import { AppIcon } from './design-system/AppIcon'
import { ArticleItem } from '../models/PavilionModels'
import { PavilionMedia } from '../services/PavilionMedia'

@Component
export struct ContentCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop articleId: string = ''
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = 'hero_bg'
  @Prop category: string = 'life'
  @Prop kind: string = 'card'
  onOpen: () => void = () => {}

  build() {
    Column() {
      Image(PavilionMedia.resource(this.coverKey))
        .width('100%')
        .height(148)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 12, topRight: 12 })
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
          .maxLines(2)
          .width('100%')
        Text(this.summary)
          .fontSize(13)
          .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
          .maxLines(2)
          .width('100%')
        Row({ space: 8 }) {
          Text(ArticleItem.labelOf(this.category))
            .fontSize(11)
            .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.brandBox(this.themeEpoch, this.darkModeOn))
            .borderRadius(8)
          Text(this.kindCaption())
            .fontSize(11)
            .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
          Blank()
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.textSub(this.themeEpoch, this.darkModeOn) })
          }
        }
        .width('100%')
      }
      .padding(12)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
    .borderRadius(12)
    .clip(true)
    .onClick((): void => { this.onOpen() })
  }

  private kindCaption(): string {
    if (this.kind === 'list') {
      return '知识清单'
    }
    if (this.kind === 'story') {
      return '趣闻故事'
    }
    if (this.kind === 'quote') {
      return '每日语录'
    }
    return '图文卡片'
  }
}
