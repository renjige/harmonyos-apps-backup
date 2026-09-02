import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DashboardStats, JourneyProgress, DateGroup, SaituRecord, JourneyMilestone } from '../models/SaituModels'
import { SaituLocalStore } from '../services/SaituLocalStore'
import { SaituTrackStore } from '../services/SaituTrackStore'
import { SaituSportStore } from '../services/SaituSportStore'
import { SportStats } from '../models/SaituSportModels'
import { SaituDetailNav } from '../services/SaituDetailNav'

@Component
export struct BoardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituJourneyEpoch') @Watch('onJourneyEpochChange') journeyEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State stats: DashboardStats = new DashboardStats()
  @State progress: JourneyProgress[] = []
  @State groups: DateGroup[] = []
  @State records: SaituRecord[] = []
  @State milestones: JourneyMilestone[] = []
  @State sportStats: SportStats = new SportStats()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onJourneyEpochChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await SaituLocalStore.dashboardStats()
    this.progress = await SaituLocalStore.journeyProgress()
    this.records = await SaituLocalStore.loadRecords()
    this.milestones = await SaituTrackStore.loadMilestones()
    this.sportStats = await SaituSportStore.stats()
    const allGroups = DateGroup.groupRecords(this.records)
    this.groups = allGroups.slice(0, 5)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('轨迹看板')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '总札记', value: `${this.stats.totalRecords}` })
          AppStatCard({ label: '连续天', value: `${this.stats.streakDays}` })
          AppStatCard({ label: '已达成', value: `${this.stats.milestoneDone}/${this.stats.milestoneTotal}` })
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '本周', value: `${this.stats.weekRecords}` })
          AppStatCard({ label: '旅途', value: `${this.stats.totalJourneys}` })
          AppStatCard({ label: '小结', value: `${this.stats.savedReports}` })
        }
        .width('100%')

        Row() {
          Text('赛事档案汇总')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('进入赛事')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => SaituDetailNav.openSportHub())
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '赛事记录', value: `${this.sportStats.records}` })
          AppStatCard({ label: '比赛笔记', value: `${this.sportStats.notes}` })
          AppStatCard({ label: '赛事复盘', value: `${this.sportStats.reviews}` })
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '观赛计划', value: `${this.sportStats.plans}` })
          AppStatCard({ label: '纪念册', value: `${this.sportStats.albums}` })
          AppStatCard({ label: '关注', value: `${this.sportStats.follows}` })
        }
        .width('100%')

        if (this.sportStats.pendingPlans > 0) {
          Text(`还有 ${this.sportStats.pendingPlans} 项观赛计划待关注，可在「赛事」Tab 查看与更新状态。`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }

        Row() {
          Text('旅途进度')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('管理旅途')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => SaituDetailNav.openJourneyManage())
        }
        .width('100%')

        if (this.progress.length === 0) {
          Text('暂无旅途，可在「管理旅途」中创建目标项目')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        } else {
          ForEach(this.progress, (p: JourneyProgress) => {
            Column({ space: Theme.space.s2 }) {
              Row({ space: Theme.space.s2 }) {
                Column()
                  .width(8)
                  .height(32)
                  .backgroundColor(p.color)
                  .borderRadius(4)
                Column({ space: 4 }) {
                  Text(p.name)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(p.progressLabel)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              Row() {
                Row()
                  .width(`${Math.max(8, Math.round(p.ratio * 100))}%`)
                  .height(8)
                  .backgroundColor(p.color)
                  .borderRadius(4)
              }
              .width('100%')
              .height(8)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(4)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => SaituDetailNav.openJourneyDetail(p.journeyId))
          }, (p: JourneyProgress) => p.rowKey())
        }

        Row() {
          Text('赛途节点')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('添加节点')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => SaituDetailNav.openMilestoneEditor('', ''))
        }
        .width('100%')

        if (this.milestones.length === 0) {
          Text('节点不是备忘录条目：为旅途设可达成的阶段目标，勾选后看板进度才会前进。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        } else {
          ForEach(this.milestones, (m: JourneyMilestone) => {
            Row({ space: Theme.space.s3 }) {
              Column()
                .width(12)
                .height(12)
                .borderRadius(6)
                .backgroundColor(m.done ? Theme.colors().success : Theme.colors().brandPrimary)
              Column({ space: 4 }) {
                Text(m.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                Text(`${m.statusLabel()}${m.dueDate.length > 0 ? ` · ${m.dueDate}` : ''}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => SaituDetailNav.openMilestone(m.id))
          }, (m: JourneyMilestone) => m.id)
        }

        Text('近期时间线')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.groups.length === 0) {
          AppEmpty({ title: '暂无记录', description: '去「记录」页写下第一条札记' })
        } else {
          ForEach(this.groups, (g: DateGroup) => {
            Row() {
              Column()
                .width(4)
                .height(40)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(2)
              Column({ space: 4 }) {
                Text(g.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textPrimary)
                Text(`${g.records.length} 条记录`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: Theme.space.s3 })
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => {
              if (g.records.length > 0) {
                SaituDetailNav.openRecord(g.records[0].id)
              }
            })
          }, (g: DateGroup) => g.dateKey)
        }

        Blank().height(this.bottomInset + Theme.space.s6)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }
}
