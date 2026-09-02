import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { WisdomItem } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'
import { WisdomMedia } from '../../services/WisdomMedia'
import { SuzhiLocalStore } from '../../services/SuzhiLocalStore'

@Component
export struct ReadDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: WisdomItem = new WisdomItem()
  @State loaded: boolean = false
  @State toastText: string = ''
  @State favorited: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await WisdomHallBizService.findRead(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
      this.favorited = await SuzhiLocalStore.isFavorite('read', this.itemId)
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async favorite(): Promise<void> {
    if (this.favorited) {
      await SuzhiLocalStore.removeFavorite('read', this.itemId)
      this.favorited = false
      this.showToast('已取消收藏')
      return
    }
    const ok = await SuzhiLocalStore.addFavorite('read', this.itemId, this.item.title)
    if (ok) {
      this.favorited = true
      this.showToast('已加入收藏')
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '文萃详情',
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { WisdomHallNav.closeDetail() },
        onFavorite: (): void => { void this.favorite() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '文萃内容不存在', description: '请返回后刷新重试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(WisdomMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(44,62,80,0)', 0.28], ['rgba(44,62,80,0.78)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.item.category.length > 0 ? this.item.category : '文萃')
                    .fontSize(Theme.type.caption)
                    .fontColor('#C9A96E')
                  Text(this.item.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F5F2ED')
                    .maxLines(3)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                Text(this.item.summaryLine())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(24)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.item.body)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.favorited ? '已收藏' : '收藏此文',
                  variant: 'primary',
                  onTap: (): void => { void this.favorite() }
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s10
              })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
