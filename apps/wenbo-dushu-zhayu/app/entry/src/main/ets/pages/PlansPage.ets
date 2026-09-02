import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { CreatePlanRequest, PlanItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct PlansPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onPlanCreated: () => void = () => {}
  onOpenReport: () => void = () => {}
  @State plans: PlanItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formGoal: string = ''
  @State formDeadline: string = ''
  @State formMinutes: string = '30'
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.plans.length === 0) {
      this.loading = true
    }
    if (AuthService.isLoggedIn()) {
      this.plans = await ReadingBizService.loadPlans(this.currentUsername)
    } else {
      this.plans = []
    }
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formGoal = ''
    this.formDeadline = this.plusDays(30)
    this.formMinutes = '30'
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private plusDays(days: number): string {
    const d = new Date()
    d.setDate(d.getDate() + days)
    return d.toISOString().slice(0, 10)
  }

  private applyTemplate(kind: string): void {
    if (kind === 'month3') {
      this.formTitle = '一个月读完 3 本书'
      this.formGoal = '本月完成 3 本，拆成每周一本，读完写一篇书评。'
      this.formDeadline = this.plusDays(30)
      this.formMinutes = '30'
      return
    }
    this.formTitle = '每天阅读 30 分钟'
    this.formGoal = '每天固定半小时，连续打卡，形成阅读习惯。'
    this.formDeadline = this.plusDays(30)
    this.formMinutes = '30'
  }

  private planMeta(item: PlanItem): string {
    let meta = `进度 ${item.progress}%`
    if (item.deadline.length > 0) {
      meta = `${meta} · 截止 ${item.deadline}`
    }
    if (item.dailyMinutes > 0) {
      meta = `${meta} · 每天 ${item.dailyMinutes} 分钟`
    }
    return meta
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async submitPlan(): Promise<void> {
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写计划名称'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreatePlanRequest()
    req.title = this.formTitle.trim()
    req.goal = this.formGoal.trim()
    req.summary = req.goal
    req.deadline = this.formDeadline
    const mins = Number(this.formMinutes)
    req.readingMinutes = mins > 0 ? mins : 0
    req.userId = this.currentUsername
    const created = await ReadingBizService.createPlan(req)
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      this.onPlanCreated()
    } else {
      this.formError = '创建失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '阅读计划', subtitle: '设定目标、截止时间与每日时长' })
        AppButton({
          label: '查看阅读报告',
          variant: 'secondary',
          onTap: (): void => { this.onOpenReport() }
        })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        if (this.loading) {
          AppLoading({ label: '加载计划…' }).layoutWeight(1)
        } else if (this.plans.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有阅读计划',
              description: AuthService.isLoggedIn()
                ? '点击右下角按钮，创建第一个阅读计划'
                : '登录后可创建并同步你的计划',
              actionLabel: '创建计划',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.plans, (item: PlanItem) => {
                ReadingListCard({
                  title: item.title,
                  summary: item.goal.length > 0 ? item.goal : item.summary,
                  coverKey: 'hero_reading_desk',
                  meta: this.planMeta(item),
                  showCover: false,
                  onTap: (): void => { ReadingDetailNav.openPlan(item.id) }
                })
              }, (item: PlanItem) => item.id)
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
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .shadow({ radius: 12, color: 'rgba(45,90,74,0.2)', offsetY: 4 })
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.PlanFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PlanFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('创建计划')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 6 }) {
            Text('快捷模板')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              Text('一个月读 3 本')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.tagForeground())
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(Theme.tagBackground())
                .border({
                  width: Theme.isDark() ? 1 : 0,
                  color: Theme.colors().strokeStrong
                })
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.applyTemplate('month3') })
              Text('每天 30 分钟')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.tagForeground())
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(Theme.tagBackground())
                .border({
                  width: Theme.isDark() ? 1 : 0,
                  color: Theme.colors().strokeStrong
                })
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.applyTemplate('daily30') })
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('计划名称')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '如：2026 阅读 24 本' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('阅读目标')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.formGoal, placeholder: '描述你的阅读目标…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(120)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formGoal = v })
          }
          .width('100%')

          AppDatePickerField({
            label: '完成时间',
            value: this.formDeadline,
            placeholder: '请选择截止日期',
            minDaysFromToday: 0,
            maxDaysFromToday: 180,
            onChange: (v: string): void => { this.formDeadline = v }
          })

          Column({ space: 6 }) {
            Text('每天阅读时长（分钟）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.formMinutes, placeholder: '如：30' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formMinutes = v })
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '创建中…' : '创建计划',
            disabled: this.submitting,
            onTap: (): void => { void this.submitPlan() }
          })
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
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
