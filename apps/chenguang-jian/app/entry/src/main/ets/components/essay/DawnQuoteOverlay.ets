import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DawnMedia } from '../../services/DawnMedia'
import { EssayDateUtil } from '../../services/EssayDateUtil'
import { EssayNav } from '../../services/EssayNav'
import { EssayStore } from '../../services/EssayStore'

@Component
export struct DawnQuoteOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop quoteId: string = ''
  @Prop quoteTitle: string = ''
  @Prop quoteBody: string = ''
  onClose: () => void = () => {}
  @State toastText: string = ''

  private async fav(): Promise<void> {
    const on = await EssayStore.toggleFav(this.quoteId, this.quoteTitle, this.quoteBody)
    this.toastText = on ? '已收藏这句晨语' : '已取消收藏'
    setTimeout(() => { this.toastText = '' }, 1800)
  }

  private async dismiss(): Promise<void> {
    await EssayStore.markQuoteShown(EssayDateUtil.todayIso())
    this.onClose()
  }

  build() {
    Stack() {
      Column() {
        Image(DawnMedia.cover('banner_gold_beam'))
          .width('100%')
          .layoutWeight(1)
          .objectFit(ImageFit.Cover)
        Column({ space: Theme.space.s4 }) {
          Text('今日晨语')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(this.quoteTitle)
            .fontSize(Theme.type.title1)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.quoteBody)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '收藏',
            variant: 'secondary',
            onTap: (): void => { void this.fav() }
          })
          AppButton({
            label: '开始书写',
            onTap: (): void => {
              void this.dismiss()
              EssayNav.openWrite('')
            }
          })
          Text('稍后再看')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding(10)
            .onClick((): void => { void this.dismiss() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: Theme.space.s8 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
