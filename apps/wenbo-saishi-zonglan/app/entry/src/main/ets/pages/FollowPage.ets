import { Theme, ThemeColors } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { MatchListCard } from '../components/sports/MatchListCard'
import { FavoriteItem, MatchItem, ReminderItem } from '../models/MatchModels'
import { ViewingPlanItem, ViewingNoteItem, WatchCheckinItem, ActivityFeedItem } from '../models/ViewingModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

class FavoriteGroup {
  label: string = ''
  items: FavoriteItem[] = []
}

class TeamScheduleBlock {
  teamTitle: string = ''
  matches: MatchItem[] = []
}

@Component
export struct FollowPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @StorageLink('accessToken') accessToken: string = ''
  @State segment: number = 0
  @State items: FavoriteItem[] = []
  @State groups: FavoriteGroup[] = []
  @State reminders: ReminderItem[] = []
  @State teamSchedules: TeamScheduleBlock[] = []
  @State todayWatch: MatchItem[] = []
  @State plans: ViewingPlanItem[] = []
  @State notes: ViewingNoteItem[] = []
  @State checkins: WatchCheckinItem[] = []
  @State feed: ActivityFeedItem[] = []
  @State loading: boolean = true
  @State toastText: string = ''

  private palette(): ThemeColors {
    return Theme.palette(this.themeColorMode === 'dark')
  }

  private sportTag(row: ReminderItem): string {
    if (row.sport === 'football') {
      return '足球'
    }
    if (row.sport === 'basketball') {
      return '篮球'
    }
    if (row.sport === 'tennis') {
      return '网球'
    }
    if (row.sport === 'esports') {
      return '电竞'
    }
    return '比赛'
  }

  private matchStatusLabel(row: ReminderItem): string {
    if (row.matchStatus === 'live') {
      return '进行中'
    }
    if (row.matchStatus === 'finished') {
      return '已结束'
    }
    return '未开始'
  }

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private buildGroups(list: FavoriteItem[]): FavoriteGroup[] {
    const labels: string[] = ['比赛', '球队', '联赛', '关注']
    const out: FavoriteGroup[] = []
    for (const label of labels) {
      const group = new FavoriteGroup()
      group.label = label
      for (const row of list) {
        if (row.groupLabel() === label) {
          group.items.push(row)
        }
      }
      if (group.items.length > 0) {
        out.push(group)
      }
    }
    return out
  }

  private async loadTeamSchedules(favorites: FavoriteItem[]): Promise<TeamScheduleBlock[]> {
    const out: TeamScheduleBlock[] = []
    for (const fav of favorites) {
      if (fav.targetType !== 'team') {
        continue
      }
      const block = new TeamScheduleBlock()
      block.teamTitle = fav.targetTitle
      block.matches = await SportsBizService.loadTeamUpcoming(fav.targetTitle, 3)
      if (block.matches.length > 0) {
        out.push(block)
      }
    }
    return out
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!this.isLoggedIn()) {
      this.items = []
      this.groups = []
      this.reminders = []
      this.teamSchedules = []
      this.todayWatch = []
      this.plans = []
      this.notes = []
      this.checkins = []
      this.feed = []
      this.loading = false
      return
    }
    this.items = await SportsBizService.loadFavorites('')
    this.groups = this.buildGroups(this.items)
    this.reminders = await SportsBizService.loadReminders('')
    this.teamSchedules = await this.loadTeamSchedules(this.items)
    this.todayWatch = await SportsBizService.loadTodayWatchList()
    this.plans = await SportsBizService.loadViewingPlans('')
    this.notes = await SportsBizService.loadViewingNotes('')
    this.checkins = await SportsBizService.loadWatchCheckins('')
    this.feed = await SportsBizService.loadActivityFeed('', 30)
    this.loading = false
  }

  private openFavorite(row: FavoriteItem): void {
    if (row.targetType === 'match') {
      DetailNav.openMatch(row.targetId)
    } else if (row.targetType === 'team') {
      DetailNav.openTeam(row.targetId)
    } else if (row.targetType === 'league') {
      DetailNav.openLeague(row.targetId)
    }
  }

  private async cancelReminder(id: string): Promise<void> {
    const ok = await SportsBizService.removeReminder(id)
    if (ok) {
      this.showToast('已取消提醒')
      void this.reload()
    } else {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '取消失败')
    }
  }

  @Builder
  SegmentBar() {
    Row({ space: Theme.space.s2 }) {
      ForEach(['今日待看', '我的计划', '笔记打卡', '关注提醒', '动态'], (label: string, index: number) => {
        Text(label)
          .fontSize(Theme.type.caption)
          .fontColor(this.segment === index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.segment === index ?
            Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.segment = index })
      }, (label: string, index: number) => `${label}_${index}`)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '我的观赛', subtitle: '计划 · 打卡 · 关注 · 动态' })
        if (!this.isLoggedIn()) {
          Column({ space: Theme.space.s4 }) {
            AppEmpty({
              title: '登录后使用观赛助手',
              description: '可关注球队、设置开赛前提醒、查看关注球队赛程'
            })
            AppButton({
              label: '登录 / 注册',
              onTap: (): void => { this.onRequireAuth() }
            })
          }
          .layoutWeight(1)
          .padding(Theme.space.pageX)
          .justifyContent(FlexAlign.Center)
        } else if (this.loading) {
          AppLoading({ label: '加载观赛数据…' }).layoutWeight(1)
        } else {
          this.SegmentBar()
          if (this.segment === 0) {
            if (this.todayWatch.length === 0) {
              AppEmpty({
                title: '今日暂无待看',
                description: '设置提醒或加入观赛计划后，这里会汇总今日赛程'
              }).layoutWeight(1)
            } else {
              Scroll() {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.todayWatch, (m: MatchItem) => {
                    MatchListCard({
                      item: m,
                      onTap: (): void => { DetailNav.openMatch(m.id) }
                    })
                  }, (m: MatchItem) => m.id)
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s10 })
                .width('100%')
              }
              .layoutWeight(1)
              .scrollBar(BarState.Off)
            }
          } else if (this.segment === 1) {
            if (this.plans.length === 0) {
              AppEmpty({
                title: '暂无观赛计划',
                description: '在首页或比赛详情创建个人观赛计划'
              }).layoutWeight(1)
            } else {
              Scroll() {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.plans, (p: ViewingPlanItem) => {
                    Column({ space: 4 }) {
                      Text(p.title)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.palette().textPrimary)
                        .width('100%')
                      Text(`${p.progressLabel()} · ${p.status === 'completed' ? '已完成' : '进行中'}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.palette().textSecondary)
                        .width('100%')
                    }
                    .width('100%')
                    .padding(Theme.space.s4)
                    .backgroundColor(this.palette().surfaceCard)
                    .borderRadius(Theme.radius.xl)
                    .border({ width: 1, color: this.palette().strokeHairline })
                  }, (p: ViewingPlanItem) => p.id)
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s10 })
                .width('100%')
              }
              .layoutWeight(1)
              .scrollBar(BarState.Off)
            }
          } else if (this.segment === 2) {
            if (this.notes.length === 0 && this.checkins.length === 0) {
              AppEmpty({
                title: '暂无笔记与打卡',
                description: '在比赛详情页完成观赛打卡或写笔记'
              }).layoutWeight(1)
            } else {
              Scroll() {
                Column({ space: Theme.space.s4 }) {
                  if (this.checkins.length > 0) {
                    Text('观赛打卡')
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.palette().textPrimary)
                      .width('100%')
                    ForEach(this.checkins, (c: WatchCheckinItem) => {
                      Row() {
                        Column({ space: 4 }) {
                          Text(c.matchTitle)
                            .fontSize(Theme.type.subhead)
                            .fontColor(this.palette().textPrimary)
                          Text(c.watchedAt.slice(0, 16).replace('T', ' '))
                            .fontSize(Theme.type.caption)
                            .fontColor(this.palette().textSecondary)
                        }
                        .layoutWeight(1)
                        .alignItems(HorizontalAlign.Start)
                      }
                      .width('100%')
                      .padding(Theme.space.s4)
                      .backgroundColor(this.palette().surfaceCard)
                      .borderRadius(Theme.radius.xl)
                      .onClick((): void => { DetailNav.openMatch(c.matchId) })
                    }, (c: WatchCheckinItem) => c.id)
                  }
                  if (this.notes.length > 0) {
                    Text('观赛笔记')
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.palette().textPrimary)
                      .width('100%')
                    ForEach(this.notes, (n: ViewingNoteItem) => {
                      Column({ space: 4 }) {
                        Text(n.matchTitle)
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.palette().textPrimary)
                          .width('100%')
                        Text(n.summary)
                          .fontSize(Theme.type.caption)
                          .fontColor(this.palette().textSecondary)
                          .width('100%')
                          .maxLines(3)
                      }
                      .width('100%')
                      .padding(Theme.space.s4)
                      .backgroundColor(this.palette().surfaceCard)
                      .borderRadius(Theme.radius.xl)
                      .onClick((): void => { DetailNav.openMatch(n.matchId) })
                    }, (n: ViewingNoteItem) => n.id)
                  }
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s10 })
                .width('100%')
              }
              .layoutWeight(1)
              .scrollBar(BarState.Off)
            }
          } else if (this.segment === 3) {
            Scroll() {
              Column({ space: Theme.space.s4 }) {
                if (this.items.length === 0 && this.reminders.length === 0 && this.teamSchedules.length === 0) {
                  AppEmpty({
                    title: '暂无关注与提醒',
                    description: '在比赛/球队详情页关注，或设置开赛前提醒'
                  })
                } else {
                  if (this.reminders.length > 0) {
                    Text('观赛提醒')
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.palette().textPrimary)
                      .width('100%')
                    ForEach(this.reminders, (row: ReminderItem) => {
                      Column({ space: Theme.space.s2 }) {
                        Text(row.displayTitle())
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.palette().textPrimary)
                          .width('100%')
                        Text(`开球 ${row.kickoffLabel()} · ${row.remindLabel()}`)
                          .fontSize(Theme.type.caption)
                          .fontColor(this.palette().textSecondary)
                          .width('100%')
                        AppButton({
                          label: '取消提醒',
                          variant: 'secondary',
                          onTap: (): void => { void this.cancelReminder(row.id) }
                        })
                      }
                      .width('100%')
                      .padding(Theme.space.s4)
                      .backgroundColor(this.palette().surfaceCard)
                      .borderRadius(Theme.radius.xl)
                      .onClick((): void => {
                        if (row.targetId.length > 0) {
                          DetailNav.openMatch(row.targetId)
                        }
                      })
                    }, (row: ReminderItem) => row.id)
                  }
                  if (this.items.length > 0) {
                    Text('我的关注')
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.palette().textPrimary)
                      .width('100%')
                    ForEach(this.groups, (group: FavoriteGroup) => {
                      ForEach(group.items, (row: FavoriteItem) => {
                        Row() {
                          Text(row.targetTitle)
                            .fontSize(Theme.type.subhead)
                            .fontColor(this.palette().textPrimary)
                            .layoutWeight(1)
                        }
                        .width('100%')
                        .padding(Theme.space.s4)
                        .backgroundColor(this.palette().surfaceCard)
                        .borderRadius(Theme.radius.xl)
                        .onClick((): void => { this.openFavorite(row) })
                      }, (row: FavoriteItem) => row.id)
                    }, (group: FavoriteGroup) => group.label)
                  }
                  if (this.teamSchedules.length > 0) {
                    Text('球队赛程')
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.palette().textPrimary)
                      .width('100%')
                    ForEach(this.teamSchedules, (block: TeamScheduleBlock) => {
                      Column({ space: Theme.space.s2 }) {
                        Text(block.teamTitle)
                          .fontSize(Theme.type.subhead)
                          .fontColor(this.palette().textPrimary)
                          .width('100%')
                        ForEach(block.matches, (m: MatchItem) => {
                          MatchListCard({
                            item: m,
                            compact: true,
                            onTap: (): void => { DetailNav.openMatch(m.id) }
                          })
                        }, (m: MatchItem) => `${block.teamTitle}_${m.id}`)
                      }
                      .width('100%')
                    }, (block: TeamScheduleBlock) => block.teamTitle)
                  }
                }
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s10 })
              .width('100%')
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          } else {
            if (this.feed.length === 0) {
              AppEmpty({
                title: '暂无观赛动态',
                description: '打卡、写笔记或创建计划后，这里会记录你的观赛轨迹'
              }).layoutWeight(1)
            } else {
              Scroll() {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.feed, (row: ActivityFeedItem) => {
                    Column({ space: 4 }) {
                      Row({ space: Theme.space.s2 }) {
                        Text(row.typeLabel())
                          .fontSize(Theme.type.caption)
                          .fontColor(this.palette().brandOnPrimary)
                          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                          .backgroundColor(this.palette().brandPrimary)
                          .borderRadius(Theme.radius.pill)
                        Text(row.timeLabel())
                          .fontSize(Theme.type.caption)
                          .fontColor(this.palette().textTertiary)
                      }
                      Text(row.title)
                        .fontSize(Theme.type.subhead)
                        .fontColor(this.palette().textPrimary)
                        .width('100%')
                      Text(row.subtitle)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.palette().textSecondary)
                        .width('100%')
                    }
                    .width('100%')
                    .padding(Theme.space.s4)
                    .backgroundColor(this.palette().surfaceCard)
                    .borderRadius(Theme.radius.xl)
                    .onClick((): void => {
                      if (row.targetId.length > 0 && row.type !== 'plan') {
                        DetailNav.openMatch(row.targetId)
                      }
                    })
                  }, (row: ActivityFeedItem) => row.id)
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s10 })
                .width('100%')
              }
              .layoutWeight(1)
              .scrollBar(BarState.Off)
            }
          }
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.palette().surfacePage)

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
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
