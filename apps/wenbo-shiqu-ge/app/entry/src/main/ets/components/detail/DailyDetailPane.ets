import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { DailyItem } from '../../models/PavilionModels'
import { PavilionBizService } from '../../services/PavilionBizService'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionMedia } from '../../services/PavilionMedia'
import { PavilionStore } from '../../services/PavilionStore'

@Component
export struct DailyDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: DailyItem = new DailyItem()
  @State favorited: boolean = false
  @State loaded: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const found = await PavilionBizService.findDaily(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
      this.favorited = PavilionStore.isFavorite(`daily:${found.id}`)
      await PavilionStore.markRead(`daily:${found.id}`)
    }
  }

  private async toggleFavorite(): Promise<void> {
    const on = await PavilionStore.toggleFavorite(`daily:${this.item.id}`)
    this.favorited = on
    this.showToast(on ? '已收入收藏夹' : '已取消收藏')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '每日一趣',
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { PavilionDetailNav.close() },
        onFavorite: (): void => { void this.toggleFavorite() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '今日条目还没写好', description: '请返回后下拉刷新。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(PavilionMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(240)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(240)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(61,52,44,0)', 0.2], ['rgba(61,52,44,0.86)', 1]]
                  })
                Column({ space: 8 }) {
                  Text(this.item.dateKey)
                    .fontSize(Theme.type.caption)
                    .fontColor('#F7F4F0')
                  Text(this.item.title)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#F7F4F0')
                    .maxLines(3)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s5 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                Text(this.item.quote)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                  .lineHeight(30)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.item.body)
                .fontSize(Theme.type.bodyL)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              AppButton({
                label: this.favorited ? '取消收藏' : '收藏今日一趣',
                variant: 'primary',
                onTap: (): void => { void this.toggleFavorite() }
              })
                .margin({
                  left: Theme.space.pageX,
                  right: Theme.space.pageX,
                  bottom: Theme.space.s10
                })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
