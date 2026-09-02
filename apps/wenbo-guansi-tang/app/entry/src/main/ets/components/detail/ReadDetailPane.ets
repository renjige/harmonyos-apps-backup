import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { SymbolHero } from '../design-system/SymbolVisual'
import { WisdomItem } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'
import { AuthService } from '../../services/AuthService'

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
      if (AuthService.isLoggedIn()) {
        void WisdomHallBizService.recordHistory('read', this.itemId, this.item.title)
      }
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async favorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    const ok = await WisdomHallBizService.addFavorite('read', this.itemId, this.item.title)
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
        title: '推荐阅读',
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { WisdomHallNav.closeDetail() },
        onFavorite: (): void => { void this.favorite() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '荐读内容不存在', description: '请返回后刷新重试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              SymbolHero({
                category: this.item.category.length > 0 ? this.item.category : '阅读',
                coverKey: this.item.coverKey,
                bannerHeight: 220,
                overline: this.item.category.length > 0 ? this.item.category : '阅读',
                title: this.item.title
              })
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
                  label: this.favorited ? '已收藏' : '收藏荐读',
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
