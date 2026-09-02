import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { StatChip } from '../components/zhixing/StatChip'
import { KnowledgeItem, OverviewStats, TimelineEvent, TodayProgress, WeeklyGoalProgress } from '../models/ZhixingModels'
import { ZhixingMedia } from '../services/ZhixingMedia'
import { ZhixingStore } from '../services/ZhixingStore'
import { KnowledgeGridCard } from '../components/zhixing/KnowledgeGridCard'

@Component
export struct HomePage {
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State cards: KnowledgeItem[] = []
  @State continueItems: KnowledgeItem[] = []
  @State timeline: TimelineEvent[] = []
  @State stats: OverviewStats = new OverviewStats()
  @State today: TodayProgress = new TodayProgress()
  @State weekGoal: WeeklyGoalProgress = new WeeklyGoalProgress()
  @State staleCount: number = 0
  @State greet: string = '你好'
  onOpenItem: (id: string) => void = (_id: string) => {}
  onCreate: (kind: string) => void = (_k: string) => {}
  onOpenGraph: () => void = () => {}
  onOpenKind: (kind: string) => void = (_k: string) => {}
  onOpenSearch: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  onOpenAchievements: () => void = () => {}
  onOpenReviewQueue: () => void = () => {}
  onOpenFocus: () => void = () => {}
  onOpenWeeklyGoal: () => void = () => {}
  onOpenActionTab: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onDataEpochChange(): void {
    void this.load()
  }

  private greeting(): string {
    const h = new Date().getHours()
    if (h < 12) {
      return '上午好'
    }
    if (h < 18) {
      return '下午好'
    }
    return '晚上好'
  }

  private async load(): Promise<void> {
    this.greet = this.greeting()
    this.stats = await ZhixingStore.overview()
    this.today = await ZhixingStore.todayProgress()
    this.weekGoal = await ZhixingStore.loadWeeklyGoalProgress()
    this.staleCount = (await ZhixingStore.staleItems()).length
    this.continueItems = await ZhixingStore.loadContinueReading(3)
    this.timeline = await ZhixingStore.loadTimeline(5)
    this.cards = await ZhixingStore.loadByKind('card')
    if (this.cards.length === 0) {
      this.cards = await ZhixingStore.loadItems()
    }
    if (this.cards.length > 6) {
      const trimmed: KnowledgeItem[] = []
      for (let i = 0; i < 6; i++) {
        trimmed.push(this.cards[i])
      }
      this.cards = trimmed
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Column({ space: 4 }) {
              Text(`知行页 · ${this.greet}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`今日习惯 ${this.today.habitDone}/${this.today.habitTotal} · 子任务 ${this.today.taskDone}/${this.today.taskTotal}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Column() {
              AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
            }
            .width(40)
            .height(40)
            .borderRadius(20)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onOpenSearch() })
          }
          .width('100%')
          .padding({ top: Theme.space.s4 })

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_know'))
              .width('100%')
              .height(168)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(168)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,42,108,0.15)', 0], ['rgba(26,42,108,0.82)', 1]]
              })
            Column({ space: 8 }) {
              Text('今日学习进度')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
              Progress({ value: this.today.percent(), total: 100, type: ProgressType.Linear })
                .width('100%')
                .color(Theme.colors().brandAccent)
                .backgroundColor('rgba(255,255,255,0.25)')
              Text(this.today.totalUnits() > 0 ?
                `已完成 ${this.today.doneUnits()} / ${this.today.totalUnits()} 项` :
                '新建计划子任务或习惯，开始跟踪今日进度')
                .fontSize(Theme.type.caption)
                .fontColor('#F4EBD0')
            }
            .padding({ left: 16, right: 16, bottom: 16 })
            .width('100%')
          }
          .width('100%')
          .height(168)
          .clip(true)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.onOpenActionTab() })

          Column({ space: 8 }) {
            Row() {
              Text('本周学习目标')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Text('调整')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { this.onOpenWeeklyGoal() })
            }
            .width('100%')
            Progress({ value: this.weekGoal.overallPercent(), total: 100, type: ProgressType.Linear })
              .width('100%')
              .color(Theme.colors().brandPrimary)
            Text(`知识 ${this.weekGoal.doneKnowledge}/${this.weekGoal.targetKnowledge} · 打卡 ${this.weekGoal.doneChecks}/${this.weekGoal.targetChecks} · 复习 ${this.weekGoal.doneReviews}/${this.weekGoal.targetReviews}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpenWeeklyGoal() })

          if (this.staleCount > 0) {
            Row({ space: 10 }) {
              AppIcon({ name: 'book', iconSize: 20, color: Theme.colors().brandAccent })
              Column({ space: 2 }) {
                Text(`今日复习 · ${this.staleCount} 条待巩固`)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text('超过 7 天未更新的知识，完成复习计入本周目标')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.onOpenReviewQueue() })
          }

          Row({ space: 8 }) {
            StatChip({ label: '知识', value: `${this.stats.notes + this.stats.cards + this.stats.digests}` })
            StatChip({ label: '完成', value: `${this.stats.donePlans}` })
            StatChip({ label: '收藏', value: `${this.stats.favorites}` })
            StatChip({ label: '连续', value: `${this.stats.streak}天` })
          }
          .width('100%')

          Row({ space: 8 }) {
            this.QuickTile('新建', 'add', (): void => { this.onCreate('card') })
            this.QuickTile('专注', 'sparkle', (): void => { this.onOpenFocus() })
            this.QuickTile('收藏', 'heart', (): void => { this.onOpenFavorites() })
            this.QuickTile('时间轴', 'list', (): void => { this.onOpenTimeline() })
          }
          .width('100%')

          Image($r('app.media.hero_bg'))
            .width('100%')
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.onCreate('card') })

          Row({ space: 8 }) {
            this.EntryChip('笔记', 'note')
            this.EntryChip('卡片', 'card')
            this.EntryChip('摘要', 'digest')
            this.EntryChip('专题', 'graph')
          }
          .width('100%')

          if (this.continueItems.length > 0) {
            Text('继续阅读')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Scroll() {
              Row({ space: 10 }) {
                ForEach(this.continueItems, (it: KnowledgeItem) => {
                  Column({ space: 4 }) {
                    Image(ZhixingMedia.image(it.coverKey))
                      .width(120)
                      .height(72)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                    Text(it.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textPrimary)
                      .maxLines(1)
                      .width(120)
                  }
                  .onClick((): void => { this.onOpenItem(it.id) })
                }, (it: KnowledgeItem) => `cont_${it.id}`)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }

          if (this.timeline.length > 0) {
            Row() {
              Text('最近动态')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Text('全部')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { this.onOpenTimeline() })
            }
            .width('100%')
            ForEach(this.timeline, (ev: TimelineEvent) => {
              Text(`${ev.dateKey} · ${ev.title}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .padding({ top: 6, bottom: 6 })
            }, (ev: TimelineEvent) => `tl_${ev.refId}_${ev.createTime}`)
          }

          Row() {
            Text('最近卡片')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('成就')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.onOpenAchievements() })
          }
          .width('100%')

          if (this.cards.length === 0) {
            AppEmpty({
              title: '知库还是空的',
              description: '新建一张知识卡片，开始知→行闭环',
              actionLabel: '新建卡片',
              onAction: (): void => { this.onCreate('card') }
            })
          } else {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.cards, (it: KnowledgeItem) => {
                Column() {
                  KnowledgeGridCard({
                    item: it,
                    onOpen: (): void => { this.onOpenItem(it.id) }
                  })
                }
                .width('48%')
                .margin({ bottom: 12 })
              }, (it: KnowledgeItem) => it.id)
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
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(52)
      .height(52)
      .borderRadius(26)
      .backgroundColor(Theme.colors().brandPrimary)
      .justifyContent(FlexAlign.Center)
      .position({ right: 20, bottom: 20 })
      .onClick((): void => { this.onCreate('card') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .onVisibleAreaChange([0.4], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 0.4) {
        void this.load()
      }
    })
  }

  @Builder
  QuickTile(label: string, icon: string, tap: () => void) {
    Column({ space: 6 }) {
      AppIcon({
        name: icon === 'add' ? 'add' : (icon === 'sparkle' ? 'sparkle' : (icon === 'heart' ? 'heart' : 'list')),
        iconSize: 20,
        color: Theme.colors().brandPrimary
      })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(tap)
  }

  @Builder
  EntryChip(label: string, kind: string) {
    Column({ space: 6 }) {
      AppIcon({
        name: kind === 'graph' ? 'sparkle' : (kind === 'note' ? 'edit' : (kind === 'digest' ? 'book' : 'grid')),
        iconSize: 20,
        color: Theme.colors().brandAccent
      })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => {
      if (kind === 'graph') {
        this.onOpenGraph()
      } else if (kind === 'card') {
        this.onOpenKind('card')
      } else {
        this.onOpenKind(kind)
      }
    })
  }
}
