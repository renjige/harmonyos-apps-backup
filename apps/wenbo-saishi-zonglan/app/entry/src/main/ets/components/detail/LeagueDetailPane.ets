import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { LeagueItem, MatchItem } from '../../models/MatchModels'
import { SportsBizService } from '../../services/SportsBizService'
import { SportsMedia } from '../../services/SportsMedia'
import { DetailNav } from '../../services/DetailNav'
import { AuthService } from '../../services/AuthService'
import { MatchListCard } from '../sports/MatchListCard'

@Component
export struct LeagueDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onOpenStandings: (leagueName: string) => void = () => {}
  onChanged: () => void = () => {}
  @State item: LeagueItem | undefined = undefined
  @State relatedMatches: MatchItem[] = []
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
    this.item = await SportsBizService.findLeague(this.itemId)
    if (this.item !== undefined) {
      const all = await SportsBizService.loadMatches(this.item.sport, false, '')
      this.relatedMatches = []
      for (const m of all) {
        if (m.leagueName === this.item.title) {
          this.relatedMatches.push(m)
        }
      }
    }
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
      if (fav.targetType === 'league' && fav.targetId === this.itemId) {
        this.favoriteId = fav.id
        break
      }
    }
  }

  private handleOpenStandings(): void {
    if (this.item !== undefined) {
      this.onOpenStandings(this.item.title)
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
    const row = await SportsBizService.createFavorite('league', this.item.id, this.item.title)
    if (row !== undefined) {
      this.favoriteId = row.id
      this.showToast('已关注联赛')
      this.onChanged()
    } else {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '关注失败')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载联赛…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '联赛不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '联赛详情',
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
            Text(`${this.item.sportLabel()} · 联赛`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
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
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '联赛介绍', variant: 'plain' }) {
            Text(this.item.summary.length > 0 ? this.item.summary : this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.description.length > 0 && this.item.description !== this.item.summary) {
          Column({ space: 8 }) {
            Text('赛季说明')
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

        Column({ space: Theme.space.s3 }) {
          Row() {
            AppButton({
              label: '查看积分榜',
              variant: 'secondary',
              onTap: (): void => { this.handleOpenStandings() }
            })
          }
          .width('100%')
          .onClick((): void => { this.handleOpenStandings() })
          AppButton({
            label: this.favoriteId.length > 0 ? '已关注联赛' : '关注联赛',
            variant: this.favoriteId.length > 0 ? 'secondary' : 'primary',
            onTap: (): void => { void this.handleFollow() }
          })
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.relatedMatches.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('相关赛程')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.relatedMatches.slice(0, 5), (row: MatchItem) => {
              MatchListCard({
                item: row,
                compact: true,
                onTap: (): void => { DetailNav.openMatch(row.id) }
              })
            }, (row: MatchItem) => row.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
    }
  }
}
