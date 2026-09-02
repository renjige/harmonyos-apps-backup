import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TeamItem } from '../../models/MatchModels'
import { SportsBizService } from '../../services/SportsBizService'
import { SportsMedia } from '../../services/SportsMedia'
import { DetailNav } from '../../services/DetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct TeamDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State item: TeamItem | undefined = undefined
  @State loading: boolean = true
  @State favoriteId: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
    void this.loadFavoriteState()
  }

  onRefreshChange(): void {
    void this.loadItem()
    void this.loadFavoriteState()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await SportsBizService.findTeam(this.itemId)
    this.loading = false
  }

  private async loadFavoriteState(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.favoriteId = ''
      return
    }
    const list = await SportsBizService.loadFavorites('')
    this.favoriteId = ''
    for (const fav of list) {
      if (fav.targetType === 'team' && fav.targetId === this.itemId) {
        this.favoriteId = fav.id
        break
      }
    }
  }

  private async handleFollow(): Promise<void> {
    if (!AuthService.requireAuth('follow_match')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    if (this.favoriteId.length > 0) {
      const ok = await SportsBizService.removeFavorite(this.favoriteId)
      if (ok) {
        this.favoriteId = ''
        this.showToast('已取消关注')
        this.onChanged()
      } else {
        this.showToast(SportsBizService.lastError.length > 0 ?
          SportsBizService.lastError : '取消关注失败')
      }
      return
    }
    const row = await SportsBizService.createFavorite('team', this.item.id, this.item.title)
    if (row !== undefined) {
      this.favoriteId = row.id
      this.showToast('已关注球队')
      this.onChanged()
    } else {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '关注失败')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载球队…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '球队不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '球队详情',
          onClose: (): void => { DetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_stadium'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 6 }) {
            Text(`${this.item.sportLabel()} · 球队`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            if (this.item.leagueName.length > 0) {
              Text(this.item.leagueName)
                .fontSize(Theme.type.callout)
                .fontColor(Theme.colors().textOnInverse)
            }
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.statsLabel.length > 0 && this.item.statsValue.length > 0) {
          Row({ space: Theme.space.s3 }) {
            Text(this.item.statsLabel)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
            Text(this.item.statsValue)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandAccent)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '球队简介', variant: 'plain' }) {
            Text(this.item.summary.length > 0 ? this.item.summary : this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.description.length > 0 && this.item.description !== this.item.summary) {
          Column({ space: 8 }) {
            Text('详细资料')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }

        Column() {
          AppButton({
            label: this.favoriteId.length > 0 ? '已关注球队' : '关注球队',
            variant: this.favoriteId.length > 0 ? 'secondary' : 'primary',
            onTap: (): void => { void this.handleFollow() }
          })
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
