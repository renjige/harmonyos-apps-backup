import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { CourtyardMedia } from '../../services/CourtyardMedia'
import { CourtyardBizService } from '../../services/CourtyardBizService'
import { CourtyardDetailNav } from '../../services/CourtyardDetailNav'
import { CourtyardLocalStore } from '../../services/CourtyardLocalStore'
import { PoemItem } from '../../models/CourtyardModels'
import { DetailShell } from './DetailShell'

@Component
export struct PoemDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop poemId: string = ''
  @State item: PoemItem = new PoemItem()
  @State fav: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const row = await CourtyardBizService.findPoem(this.poemId)
    if (row !== undefined) {
      this.item = row
      this.fav = CourtyardLocalStore.isFav(row.id)
      await CourtyardLocalStore.markRead(row.id)
    }
  }

  private async toggleFav(): Promise<void> {
    this.fav = await CourtyardLocalStore.toggleFav(this.item.id)
    this.toastText = this.fav ? '已收藏到小院' : '已取消收藏'
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  build() {
    Stack() {
      DetailShell({
        title: this.item.title.length > 0 ? this.item.title : '诗词',
        onClose: (): void => { this.onClose() }
      }) {
        Column({ space: Theme.space.s4 }) {
          Stack() {
            Image(CourtyardMedia.cover(this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_courtyard'))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column() {
              Text(this.item.metaLine())
                .fontSize(Theme.type.caption)
                .fontColor('#F5F0E8')
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(44,24,16,0)', 0], ['rgba(44,24,16,0.88)', 1]]
            })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignContent(Alignment.BottomStart)
          .clip(true)
          .borderRadius(Theme.radius.md)

          Column({ space: Theme.space.s4 }) {
            Text(this.item.body)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(28)
              .width('100%')

            AppCard({ title: '智慧笺注' }) {
              Text(this.item.annotation.length > 0 ? this.item.annotation : '本篇笺注待补。')
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            AppCard({ title: '白话译诗' }) {
              Text(this.item.translation.length > 0 ? this.item.translation : '暂无译文。')
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            AppCard({ title: '背景解读' }) {
              Text(this.item.background.length > 0 ? this.item.background : '创作背景待考。')
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            AppCard({ title: '名家评点' }) {
              Text(this.item.comments.length > 0 ? this.item.comments : '评点收录中。')
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            AppCard({ title: '赏析' }) {
              Text(this.item.appreciation.length > 0 ? this.item.appreciation : this.item.summary)
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            AppButton({
              label: this.fav ? '取消收藏' : '收藏本篇',
              variant: 'secondary',
              onTap: (): void => { void this.toggleFav() }
            })
            AppButton({
              label: '去做格律检测',
              onTap: (): void => { CourtyardDetailNav.openMeterWithText(this.item.body) }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .width('100%')
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('rgba(44,24,16,0.92)')
          .borderRadius(Theme.radius.sm)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
