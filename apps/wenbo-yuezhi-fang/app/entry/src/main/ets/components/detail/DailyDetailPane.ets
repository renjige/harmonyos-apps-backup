import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { DailyItem } from '../../models/AtelierModels'
import { AtelierBizService } from '../../services/AtelierBizService'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'
import { AtelierMedia } from '../../services/AtelierMedia'
import { AtelierProgress } from '../../services/AtelierProgress'
import { AuthService } from '../../services/AuthService'
import { PracticeKind } from '../../models/PracticeModels'

@Component
export struct DailyDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: DailyItem = new DailyItem()
  @State favorited: boolean = false
  @State favId: string = ''
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    AtelierDetailNav.showToast(message)
  }

  private gate(action: string): boolean {
    if (AuthService.requireAuth(action)) {
      return true
    }
    AtelierDetailNav.requestLogin()
    return false
  }

  private async reload(): Promise<void> {
    const found = await AtelierBizService.findDaily(this.itemId)
    if (found === undefined) {
      return
    }
    this.item = found
    this.loaded = true
    await AtelierProgress.addReadMinutes(2)
    const uid = AtelierBizService.userId()
    if (uid.length === 0) {
      this.favorited = false
      this.favId = ''
      return
    }
    const favs = await AtelierBizService.loadFavorites(uid)
    this.favorited = false
    this.favId = ''
    for (const f of favs) {
      if (f.contentId === found.id) {
        this.favorited = true
        this.favId = f.id
      }
    }
  }

  private async toggleFav(): Promise<void> {
    if (!this.gate('favorite')) {
      return
    }
    if (this.favorited && this.favId.length > 0) {
      const ok = await AtelierBizService.removeFavorite(this.favId, this.item.id)
      if (ok) {
        this.favorited = false
        this.favId = ''
        this.showToast('已移出书坊')
        AtelierDetailNav.bumpRefresh()
      } else {
        this.showToast('移出失败，请稍后重试')
      }
      return
    }
    const row = await AtelierBizService.addFavorite(this.item.id, 'daily', this.item.title,
      '每日精选', this.item.coverKey, 'life')
    if (row !== undefined) {
      this.favorited = true
      this.favId = row.id
      this.showToast('已收入书坊，可在「我的书坊」查看')
      AtelierDetailNav.bumpRefresh()
    } else {
      this.showToast('收入书坊失败，请登录后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '每日精选',
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { AtelierDetailNav.close() },
        onFavorite: (): void => { void this.toggleFav() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '今日精选还没写好', description: '请返回后下拉刷新。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(AtelierMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(240)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(240)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,42,108,0)', 0.2], ['rgba(26,42,108,0.86)', 1]]
                  })
                Column({ space: 8 }) {
                  Text(this.item.dateKey)
                    .fontSize(Theme.type.caption)
                    .fontColor('#F8F9FA')
                  Text(this.item.title)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#F8F9FA')
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
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(30)
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
                  label: '做今日功课',
                  onTap: (): void => {
                    AtelierDetailNav.openWorkNew(PracticeKind.ofDaily(this.item.id), this.item.id)
                  }
                })
                AppButton({
                  label: this.favorited ? '移出书坊' : '收入书坊',
                  variant: 'secondary',
                  onTap: (): void => { void this.toggleFav() }
                })
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}
