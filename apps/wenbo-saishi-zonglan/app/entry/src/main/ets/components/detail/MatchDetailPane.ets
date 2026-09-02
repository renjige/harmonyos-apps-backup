import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { MatchItem, TimelineEvent } from '../../models/MatchModels'
import { SportsBizService } from '../../services/SportsBizService'
import { SportsMedia } from '../../services/SportsMedia'
import { DetailNav } from '../../services/DetailNav'
import { AuthService } from '../../services/AuthService'
import { MatchTimeline } from '../sports/MatchTimeline'
import { MatchListCard } from '../sports/MatchListCard'
import { CreateWatchCheckinBody } from '../../models/ViewingModels'

@Component
export struct MatchDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onOpenReminder: (match: MatchItem) => void = () => {}
  onOpenNote: (match: MatchItem) => void = () => {}
  onOpenPlan: (match: MatchItem) => void = () => {}
  onChanged: () => void = () => {}
  @State item: MatchItem | undefined = undefined
  @State loading: boolean = true
  @State favoriteId: string = ''
  @State checkinId: string = ''
  @State toastText: string = ''
  @State timelineEvents: TimelineEvent[] = []
  @State h2hMatches: MatchItem[] = []

  aboutToAppear(): void {
    void this.loadItem()
    void this.loadFavoriteState()
    void this.loadCheckinState()
  }

  onRefreshChange(): void {
    void this.loadItem()
    void this.loadFavoriteState()
    void this.loadCheckinState()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await SportsBizService.findMatch(this.itemId)
    this.timelineEvents = []
    this.h2hMatches = []
    if (this.item !== undefined) {
      this.timelineEvents = TimelineEvent.parseRemark(this.item.remark)
      this.h2hMatches = await SportsBizService.loadHeadToHead(this.item.homeTeam, this.item.awayTeam)
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
      if (fav.targetType === 'match' && fav.targetId === this.itemId) {
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
    const row = await SportsBizService.createFavorite('match', this.item.id, this.item.title)
    if (row !== undefined) {
      this.favoriteId = row.id
      this.showToast('已加入关注')
      this.onChanged()
    } else {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '关注失败')
    }
  }

  private async loadCheckinState(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.checkinId = ''
      return
    }
    const list = await SportsBizService.loadWatchCheckins('')
    this.checkinId = ''
    for (const row of list) {
      if (row.matchId === this.itemId) {
        this.checkinId = row.id
        break
      }
    }
  }

  private async handleCheckin(): Promise<void> {
    if (!AuthService.requireAuth('set_reminder')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    if (this.checkinId.length > 0) {
      this.showToast('已完成观赛打卡')
      return
    }
    const body = new CreateWatchCheckinBody()
    body.matchId = this.item.id
    body.matchTitle = this.item.title
    const plan = await SportsBizService.findActivePlanForMatch(this.item.id)
    if (plan !== undefined) {
      body.planId = plan.id
    }
    const row = await SportsBizService.createWatchCheckin(body)
    if (row !== undefined) {
      this.checkinId = row.id
      this.showToast('观赛打卡成功')
      this.onChanged()
    } else {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '打卡失败')
    }
  }

  private handleNote(): void {
    if (!AuthService.requireAuth('set_reminder')) {
      this.onRequireAuth()
      return
    }
    if (this.item !== undefined) {
      this.onOpenNote(this.item)
    }
  }

  private handlePlan(): void {
    if (!AuthService.requireAuth('set_reminder')) {
      this.onRequireAuth()
      return
    }
    if (this.item !== undefined) {
      this.onOpenPlan(this.item)
    }
  }

  private handleReminder(): void {
    if (!AuthService.requireAuth('set_reminder')) {
      this.onRequireAuth()
      return
    }
    if (this.item !== undefined) {
      this.onOpenReminder(this.item)
    }
  }

  private handleShare(): void {
    if (this.item === undefined) {
      return
    }
    try {
      const text = this.item.shareText()
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.showToast('比赛信息已复制，可粘贴分享')
    } catch {
      this.showToast('分享失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载比赛…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '比赛不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '比赛详情',
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
          if (this.item.coverKey === 'match_football_1') {
            Image($r('app.media.match_football_1'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          } else if (this.item.coverKey === 'match_basketball_1') {
            Image($r('app.media.match_basketball_1'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          } else {
            Column()
              .width('100%')
              .height(200)
              .linearGradient({
                angle: 135,
                colors: [[SportsMedia.mediaResource(this.item.coverKey)[0], 0],
                  [SportsMedia.mediaResource(this.item.coverKey)[1], 1]]
              })
              .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          }
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 6 }) {
            Text(`${this.item.sportLabel()} · ${this.item.statusLabel()}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            if (this.item.homeScore >= 0 && this.item.awayScore >= 0) {
              Text(this.item.scoreText())
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textOnInverse)
            }
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s2 }) {
          Text(this.item.leagueName)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
          Text(this.item.timeLabel())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          if (this.item.venue.length > 0) {
            Text(this.item.venue)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '比赛摘要', variant: 'plain' }) {
            Text(this.item.summary.length > 0 ? this.item.summary : this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.description.length > 0 && this.item.description !== this.item.summary) {
          Column({ space: 8 }) {
            Text('赛事说明')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.body.length > 0 ? this.item.body : this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }

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

        if (this.timelineEvents.length > 0) {
          Column() {
            MatchTimeline({ events: this.timelineEvents })
          }
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.h2hMatches.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('历史交锋')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.h2hMatches, (row: MatchItem) => {
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

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: this.checkinId.length > 0 ? '已打卡' : '观赛打卡',
            variant: this.checkinId.length > 0 ? 'secondary' : 'primary',
            onTap: (): void => { void this.handleCheckin() }
          }).layoutWeight(1)
          AppButton({
            label: '写笔记',
            variant: 'secondary',
            onTap: (): void => { this.handleNote() }
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: this.favoriteId.length > 0 ? '已关注' : '关注比赛',
            variant: this.favoriteId.length > 0 ? 'secondary' : 'primary',
            onTap: (): void => { void this.handleFollow() }
          }).layoutWeight(1)
          AppButton({
            label: '加入计划',
            variant: 'secondary',
            onTap: (): void => { this.handlePlan() }
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '设置提醒',
            variant: 'secondary',
            onTap: (): void => { this.handleReminder() }
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '复制分享',
            variant: 'secondary',
            onTap: (): void => { this.handleShare() }
          })
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
