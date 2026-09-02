import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RelicView } from '../../models/KingdomModels'
import { KingdomMedia } from '../../services/KingdomMedia'
import { KingdomDetailNav } from '../../services/KingdomDetailNav'

@Component
export struct CollectionOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop relics: RelicView[] = []
  onClose: () => void = () => {}

  private openRelic(item: RelicView): void {
    KingdomDetailNav.open('relic', item.id, '知道了')
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.onClose())
        Text('王国收藏馆')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.pageX, top: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('闯关点亮藏品。新探索者开始时这里是空的。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.relics, (item: RelicView) => {
            Row({ space: Theme.space.s4 }) {
              Image(KingdomMedia.resource(item.coverKey))
                .width(72)
                .height(72)
                .borderRadius(16)
                .objectFit(ImageFit.Cover)
                .opacity(item.unlocked ? 1 : 0.4)
              Column({ space: 4 }) {
                Text(item.unlocked ? item.title : '尚未点亮')
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(item.unlocked ? item.summary : item.rule)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .borderRadius(20)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .onClick(() => this.openRelic(item))
          }, (item: RelicView) => item.id)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
