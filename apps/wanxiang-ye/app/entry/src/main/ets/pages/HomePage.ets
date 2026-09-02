import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { InfoFeaturedCard } from '../components/wanxiang/InfoFeaturedCard'
import { DashboardStats, TimelineEvent, AchievementDef } from '../models/UserKnowledgeModels'
import { InfoRepository } from '../services/InfoRepository'
import { StatsService } from '../services/StatsService'
import { TimelineService } from '../services/TimelineService'
import { AchievementService } from '../services/AchievementService'
import { WanXiangDetailNav } from '../services/WanXiangDetailNav'
import { WanXiangNav } from '../services/WanXiangNav'
import { InfoItem } from '../models/InfoModels'
import { TopicCollection } from '../models/InfoModels'
import { DailyTaskStore } from '../services/DailyTaskStore'
import { TopicProgressStore, TopicProgress } from '../services/TopicProgressStore'
import { TopicPathOverlayPage } from './TopicPathOverlayPage'
import { DailyTaskRow } from '../components/wanxiang/DailyTaskRow'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('wanxiangStoreReady') @Watch('onStoreReady') storeReady: boolean = false
  @Prop bottomInset: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State stats: DashboardStats = new DashboardStats()
  @State recentEvents: TimelineEvent[] = []
  @State todayLead: InfoItem | undefined = undefined
  @State greeting: string = ''
  @State dateLabel: string = ''
  @State latestAchievement: AchievementDef | undefined = undefined
  @State loading: boolean = true
  @State dailyReadDone: boolean = false
  @State dailyReviewDone: boolean = false
  @State dailyRecordDone: boolean = false
  @State topics: TopicCollection[] = []
  @State topicProgress: TopicProgress[] = []
  @State showTopicId: string = ''

  aboutToAppear(): void {
    this.initHeader()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onStoreReady(): void {
    if (this.storeReady) {
      void this.reload()
    }
  }

  private initHeader(): void {
    const now = new Date()
    const h = now.getHours()
    if (h < 12) {
      this.greeting = '早上好'
    } else if (h < 18) {
      this.greeting = '下午好'
    } else {
      this.greeting = '晚上好'
    }
    const m = now.getMonth() + 1
    const d = now.getDate()
    const weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    this.dateLabel = `${m}月${d}日 · 周${weekdays[now.getDay()]}`
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.stats = await StatsService.dashboard()
    const tasks = await DailyTaskStore.loadTodaySynced()
    this.dailyReadDone = tasks.readDone
    this.dailyReviewDone = tasks.reviewDone
    this.dailyRecordDone = tasks.recordDone
    this.topics = InfoRepository.topicCollections()
    const prog: TopicProgress[] = []
    for (const t of this.topics) {
      prog.push(await TopicProgressStore.load(t.id))
    }
    this.topicProgress = prog
    this.recentEvents = await TimelineService.recent(4)
    this.todayLead = InfoRepository.leadItem('recommend')
    const unlocked = await AchievementService.listUnlocked()
    if (unlocked.length > 0) {
      const last = unlocked[unlocked.length - 1]
      this.latestAchievement = AchievementService.defById(last)
    }
    this.loading = false
  }

  build() {
    Stack() {
      Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Column({ space: 4 }) {
            Text('万象页')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text(`${this.greeting}，今天也学一点新的东西`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            Text(this.dateLabel)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => WanXiangNav.openSearch())
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_bg'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
            .opacity(0.92)
          Row({ space: 8 }) {
            Image($r('app.media.banner_life'))
              .width(56)
              .height(56)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.sm)
            Text('今日阅读 · 从一条精选开始')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
          .padding(Theme.space.s4)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        this.progressCard()

        this.dailyTaskCard()

        Row({ space: Theme.space.s2 }) {
          this.miniStat('已读', `${this.stats.readCount}`)
          this.miniStat('收藏', `${this.stats.favoriteCount}`)
          this.miniStat('自建', `${this.stats.knowledgeCount}`)
          this.miniStat('连续', `${this.stats.streakDays}天`)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        this.quickActions()

        this.topicPathsSection()

        if (this.todayLead !== undefined) {
          Column({ space: Theme.space.s2 }) {
            Text('今日精选栏目')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            InfoFeaturedCard({
              item: this.todayLead,
              onTap: (): void => { WanXiangDetailNav.open(this.todayLead!.id) }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.recentEvents.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('最近动态栏目')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            ForEach(this.recentEvents, (ev: TimelineEvent) => {
              Row({ space: Theme.space.s2 }) {
                Text(TimelineService.formatDay(ev.timestamp))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width(48)
                Text(ev.title)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (ev: TimelineEvent) => ev.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.latestAchievement !== undefined) {
          Row({ space: Theme.space.s3 }) {
            Text(this.latestAchievement.emoji)
              .fontSize(28)
            Column({ space: 2 }) {
              Text('最近成就')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
              Text(this.latestAchievement.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
      }
      .padding({ bottom: this.bottomInset + Theme.space.s8 })
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .backgroundColor(Theme.colors().surfacePage)

      if (this.showTopicId.length > 0) {
        TopicPathOverlayPage({
          topicId: this.showTopicId,
          onClose: (): void => {
            this.showTopicId = ''
            AppStorage.setOrCreate('tabBarHidden', false)
            void this.reload()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  dailyTaskCard() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('今日任务')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text(`${this.dailyTaskDoneCount()}/3`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')

      DailyTaskRow({
        label: '阅读 1 篇精选',
        done: this.dailyReadDone,
        onTap: (): void => {
          if (this.todayLead !== undefined) {
            WanXiangDetailNav.open(this.todayLead.id)
          }
        }
      })
      DailyTaskRow({
        label: '完成 1 次复习',
        done: this.dailyReviewDone,
        onTap: (): void => WanXiangNav.switchTab(2)
      })
      DailyTaskRow({
        label: '记录 1 条知识/灵感',
        done: this.dailyRecordDone,
        onTap: (): void => WanXiangNav.openEditor()
      })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  private dailyTaskDoneCount(): number {
    let n = 0
    if (this.dailyReadDone) {
      n++
    }
    if (this.dailyReviewDone) {
      n++
    }
    if (this.dailyRecordDone) {
      n++
    }
    return n
  }

  @Builder
  topicPathsSection() {
    Column({ space: Theme.space.s2 }) {
      Text('专题阅读路径')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(this.topics, (t: TopicCollection, idx: number) => {
            this.topicCard(t, idx)
          }, (t: TopicCollection) => t.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  topicCard(t: TopicCollection, idx: number) {
    Column({ space: Theme.space.s2 }) {
      Text(`${t.emoji} ${t.title}`)
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .maxLines(2)
        .width(200)
      Text(t.description)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .maxLines(2)
        .width(200)
      Progress({
        value: idx < this.topicProgress.length ? this.topicProgress[idx].doneCount : 0,
        total: idx < this.topicProgress.length && this.topicProgress[idx].totalCount > 0 ?
          this.topicProgress[idx].totalCount : 1,
        type: ProgressType.Linear
      })
        .width(200)
        .height(6)
        .color(Theme.colors().brandPrimary)
    }
    .width(220)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
      this.showTopicId = t.id
    })
  }

  @Builder
  progressCard() {
    Column({ space: Theme.space.s3 }) {
      Text('本周阅读进度')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
      Progress({ value: this.stats.planDone, total: this.stats.planTarget, type: ProgressType.Linear })
        .width('100%')
        .height(8)
        .color('#FFFFFF')
        .backgroundColor('rgba(255,255,255,0.28)')
      Row() {
        Text(`已完成 ${this.stats.planDone} / ${this.stats.planTarget}`)
          .fontSize(Theme.type.bodyS)
          .fontColor('#F8FAFC')
        Blank()
        Text(`今日已读 ${this.stats.todayRead} 篇 · 待复习 ${this.stats.reviewPending}`)
          .fontSize(Theme.type.caption)
          .fontColor('#E2E8F0')
      }
      .width('100%')

      AppButton({
        label: this.stats.reviewPending > 0 ? '继续复习 →' : '开始阅读 →',
        variant: 'secondary',
        onTap: (): void => {
          if (this.stats.reviewPending > 0) {
            WanXiangNav.switchTab(2)
          } else if (this.todayLead !== undefined) {
            WanXiangDetailNav.open(this.todayLead.id)
          }
        }
      })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    .linearGradient({
      angle: 135,
      colors: [[Theme.colors().brandPrimary, 0], ['#0062CC', 1]]
    })
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  miniStat(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  quickActions() {
    Column({ space: Theme.space.s2 }) {
      Text('快捷操作')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.actionChip('新建知识', (): void => WanXiangNav.openEditor())
        this.actionChip('记灵感', (): void => WanXiangNav.openSparkEditor())
        this.actionChip('去复习', (): void => WanXiangNav.switchTab(2))
        this.actionChip('知识库', (): void => WanXiangNav.switchTab(1))
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  actionChip(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick((): void => onTap())
  }
}
