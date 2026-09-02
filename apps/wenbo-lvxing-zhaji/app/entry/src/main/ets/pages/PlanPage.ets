import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateDiaryRequest, JournalItem, UpdateDiaryRequest } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { PlanCodec, PlanTaskItem } from '../services/PlanCodec'
import { AuthService } from '../services/AuthService'

/** 计划 Tab：出行计划 · 清单进度 · 旅途打卡 */
@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onDataChanged: () => void = () => {}
  onWriteDiary: () => void = () => {}
  @State plans: JournalItem[] = []
  @State checkinStreak: number = 0
  @State checkedToday: boolean = false
  @State loading: boolean = true
  @State showForm: boolean = false
  @State showDetail: boolean = false
  @State detailPlan: JournalItem | undefined = undefined
  @State detailTasks: PlanTaskItem[] = []
  @State detailDoneCount: number = 0
  @State detailTotalCount: number = 0
  @State detailProgressPct: number = 0
  @State taskRevision: number = 0
  @State formTitle: string = ''
  @State formDestination: string = ''
  @State formDate: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private reloadSeq: number = 0

  aboutToAppear(): void {
    this.formDate = PlanPage.todayIso()
    void this.reload(true)
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  onRefreshTokenChange(): void {
    void this.reload(false)
  }

  private static todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(blocking: boolean = false): Promise<void> {
    const seq = ++this.reloadSeq
    if (blocking || this.plans.length === 0) {
      this.loading = true
    }
    if (!AuthService.isLoggedIn()) {
      if (seq !== this.reloadSeq) {
        return
      }
      this.plans = []
      this.checkinStreak = 0
      this.checkedToday = false
      this.loading = false
      return
    }
    const all = await JournalBizService.loadAllDiaries(this.currentUsername)
    if (seq !== this.reloadSeq) {
      return
    }
    this.plans = JournalBizService.filterPlans(all)
    const checkins = JournalBizService.filterCheckins(all)
    this.checkinStreak = JournalBizService.computeCheckinStreak(checkins)
    this.checkedToday = JournalBizService.hasCheckinToday(checkins)
    this.loading = false
  }

  private upsertPlan(plan: JournalItem): void {
    const item = JournalBizService.normalizePlanItem(plan)
    const next: JournalItem[] = []
    let found = false
    for (const p of this.plans) {
      if (p.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(p)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    this.plans = next
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formDestination = ''
    this.formDate = PlanPage.todayIso()
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private planProgress(item: JournalItem): number {
    return PlanCodec.progressPercent(PlanCodec.decodeTasks(item.body))
  }

  private async submitPlan(): Promise<void> {
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写计划名称'
      return
    }
    if (this.formDestination.trim().length === 0) {
      this.formError = '请填写目的地'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateDiaryRequest()
    req.title = this.formTitle.trim()
    req.subtitle = this.formDestination.trim()
    req.body = PlanCodec.encodeTasks(PlanCodec.defaultTasks())
    req.summary = `出行计划 · ${req.subtitle}`
    req.recordDate = this.formDate
    req.userId = this.currentUsername
    req.kind = 'plan'
    req.category = 'planning'
    req.coverKey = 'hero_travel_home'
    req.imageKeys = ['hero_travel_home']
    const created = await JournalBizService.createDiary(req)
    this.submitting = false
    if (created !== undefined) {
      this.upsertPlan(created)
      this.closeForm()
      this.showToast('出行计划已创建')
      this.onDataChanged()
      void this.reload(false)
    } else {
      this.formError = '创建失败，请稍后重试'
    }
  }

  private syncDetailProgress(): void {
    this.detailDoneCount = PlanCodec.doneCount(this.detailTasks)
    this.detailTotalCount = this.detailTasks.length
    this.detailProgressPct = PlanCodec.progressPercent(this.detailTasks)
    this.taskRevision += 1
  }

  private clonePlanWithBody(source: JournalItem, body: string, category: string): JournalItem {
    const copy = new JournalItem()
    copy.id = source.id
    copy.title = source.title
    copy.subtitle = source.subtitle
    copy.summary = source.summary
    copy.body = body
    copy.description = source.description
    copy.coverKey = source.coverKey
    copy.tags = source.tags
    copy.recordDate = source.recordDate
    copy.kind = source.kind
    copy.category = category
    copy.userId = source.userId
    copy.imageKeys = source.imageKeys
    copy.photoCount = source.photoCount
    return copy
  }

  private patchPlanList(planId: string, body: string, category: string): void {
    const nextPlans: JournalItem[] = []
    for (const p of this.plans) {
      if (p.id === planId) {
        nextPlans.push(this.clonePlanWithBody(p, body, category))
      } else {
        nextPlans.push(p)
      }
    }
    this.plans = nextPlans
  }

  private openPlanDetail(item: JournalItem): void {
    this.detailPlan = item
    this.detailTasks = PlanCodec.decodeTasks(item.body)
    this.syncDetailProgress()
    this.showDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closePlanDetail(): void {
    this.showDetail = false
    this.detailPlan = undefined
    this.detailTasks = []
    this.detailDoneCount = 0
    this.detailTotalCount = 0
    this.detailProgressPct = 0
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async toggleTask(taskId: string): Promise<void> {
    if (this.detailPlan === undefined) {
      return
    }
    const next: PlanTaskItem[] = []
    for (const t of this.detailTasks) {
      const copy = new PlanTaskItem()
      copy.id = t.id
      copy.title = t.title
      copy.done = t.id === taskId ? !t.done : t.done
      next.push(copy)
    }
    const encoded = PlanCodec.encodeTasks(next)
    const pct = PlanCodec.progressPercent(next)
    const category = pct >= 100 ? 'done' : 'active'
    const planId = this.detailPlan.id

    this.detailTasks = next
    this.detailPlan = this.clonePlanWithBody(this.detailPlan, encoded, category)
    this.patchPlanList(planId, encoded, category)
    this.syncDetailProgress()

    const req = new UpdateDiaryRequest()
    req.body = encoded
    req.category = category
    req.userId = this.currentUsername
    const updated = await JournalBizService.updateDiary(planId, req)
    if (updated !== undefined) {
      this.detailPlan = updated
      this.patchPlanList(planId, updated.body, updated.category.length > 0 ? updated.category : category)
      this.onDataChanged()
    } else {
      this.showToast('保存失败，请重试')
    }
  }

  private async handleCheckin(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.checkedToday) {
      this.showToast('今日已打卡')
      return
    }
    const req = new CreateDiaryRequest()
    req.title = '今日旅途打卡'
    req.subtitle = '旅途心情'
    req.body = '记录今日旅途点滴，保持连续打卡。'
    req.summary = '旅途打卡'
    req.recordDate = PlanPage.todayIso()
    req.userId = this.currentUsername
    req.kind = 'checkin'
    req.sourceRefId = 'daily'
    req.coverKey = 'hero_coastal_sunset'
    req.imageKeys = ['hero_coastal_sunset']
    const created = await JournalBizService.createDiary(req)
    if (created !== undefined) {
      await this.reload()
      this.onDataChanged()
      this.showToast(`打卡成功 · 连续 ${this.checkinStreak} 天`)
    } else {
      this.showToast('打卡失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          AppHeader({ title: '出行计划', subtitle: '规划旅程 · 清单进度 · 每日打卡' })

          if (!AuthService.isLoggedIn()) {
            AppEmpty({
              title: '登录后管理出行计划',
              description: '创建计划、跟踪清单、每日旅途打卡',
              actionLabel: '去登录',
              onAction: (): void => { this.onRequireAuth() }
            })
          } else if (this.loading) {
            AppLoading({ label: '加载计划…' })
          } else {
            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text(`${this.checkinStreak}`)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().brandPrimary)
                Text('连续打卡')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Column({ space: 4 }) {
                Text(`${this.plans.length}`)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().success)
                Text('进行中计划')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }
            .width('100%')

            AppButton({
              label: this.checkedToday ? '今日已打卡' : '今日旅途打卡',
              variant: this.checkedToday ? 'secondary' : 'primary',
              disabled: this.checkedToday,
              onTap: (): void => { void this.handleCheckin() }
            })

            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('我的计划')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                AppButton({
                  label: '新建',
                  variant: 'ghost',
                  onTap: (): void => { this.openCreateForm() }
                })
              }
              .width('100%')

              if (this.plans.length === 0) {
                AppEmpty({
                  title: '还没有出行计划',
                  description: '创建计划并勾选清单，出发前更有条理',
                  actionLabel: '创建计划',
                  onAction: (): void => { this.openCreateForm() }
                })
              } else {
                ForEach(this.plans, (plan: JournalItem) => {
                  Column({ space: Theme.space.s2 }) {
                    Row() {
                      Text(plan.title)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().textPrimary)
                        .layoutWeight(1)
                      Text(`${this.planProgress(plan)}%`)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandPrimary)
                    }
                    .width('100%')
                    Text(plan.subtitle.length > 0 ? plan.subtitle : '未设置目的地')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                      .width('100%')
                    Progress({ value: this.planProgress(plan), total: 100, type: ProgressType.Linear })
                      .width('100%')
                      .color(Theme.colors().brandPrimary)
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.xl)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                  .onClick((): void => { this.openPlanDetail(plan) })
                }, (plan: JournalItem) => `${plan.id}_${this.planProgress(plan)}`)
              }
            }
            .width('100%')
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      if (this.showForm) {
        this.PlanFormOverlay()
      }
      if (this.showDetail && this.detailPlan !== undefined) {
        this.PlanDetailOverlay()
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
        .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
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
        Text('创建出行计划')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.formError.length > 0) {
            Text(this.formError)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
          TextInput({ text: this.formTitle, placeholder: '计划名称，如：川西五日游' })
            .width('100%')
            .height(44)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
          TextInput({ text: this.formDestination, placeholder: '目的地，如：云南·大理' })
            .width('100%')
            .height(44)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formDestination = v })
          AppDatePickerField({
            label: '出发日期',
            value: this.formDate,
            placeholder: '选择日期',
            onChange: (v: string) => { this.formDate = v }
          })
          Text('将自动创建「订交通 / 订住宿 / 整理行李」清单')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          AppButton({
            label: this.submitting ? '创建中…' : '创建计划',
            disabled: this.submitting,
            onTap: (): void => { void this.submitPlan() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(25)
  }

  @Builder
  PlanDetailOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closePlanDetail() })
        Text(this.detailPlan !== undefined ? this.detailPlan.title : '计划详情')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.detailPlan !== undefined) {
            Text(this.detailPlan.subtitle)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text(`进度 ${this.detailDoneCount}/${this.detailTotalCount}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            Progress({ value: this.detailProgressPct, total: 100, type: ProgressType.Linear })
              .width('100%')
              .color(Theme.colors().brandPrimary)
          }
          ForEach(this.detailTasks, (task: PlanTaskItem) => {
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppIcon({
                  name: task.done ? 'check' : 'empty',
                  iconSize: Theme.icon.md,
                  color: task.done ? Theme.colors().success : Theme.colors().textTertiary
                })
              }
              .width(32)
              .height(32)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(task.done ?
                Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              Text(task.title)
                .fontSize(Theme.type.body)
                .fontColor(task.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
                .decoration({ type: task.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({
              width: task.done ? 1 : 0,
              color: Theme.colors().brandPrimary
            })
            .onClick((): void => { void this.toggleTask(task.id) })
          }, (task: PlanTaskItem) => `${task.id}_${task.done ? '1' : '0'}_${this.taskRevision}`)

          AppButton({
            label: '写今日札记',
            variant: 'secondary',
            onTap: (): void => {
              this.closePlanDetail()
              this.onWriteDiary()
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(26)
  }
}
