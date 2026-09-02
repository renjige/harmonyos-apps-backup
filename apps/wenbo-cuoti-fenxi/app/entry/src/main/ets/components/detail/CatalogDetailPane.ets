import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { WrongMedia } from '../../services/WrongMedia'
import { CatalogItem } from '../../models/WrongModels'

@Component
export struct CatalogDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CatalogItem = new CatalogItem()
  @Prop ctaLabel: string = '去录入错题'
  onClose: () => void = () => {}
  onCta: () => void = () => {}

  build() {
    DetailShell({ title: this.item.title, onClose: () => this.onClose() }) {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(WrongMedia.resource(this.item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(11,31,74,0.08)', 0], ['rgba(11,31,74,0.72)', 1]]
            })
          Column({ space: 6 }) {
            if (this.item.subtitle.length > 0) {
              Text(this.item.subtitle)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
            }
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
        }
        .width('100%')
        .borderRadius(Theme.radius.md)
        .clip(true)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        Column({ space: Theme.space.s3 }) {
          AppCard({ title: '摘要' }) {
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          AppCard({ title: '说明' }) {
            Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          AppButton({
            label: this.ctaLabel,
            onTap: () => this.onCta()
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
    }
  }
}
