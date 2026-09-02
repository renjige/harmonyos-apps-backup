import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ArtworkItem } from '../../models/KagModels'
import { KagMedia } from '../../services/KagMedia'
import { KagNav } from '../../services/KagNav'
import { DetailShell } from './DetailShell'

@Component
export struct SharePosterOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ArtworkItem = new ArtworkItem()

  build() {
    DetailShell({
      title: '分享海报',
      onBack: () => KagNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 12 }) {
            if (this.item.imageFile.length > 0) {
              Image(this.item.imageFile)
                .width('100%')
                .height(280)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
            } else {
              Image(KagMedia.cover(this.item.coverKey))
                .width('100%')
                .height(280)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
            }
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`${this.item.createdOn}  ${this.item.ageLabel}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.story.length > 0 ? this.item.story : '珍藏于少儿画苑')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('少儿画苑')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandDeep)
              .width('100%')
              .textAlign(TextAlign.End)
          }
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({ radius: 18, color: 'rgba(45,32,24,0.12)', offsetY: 8 })

          Text('可截图发给亲友。本应用不接入支付，也不跳转外部小程序。')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '完成',
            variant: 'primary',
            onTap: () => KagNav.close()
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
    }
  }
}
