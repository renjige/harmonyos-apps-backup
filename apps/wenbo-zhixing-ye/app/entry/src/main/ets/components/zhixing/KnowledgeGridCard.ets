import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { KnowledgeItem } from '../../models/ZhixingModels'
import { ZhixingMedia } from '../../services/ZhixingMedia'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct KnowledgeGridCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: KnowledgeItem = new KnowledgeItem()
  onOpen: () => void = () => {}
  @State private pressed: boolean = false

  build() {
    Column({ space: 8 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(ZhixingMedia.image(this.item.coverKey))
          .width('100%')
          .height(110)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(40)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,42,108,0)', 0], ['rgba(26,42,108,0.72)', 1]]
          })
      }
      .width('100%')
      .height(110)
      .borderRadius(12)
      .clip(true)

      Text(this.item.title.length > 0 ? this.item.title : '未命名')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Text(this.item.preview())
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Row({ space: 4 }) {
        Text(CategoryEmojiUtil.chipLabel(this.item.kindLabel()))
          .fontSize(10)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Blank()
        if (this.item.favorite) {
          AppIcon({ name: 'heart', iconSize: 14, color: Theme.colors().brandAccent })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(10)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .scale({ x: this.pressed ? 0.95 : 1, y: this.pressed ? 0.95 : 1 })
    .animation({ duration: Theme.motion.instant, curve: Curve.EaseOut })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) {
        this.pressed = true
      }
      if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
        this.pressed = false
      }
    })
    .onClick((): void => { this.onOpen() })
  }
}
