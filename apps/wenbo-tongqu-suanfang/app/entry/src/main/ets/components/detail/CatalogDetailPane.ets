import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CatalogItem } from '../../models/MathModels'
import { MathMedia } from '../../services/MathMedia'

@Component
export struct CatalogDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CatalogItem = new CatalogItem()
  @Prop ctaLabel: string = '开始练习'
  onClose: () => void = () => {}
  onAction: () => void = () => {}

  build() {
    DetailShell({
      title: this.item.title,
      onClose: () => this.onClose()
    }) {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(MathMedia.resource(this.item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(120)
            .linearGradient({
              angle: 180,
              colors: [['rgba(23,32,51,0)', 0], ['rgba(23,32,51,0.72)', 1]]
            })
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s4 })
        }
        .width('100%')
        .height(220)
        .borderRadius(Theme.radius.xl)
        .clip(true)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        if (this.item.subtitle.length > 0) {
          Text(this.item.subtitle)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            .width('100%')
        }

        Column({ space: Theme.space.s2 }) {
          Text('简介')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(this.item.summary.length > 0 ? this.item.summary : this.item.subtitle)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(24)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .width('100%')

        Column() {
          AppButton({ label: this.ctaLabel, onTap: () => this.onAction() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      }
      .width('100%')
    }
  }
}
