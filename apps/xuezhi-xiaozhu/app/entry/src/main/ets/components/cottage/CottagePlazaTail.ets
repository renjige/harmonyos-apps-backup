import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CottageItem } from '../../models/CottageModels'
import { CottageMedia } from '../../services/CottageMedia'
import { CottageNav } from '../../services/CottageNav'

@Component
export struct CottagePlazaTail {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop cards: CottageItem[] = []

  build() {
    Column({ space: Theme.space.s5 }) {
      if (this.cards.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('今日知识卡片')
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('全部')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { CottageNav.switchTab(1) })
          }
          .width('100%')
          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.cards.slice(0, 6), (c: CottageItem) => {
                Column() {
                  Image(CottageMedia.resource(c.coverKey))
                    .width(148)
                    .height(96)
                    .borderRadius(Theme.radius.md)
                    .objectFit(ImageFit.Cover)
                  Text(c.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .width(148)
                    .margin({ top: 8 })
                }
                .onClick((): void => { CottageNav.openCard(c.id) })
              }, (c: CottageItem) => c.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
        }
        .width('100%')
      }

      Column({ space: Theme.space.s3 }) {
        Text('还不确定从哪条路开始？')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        AppButton({
          label: '开始学习匹配',
          onTap: (): void => { CottageNav.openDiagnose() }
        })
        AppButton({
          label: '智慧问答（仅供参考）',
          variant: 'secondary',
          onTap: (): void => { CottageNav.openQa() }
        })
      }
      .width('100%')
    }
    .width('100%')
  }
}
