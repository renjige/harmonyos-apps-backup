import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppTimePickerField } from '../components/design-system/AppDatePickerField'
import { KnowledgeItem, RecommendItem, StudyReminder } from '../models/ZhixingModels'
import { ZhixingMedia } from '../services/ZhixingMedia'
import { ZhixingStore } from '../services/ZhixingStore'
import { RecommendService } from '../services/RecommendService'
import { ReminderService } from '../services/ReminderService'
import { StatChip } from '../components/zhixing/StatChip'

@Component
export struct WisdomPage {
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State hits: KnowledgeItem[] = []
  @State knowText: string = '0'
  @State planText: string = '0'
  @State checkText: string = '0/0'
  @State weekKnow: string = '0'
  @State weekLog: string = '0'
  @State weekRate: string = '0%'
  @State logCount: number = 0
  @State stale: KnowledgeItem[] = []
  @State recs: RecommendItem[] = []
  @State reminder: StudyReminder = new StudyReminder()
  @State remindSwitch: boolean = false
  @State timeText: string = '21:00'
  @State toastText: string = ''
  private reminderBusy: boolean = false
  private ignoreToggleUntil: number = 0
  onOpenItem: (id: string) => void = (_id: string) => {}
  onDiagnose: () => void = () => {}
  onCreateCard: () => void = () => {}
  onOpenActionTab: () => void = () => {}
  onOpenTag: (tag: string) => void = (_t: string) => {}
  onOpenGrowth: () => void = () => {}
  onOpenAchievements: () => void = () => {}
  onOpenReview: () => void = () => {}
  onOpenReviewQueue: () => void = () => {}
  onOpenFocus: () => void = () => {}
  onOpenWeeklyGoal: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    this.uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext
    void this.load()
  }

  private hostContext(): common.UIAbilityContext | null {
    if (this.uiContext === null) {
      try {
        this.uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext
      } catch {
        this.uiContext = null
      }
    }
    return this.uiContext
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onDataEpochChange(): void {
    void this.load()
  }

  private pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  private async load(): Promise<void> {
    const ov = await ZhixingStore.overview()
    const weekly = await ZhixingStore.weeklyInsight()
    this.knowText = `${ov.notes + ov.cards + ov.digests}`
    this.planText = `${ov.plans}`
    this.checkText = `${weekly.checkedHabitsToday}/${weekly.habitTotal}`
    this.weekKnow = `${weekly.newKnowledge}`
    this.weekLog = `${weekly.newLogs}`
    this.weekRate = `${weekly.planRate}%`
    this.logCount = ov.logs
    this.stale = await ZhixingStore.staleItems()
    this.recs = await RecommendService.byTags()
    const loaded = await ZhixingStore.loadReminder()
    if (!this.reminderBusy) {
      this.reminder = loaded
      this.remindSwitch = loaded.enabled
    }
    this.timeText = `${this.pad(this.reminder.hour)}:${this.pad(this.reminder.minute)}`
    if (this.query.trim().length > 0) {
      this.hits = await ZhixingStore.search(this.query.trim())
    } else {
      this.hits = []
    }
  }

  private async onTime(v: string): Promise<void> {
    this.timeText = v
    const parts = v.split(':')
    if (parts.length >= 2) {
      this.reminder.hour = Number.parseInt(parts[0], 10)
      this.reminder.minute = Number.parseInt(parts[1], 10)
      await ZhixingStore.saveReminder(this.reminder)
      if (this.reminder.enabled && this.hostContext() !== null) {
        const ok = await ReminderService.apply(this.reminder, this.hostContext() as common.UIAbilityContext)
        this.toastText = ok ? '提醒时间已更新' : ReminderService.lastError
        setTimeout((): void => { this.toastText = '' }, 2800)
      }
    }
  }

  private async toggleRemind(want: boolean): Promise<void> {
    if (this.reminderBusy || Date.now() < this.ignoreToggleUntil) {
      return
    }
    this.reminderBusy = true
    const prevEnabled = this.reminder.enabled
    this.remindSwitch = want
    this.reminder.enabled = want
    try {
      const ctx = this.hostContext()
      if (ctx === null) {
        this.ignoreToggleUntil = Date.now() + 600
        this.remindSwitch = prevEnabled
        this.reminder.enabled = prevEnabled
        this.toastText = '环境未就绪，请稍后再试'
        return
      }
      const ok = await ReminderService.apply(this.reminder, ctx)
      if (!ok) {
        this.ignoreToggleUntil = Date.now() + 600
        this.remindSwitch = prevEnabled
        this.reminder.enabled = prevEnabled
        await ZhixingStore.saveReminder(this.reminder)
        this.toastText = ReminderService.lastError.length > 0 ?
          ReminderService.lastError : '提醒设置失败，请检查通知与发布提醒权限'
        return
      }
      await ZhixingStore.saveReminder(this.reminder)
      if (want) {
        this.toastText = ReminderService.lastError.length > 0 ?
          ReminderService.lastError : `已开启，${ReminderService.nextLabel(this.reminder)} 到点提醒`
      } else {
        this.toastText = '已关闭提醒'
      }
    } finally {
      this.reminderBusy = false
    }
    setTimeout((): void => { this.toastText = '' }, 3200)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.themeEpoch >= 0 ? '智慧' : '智慧')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .padding({ top: Theme.space.s4 })
          Text('检索、提醒、统计与规则推荐，不含生成式对话')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          TextInput({ text: this.query, placeholder: '智慧检索：关键词' })
            .onChange((v: string) => {
              this.query = v
              void this.load()
            })
            .height(44)
            .fontColor(Theme.colors().textPrimary)
            .placeholderColor(Theme.colors().textTertiary)
            .backgroundColor(Theme.colors().surfaceCard)

          if (this.hits.length > 0) {
            ForEach(this.hits, (it: KnowledgeItem) => {
              Text(`${it.kindLabel()} · ${it.title}`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .padding(12)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.onOpenItem(it.id) })
            }, (it: KnowledgeItem) => it.id)
          }

          if (this.stale.length > 0) {
            Row({ space: 10 }) {
              AppIcon({ name: 'book', iconSize: 20, color: Theme.colors().brandAccent })
              Column({ space: 2 }) {
                Text(`复习队列 · ${this.stale.length} 条待巩固`)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text('进入队列逐条复习，完成后计入本周目标')
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

          Row({ space: 10 }) {
            AppIcon({ name: 'sparkle', iconSize: 20, color: Theme.colors().brandAccent })
            Column({ space: 2 }) {
              Text('专注学习')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('15/25/45 分钟倒计时，结束写入行动日志')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpenFocus() })

          Row({ space: 10 }) {
            AppIcon({ name: 'flag', iconSize: 20, color: Theme.colors().brandAccent })
            Column({ space: 2 }) {
              Text('本周学习目标')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('知识 / 打卡 / 复习三维目标与进度')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpenWeeklyGoal() })

          Row({ space: 12 }) {
            StatChip({ label: '知识', value: this.knowText })
            StatChip({ label: '计划', value: this.planText })
            StatChip({ label: '打卡', value: this.checkText })
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('本周学习概览')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Row({ space: 8 }) {
              StatChip({ label: '新增知识', value: this.weekKnow })
              StatChip({ label: '行动日志', value: this.weekLog })
              StatChip({ label: '计划完成', value: this.weekRate })
            }
            .width('100%')
            Text(`累计日志 ${this.logCount} 条 · 待复习 ${this.stale.length} 条`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text('去行录打卡')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
              .onClick((): void => { this.onOpenActionTab() })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Column({ space: 8 }) {
            Row() {
              AppIcon({ name: 'bell', iconSize: 20, color: Theme.colors().brandAccent })
              Text(' 智能提醒')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: this.remindSwitch })
                .selectedColor(Theme.colors().brandPrimary)
                .enabled(false)
            }
            .width('100%')
            .onClick((): void => { void this.toggleRemind(!this.remindSwitch) })
            AppTimePickerField({
              label: '提醒时间',
              value: this.timeText,
              placeholder: '选择时间',
              onChange: (v: string) => { void this.onTime(v) }
            })
            Text('开启后会预约到点再通知，不会立刻弹出。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text('推荐阅读')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.recs.length === 0) {
            AppEmpty({
              title: '还没有推荐',
              description: '给知识卡片加上标签后，会按规则给出阅读方向',
              actionLabel: '去写卡片',
              onAction: (): void => { this.onCreateCard() }
            })
          } else {
            ForEach(this.recs, (r: RecommendItem) => {
              Row({ space: 12 }) {
                Image(ZhixingMedia.image(r.coverKey))
                  .width(64)
                  .height(64)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                Column({ space: 4 }) {
                  Text(r.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text(r.reason)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.onOpenTag(r.tag) })
            }, (r: RecommendItem) => r.id)
          }

          Row({ space: 10 }) {
            AppIcon({ name: 'chart', iconSize: 20, color: Theme.colors().brandAccent })
            Column({ space: 2 }) {
              Text('成长仪表盘')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('统计、趋势与周/月回顾摘要')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpenGrowth() })

          Row({ space: 10 }) {
            AppIcon({ name: 'flag', iconSize: 20, color: Theme.colors().brandAccent })
            Column({ space: 2 }) {
              Text('成就墙')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('打卡、卡片与计划里程碑')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpenAchievements() })

          Row({ space: 10 }) {
            AppIcon({ name: 'list', iconSize: 20, color: Theme.colors().brandAccent })
            Column({ space: 2 }) {
              Text('成长时间轴')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('创建、打卡、完成与日志串联')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpenTimeline() })

          Row({ space: 10 }) {
            AppIcon({ name: 'sparkle', iconSize: 20, color: Theme.colors().brandAccent })
            Column({ space: 2 }) {
              Text('学情自检')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('问卷 + 模板报告，不含生成式对话')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onDiagnose() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
          .zIndex(30)
      }
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
}
