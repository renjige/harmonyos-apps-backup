import { Theme } from '../components/design-system/Theme'
import { AppButton, AppGradientButton } from '../components/design-system/AppButton'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ChallengeListCard } from '../components/sport/ChallengeListCard'
import { PlanTask, SportChallenge, TrainingPlan } from '../models/SportModels'
import { ChallengeStore } from '../services/ChallengeStore'
import { PlanStore } from '../services/PlanStore'
import { SportRecordService } from '../services/SportRecordService'
import { SportDetailNav } from '../services/SportDetailNav'
import { AuthService } from '../services/AuthService'
import { SectionHeader } from '../components/design-system/SectionHeader'
import { PlanSyncService } from '../services/PlanSyncService'
import { SelectChip } from '../components/design-system/SelectChip'
import { GlassPanel } from '../components/design-system/GlassPanel'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State plans: TrainingPlan[] = []
  @State challenges: SportChallenge[] = []
  @State showPlanForm: boolean = false
  @State showChallengeForm: boolean = false
  @State planTitle: string = ''
  @State planTasks: PlanTask[] = PlanSyncService.defaultTasks()
  @State chTitle: string = ''
  @State chSportType: string = '全部'
  @State chTargetSessions: string = '8'
  @State chStartDate: string = ''
  @State chEndDate: string = ''
  @State chNote: string = ''
  @State formError: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
    this.chStartDate = SportRecordService.todayKey()
    this.chEndDate = SportRecordService.addDays(this.chStartDate, 14)
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.plans = PlanStore.list()
    this.challenges = ChallengeStore.list()
  }

  private openPlanForm(): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    this.planTitle = ''
    this.planTasks = PlanSyncService.defaultTasks()
    this.formError = ''
    this.showPlanForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openChallengeForm(): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    this.chTitle = ''
    this.chSportType = '全部'
    this.chTargetSessions = '8'
    this.chStartDate = SportRecordService.todayKey()
    this.chEndDate = SportRecordService.addDays(this.chStartDate, 14)
    this.chNote = ''
    this.formError = ''
    this.showChallengeForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForms(): void {
    this.showPlanForm = false
    this.showChallengeForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async submitPlan(): Promise<void> {
    if (this.planTitle.trim().length < 2) {
      this.formError = '请填写周计划名称'
      return
    }
    const tasks: PlanTask[] = []
    const base = Date.now()
    for (let i = 0; i < this.planTasks.length; i++) {
      const src = this.planTasks[i]
      if (src.title.trim().length === 0) {
        continue
      }
      const t = new PlanTask()
      t.id = src.id.length > 0 ? src.id : `task_${base}_${i}`
      t.sportType = src.sportType
      t.title = src.title.trim()
      t.targetCount = src.targetCount > 0 ? src.targetCount : 1
      t.doneCount = 0
      t.status = 'pending'
      tasks.push(t)
    }
    if (tasks.length === 0) {
      this.formError = '请至少添加 1 项训练任务'
      return
    }
    const plan = PlanStore.createDefault(this.planTitle.trim(), tasks)
    await PlanStore.save(plan)
    this.closeForms()
    this.reload()
    this.onDataChanged()
  }

  private updateTaskSport(index: number, sportType: string): void {
    const next: PlanTask[] = []
    for (let i = 0; i < this.planTasks.length; i++) {
      const t = this.cloneTask(this.planTasks[i])
      if (i === index) {
        t.sportType = sportType
      }
      next.push(t)
    }
    this.planTasks = next
  }

  private cloneTask(src: PlanTask): PlanTask {
    const t = new PlanTask()
    t.id = src.id
    t.sportType = src.sportType
    t.title = src.title
    t.targetCount = src.targetCount
    t.doneCount = src.doneCount
    t.status = src.status
    return t
  }

  private async submitChallenge(): Promise<void> {
    const n = parseInt(this.chTargetSessions, 10)
    if (this.chTitle.trim().length < 2) {
      this.formError = '请填写挑战名称'
      return
    }
    if (isNaN(n) || n < 1) {
      this.formError = '目标次数至少为 1'
      return
    }
    const c = new SportChallenge()
    c.id = `ch_${Date.now()}`
    c.title = this.chTitle.trim()
    c.sportType = this.chSportType
    c.targetSessions = n
    c.startDate = this.chStartDate
    c.endDate = this.chEndDate
    c.note = this.chNote.trim()
    c.status = 'active'
    c.createdAt = new Date().toISOString()
    await ChallengeStore.save(c)
    this.closeForms()
    this.reload()
    this.onDataChanged()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          this.PageHero()
          GlassPanel() {
            Column({ space: Theme.space.s4 }) {
              SectionHeader({ title: '本周训练计划', subtitle: '保存训练自动计入匹配任务' })
              AppGradientButton({
                label: '新建周计划',
                onTap: (): void => {
                  this.openPlanForm()
                }
              })
              if (this.plans.length === 0) {
                AppEmpty({
                  title: '暂无周计划',
                  description: '创建一份 7 天计划，按任务勾选完成度。',
                  actionLabel: '创建计划',
                  onAction: (): void => {
                    this.openPlanForm()
                  }
                })
              } else {
                ForEach(this.plans, (p: TrainingPlan) => {
                  this.PlanRow(p)
                }, (p: TrainingPlan) => `${p.id}_${PlanStore.progress(p)}`)
              }
            }
          }

          GlassPanel() {
            Column({ space: Theme.space.s4 }) {
              SectionHeader({ title: '赛季挑战', subtitle: '训练记录自动计入挑战进度' })
              AppButton({
                label: '新建挑战',
                onTap: (): void => {
                  this.openChallengeForm()
                }
              })
              if (this.challenges.length === 0) {
                AppEmpty({
                  title: '还没有挑战',
                  description: '例如「两周跑步 8 次」。',
                  actionLabel: '立即创建',
                  onAction: (): void => {
                    this.openChallengeForm()
                  }
                })
              } else {
                ForEach(this.challenges, (c: SportChallenge) => {
                  ChallengeListCard({
                    item: c,
                    onTap: (): void => {
                      SportDetailNav.openChallenge(c.id)
                    }
                  })
                }, (c: SportChallenge) => c.id)
              }
            }
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s6,
          bottom: Theme.space.s10 + 96
        })
      }
      .width('100%')
      .height('100%')

      if (this.showPlanForm || this.showChallengeForm) {
        this.FormOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  PageHero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.ambient_data_bg'))
        .width('100%')
        .height(148)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(148)
        .borderRadius(Theme.radius.xl)
        .linearGradient({ angle: 180, colors: Theme.heroScrim() })
      Column({ space: 6 }) {
        Text('PLAN CENTER')
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textOnScrimMuted)
        Text('计划中心')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnScrim)
        Text('周计划 + 赛季挑战，让训练有节奏')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textOnScrimMuted)
      }
      .padding(Theme.space.s5)
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  PlanRow(p: TrainingPlan) {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: 4 }) {
          Text(p.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text(`${p.weekStart} → ${p.weekEnd}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text(`${PlanStore.progress(p)}%`)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')
      Progress({ value: PlanStore.progress(p), total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => {
      SportDetailNav.openPlan(p.id)
    })
  }

  @Builder
  FormOverlay() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Text(this.showPlanForm ? '新建周计划' : '新建挑战')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({
          label: '关闭',
          variant: 'secondary',
          onTap: (): void => {
            this.closeForms()
          }
        })
      }
      .width('100%')

      if (this.showPlanForm) {
        TextInput({ text: this.planTitle, placeholder: '计划名称，如「赛前一周」' })
          .onChange((v: string) => {
            this.planTitle = v
          })
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
        Text('自定义本周任务（保存后，同项目训练会自动 +1 进度）')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        ForEach(this.planTasks, (task: PlanTask, index: number) => {
          Column({ space: Theme.space.s2 }) {
            Text(`任务 ${index + 1}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: task.title, placeholder: '任务名称' })
              .onChange((v: string) => {
                const next: PlanTask[] = []
                for (let i = 0; i < this.planTasks.length; i++) {
                  const t = this.cloneTask(this.planTasks[i])
                  if (i === index) {
                    t.title = v
                  }
                  next.push(t)
                }
                this.planTasks = next
              })
              .fontColor(Theme.colors().textPrimary)
            Row({ space: Theme.space.s2 }) {
              ForEach(SportRecordService.sportTypes(), (st: string) => {
                SelectChip({
                  label: st,
                  active: task.sportType === st,
                  onTap: (): void => {
                    this.updateTaskSport(index, st)
                  }
                })
              }, (st: string) => `${index}_${st}`)
            }
            .width('100%')
            TextInput({ text: `${task.targetCount}`, placeholder: '目标次数' })
              .type(InputType.Number)
              .onChange((v: string) => {
                const n = parseInt(v, 10)
                const next: PlanTask[] = []
                for (let i = 0; i < this.planTasks.length; i++) {
                  const t = this.cloneTask(this.planTasks[i])
                  if (i === index && !isNaN(n) && n > 0) {
                    t.targetCount = n
                  }
                  next.push(t)
                }
                this.planTasks = next
              })
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }, (task: PlanTask, index: number) => `${task.id}_${index}`)
        AppGradientButton({
          label: '保存计划',
          onTap: (): void => {
            void this.submitPlan()
          }
        })
      } else {
        TextInput({ text: this.chTitle, placeholder: '挑战名称' })
          .onChange((v: string) => {
            this.chTitle = v
          })
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
        TextInput({ text: this.chTargetSessions, placeholder: '目标次数' })
          .onChange((v: string) => {
            this.chTargetSessions = v
          })
          .type(InputType.Number)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
        AppDatePickerField({
          label: '开始日期',
          value: this.chStartDate,
          onChange: (v: string): void => {
            this.chStartDate = v
          }
        })
        AppDatePickerField({
          label: '结束日期',
          value: this.chEndDate,
          onChange: (v: string): void => {
            this.chEndDate = v
          }
        })
        AppGradientButton({
          label: '保存挑战',
          onTap: (): void => {
            void this.submitChallenge()
          }
        })
      }

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
      }
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(30)
  }
}
