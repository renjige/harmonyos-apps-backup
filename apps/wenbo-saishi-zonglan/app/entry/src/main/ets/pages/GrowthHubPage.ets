import { Theme, ThemeColors } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { SportsBizService } from '../services/SportsBizService'
import { ActivityFeedItem, UserStatsPayload, ViewingPlanItem } from '../models/ViewingModels'
import { DetailNav } from '../services/DetailNav'

class AchievementItem {
  id: string = ''
  title: string = ''
  desc: string = ''
  unlocked: boolean = false
}

@Component
export struct GrowthHubPage {
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @StorageLink('accessToken') accessToken: string = ''
  @State loading: boolean = true
  @State stats: UserStatsPayload = new UserStatsPayload()
  @State feed: ActivityFeedItem[] = []
  @State plans: ViewingPlanItem[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private palette(): ThemeColors {
    return Theme.palette(this.themeColorMode === 'dark')
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private achievements(): AchievementItem[] {
    const out: AchievementItem[] = []
    const a1 = new AchievementItem()
    a1.id = 'first_watch'
    a1.title = '首次观赛'
    a1.desc = '完成第一次观赛打卡'
    a1.unlocked = this.stats.watchedCount >= 1
    out.push(a1)
    const a2 = new AchievementItem()
    a2.id = 'streak_3'
    a2.title = '连续 3 天'
    a2.desc = '连续 3 天有观赛记录'
    a2.unlocked = this.stats.watchStreakDays >= 3
    out.push(a2)
    const a3 = new AchievementItem()
    a3.id = 'notes_5'
    a3.title = '笔记达人'
    a3.desc = '累计 5 篇观赛笔记'
    a3.unlocked = this.stats.noteCount >= 5
    out.push(a3)
    const a4 = new AchievementItem()
    a4.id = 'plan_done'
    a4.title = '计划完成'
    a4.desc = '完成一个观赛计划'
    a4.unlocked = this.stats.planCompletedCount >= this.stats.planTargetCount &&
      this.stats.planTargetCount > 0
    out.push(a4)
    return out
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!this.isLoggedIn()) {
      this.loading = false
      return
    }
    const s = await SportsBizService.loadUserStats('')
    if (s !== undefined) {
      this.stats = s
    }
    this.feed = await SportsBizService.loadActivityFeed('', 20)
    this.plans = await SportsBizService.loadViewingPlans('')
    this.loading = false
  }

  @Builder
  StatCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.palette().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.palette().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.palette().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: this.palette().strokeHairline })
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          Text('‹')
            .fontSize(24)
            .fontColor(this.palette().textPrimary)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        AppHeader({ title: '观赛成长', subtitle: '统计 · 成就 · 回顾' })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      if (!this.isLoggedIn()) {
        AppEmpty({
          title: '登录后查看成长数据',
          description: '打卡、笔记与计划会在这里汇总'
        }).layoutWeight(1)
      } else if (this.loading) {
        AppLoading({ label: '加载数据…' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: Theme.space.s2 }) {
              this.StatCard('已观看', `${this.stats.watchedCount}`)
              this.StatCard('笔记', `${this.stats.noteCount}`)
            }
            .width('100%')
            Row({ space: Theme.space.s2 }) {
              this.StatCard('连续天', `${this.stats.watchStreakDays}`)
              this.StatCard('关注', `${this.stats.favoriteCount}`)
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('本周回顾')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.palette().textPrimary)
                .width('100%')
              Text(`本月你已观看 ${this.stats.watchedCount} 场比赛，写下 ${this.stats.noteCount} 篇笔记，`
                + `活跃计划 ${this.stats.activePlanCount} 个。`
                + (this.stats.planTargetCount > 0 ?
                  ` 计划进度 ${this.stats.planCompletedCount}/${this.stats.planTargetCount} 场。` : ''))
                .fontSize(Theme.type.body)
                .fontColor(this.palette().textSecondary)
                .width('100%')
                .lineHeight(22)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.palette().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: this.palette().strokeHairline })

            Column({ space: Theme.space.s3 }) {
              Text('成就墙')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.palette().textPrimary)
                .width('100%')
              ForEach(this.achievements(), (a: AchievementItem) => {
                Row({ space: Theme.space.s3 }) {
                  Column({ space: 4 }) {
                    Text(a.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.palette().textPrimary)
                    Text(a.desc)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.palette().textSecondary)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text(a.unlocked ? '已解锁' : '未解锁')
                    .fontSize(Theme.type.caption)
                    .fontColor(a.unlocked ? this.palette().success : this.palette().textTertiary)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.palette().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({ width: 1, color: this.palette().strokeHairline })
              }, (a: AchievementItem) => a.id)
            }
            .width('100%')

            if (this.feed.length > 0) {
              Column({ space: Theme.space.s3 }) {
                Text('观赛时间轴')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.palette().textPrimary)
                  .width('100%')
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
                    .width('100%')
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
                  .alignItems(HorizontalAlign.Start)
                  .backgroundColor(this.palette().surfaceCard)
                  .borderRadius(Theme.radius.xl)
                  .border({ width: 1, color: this.palette().strokeHairline })
                  .onClick((): void => {
                    if (row.type === 'checkin' || row.type === 'note' || row.type === 'favorite' ||
                      row.type === 'reminder') {
                      if (row.targetId.length > 0) {
                        DetailNav.openMatch(row.targetId)
                      }
                    }
                  })
                }, (row: ActivityFeedItem) => row.id)
              }
              .width('100%')
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.palette().surfacePage)
  }
}
