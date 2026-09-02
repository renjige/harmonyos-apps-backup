import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { DailyItem } from '../models/AtelierModels'
import { AtelierBizService } from '../services/AtelierBizService'
import { AtelierDetailNav } from '../services/AtelierDetailNav'
import { AtelierMedia } from '../services/AtelierMedia'
import { AuthService } from '../services/AuthService'
import { PracticeKind } from '../models/PracticeModels'
import { AtelierPractice } from '../services/AtelierPractice'

@Component
export struct DailyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State today: DailyItem = AtelierBizService.pickToday(AtelierBizService.packDaily())
  @State list: DailyItem[] = AtelierBizService.packDaily()
  @State hasToday: boolean = true
  @State favorited: boolean = false
  @State favId: string = ''

  aboutToAppear(): void {
    this.list = AtelierBizService.packDaily()
    this.today = AtelierBizService.pickToday(this.list)
    this.hasToday = this.today.id.length > 0
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    AtelierDetailNav.showToast(message)
  }

  private async reload(): Promise<void> {
    if (this.list.length === 0) {
      this.list = AtelierBizService.packDaily()
      this.today = AtelierBizService.pickToday(this.list)
      this.hasToday = this.today.id.length > 0
    }
    const days = await AtelierBizService.loadDaily()
    if (days.length > 0) {
      this.list = days
      this.today = AtelierBizService.pickToday(days)
      this.hasToday = this.today.id.length > 0
    }
    this.favorited = false
    this.favId = ''
    const uid = AtelierBizService.userId()
    if (this.hasToday && uid.length > 0) {
      const favs = await AtelierBizService.loadFavorites(uid)
      for (const f of favs) {
        if (f.contentId === this.today.id) {
          this.favorited = true
          this.favId = f.id
        }
      }
    }
  }

  private async toggleFavorite(): Promise<void> {
    if (!this.hasToday) {
      return
    }
    if (!AuthService.requireAuth('favorite')) {
      AtelierDetailNav.requestLogin()
      return
    }
    if (this.favorited && this.favId.length > 0) {
      const ok = await AtelierBizService.removeFavorite(this.favId, this.today.id)
      if (ok) {
        this.favorited = false
        this.favId = ''
        this.showToast('已移出书坊')
        AtelierDetailNav.bumpRefresh()
      }
      return
    }
    const row = await AtelierBizService.addFavorite(this.today.id, 'daily', this.today.title,
      '每日精选', this.today.coverKey, 'life')
    if (row !== undefined) {
      this.favorited = true
      this.favId = row.id
      this.showToast('已收入书坊')
      AtelierDetailNav.bumpRefresh()
    } else {
      this.showToast('收入书坊失败，请登录后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Column({ space: 2 }) {
            Text('每日工坊')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('官方精选短读，练一页课业；不含用户发帖')
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Column() {
            AppIcon({ name: 'sparkle', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { AtelierDetailNav.openHot() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        if (!this.hasToday) {
          AppEmpty({
            title: '还没有每日精选',
            description: '请检查网络后重试，或先去发现页读一篇知识卡。',
            actionLabel: '重新加载',
            onAction: (): void => { void this.reload() }
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.banner_plaza'))
                .width('100%')
                .height(100)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)

              Stack({ alignContent: Alignment.BottomStart }) {
                Image(AtelierMedia.resource(this.today.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,42,108,0)', 0.15], ['rgba(26,42,108,0.82)', 1]]
                  })
                Column({ space: 8 }) {
                  Text(this.today.dateKey.length > 0 ? this.today.dateKey : '今日精选')
                    .fontSize(13)
                    .fontColor('#F8F9FA')
                  Text(this.today.title)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#F8F9FA')
                    .maxLines(3)
                }
                .padding(16)
              }
              .width('100%')
              .borderRadius(12)
              .clip(true)
              .onClick((): void => { AtelierDetailNav.openDaily(this.today.id) })

              Text(this.today.quote)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28)
                .width('100%')

              AppButton({
                label: '阅读全文',
                onTap: (): void => { AtelierDetailNav.openDaily(this.today.id) }
              })
              AppButton({
                label: '做今日功课',
                onTap: (): void => {
                  AtelierDetailNav.openWorkNew(PracticeKind.ofDaily(this.today.id), this.today.id)
                }
              })
              AppButton({
                label: '专注计时',
                variant: 'secondary',
                onTap: (): void => { AtelierDetailNav.openTimer() }
              })
              AppButton({
                label: this.favorited ? '已收入书坊' : '收入书坊',
                variant: 'secondary',
                onTap: (): void => { void this.toggleFavorite() }
              })
              if (AtelierPractice.count() > 0) {
                Text(`本机已有 ${AtelierPractice.count()} 页课业`)
                  .fontSize(13)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .onClick((): void => { AtelierDetailNav.openWorkList() })
              }

              Text('往期精选')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .margin({ top: Theme.space.s2 })

              ForEach(this.list, (row: DailyItem) => {
                Row() {
                  Text(row.dateKey)
                    .fontSize(13)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width(96)
                  Text(row.title)
                    .fontSize(16)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                    .layoutWeight(1)
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(8)
                .onClick((): void => { AtelierDetailNav.openDaily(row.id) })
              }, (row: DailyItem) => row.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
  }
}
