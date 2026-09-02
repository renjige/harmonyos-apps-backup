import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ActionLog, PlanTask, PlanTemplate, StudyHabit, StudyPlan } from '../../models/ZhixingModels'
import { ZhixingStore } from '../../services/ZhixingStore'

@Component
export struct ActionEditor {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop kind: string = 'plan'
  @State title: string = ''
  @State extra: string = ''
  @State deadline: string = ''
  @State progress: number = 0
  @State errorText: string = ''
  @State templateId: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  private plan: StudyPlan = StudyPlan.createNew()
  private habit: StudyHabit = StudyHabit.createNew()
  private log: ActionLog = ActionLog.createNew()
  private templates: PlanTemplate[] = ZhixingStore.planTemplates()

  aboutToAppear(): void {
    void this.boot()
  }

  private heading(): string {
    if (this.kind === 'habit') {
      return this.itemId.length > 0 ? '编辑习惯' : '🔥 新建习惯'
    }
    if (this.kind === 'log') {
      return this.itemId.length > 0 ? '编辑行动日志' : '🌙 写行动日志'
    }
    return this.itemId.length > 0 ? '编辑学习计划' : '🎯 新建学习计划'
  }

  private async boot(): Promise<void> {
    if (this.kind === 'habit') {
      if (this.itemId.length > 0) {
        const f = await ZhixingStore.findHabit(this.itemId)
        if (f !== undefined) {
          this.habit = f
          this.title = f.title
        }
      }
      return
    }
    if (this.kind === 'log') {
      if (this.itemId.length > 0) {
        const f = await ZhixingStore.findLog(this.itemId)
        if (f !== undefined) {
          this.log = f
          this.title = f.title
          this.extra = f.body
        }
      }
      return
    }
    if (this.itemId.length > 0) {
      const f = await ZhixingStore.findPlan(this.itemId)
      if (f !== undefined) {
        this.plan = f
        this.title = f.title
        this.extra = f.goal
        this.deadline = f.deadline
        this.progress = f.progress
      }
    }
  }

  private applyTemplate(t: PlanTemplate): void {
    if (this.itemId.length > 0) {
      return
    }
    this.templateId = t.id
    this.title = t.title
    this.extra = t.goal
    this.plan = StudyPlan.createNew()
    this.plan.title = t.title
    this.plan.goal = t.goal
    this.plan.progress = 0
    this.plan.tasks = []
    for (const tt of t.taskTitles) {
      this.plan.tasks.push(PlanTask.create(tt))
    }
    this.plan.syncProgressFromTasks()
    this.progress = 0
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    if (this.kind === 'habit') {
      this.habit.title = this.title.trim()
      await ZhixingStore.saveHabit(this.habit)
      this.onSaved()
      return
    }
    if (this.kind === 'log') {
      this.log.title = this.title.trim()
      this.log.body = this.extra.trim()
      await ZhixingStore.saveLog(this.log)
      this.onSaved()
      return
    }
    this.plan.title = this.title.trim()
    this.plan.goal = this.extra.trim()
    this.plan.deadline = this.deadline
    this.plan.progress = this.progress
    await ZhixingStore.savePlan(this.plan)
    this.onSaved()
  }

  build() {
    Column() {
      AppNavBar({ title: this.heading(), onBack: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
          TextInput({ text: this.title, placeholder: '标题' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          if (this.kind === 'plan') {
            if (this.itemId.length === 0) {
              Text('计划模板（可选）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.templates, (t: PlanTemplate) => {
                  Text(t.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.templateId === t.id ?
                      Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.templateId === t.id ?
                      Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.applyTemplate(t) })
                }, (t: PlanTemplate) => t.id)
              }
              .width('100%')
            }
            TextArea({ text: this.extra, placeholder: '目标与验收标准' })
              .onChange((v: string) => { this.extra = v })
              .height(100)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            AppDatePickerField({
              label: '截止日期',
              value: this.deadline,
              placeholder: '选择截止日期',
              minDaysFromToday: 0,
              maxDaysFromToday: 365,
              onChange: (v: string) => { this.deadline = v }
            })
            Text(`进度 ${this.progress}%`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Slider({ value: this.progress, min: 0, max: 100, step: 5 })
              .onChange((v: number) => { this.progress = Math.floor(v) })
              .width('100%')
          }
          if (this.kind === 'log') {
            TextArea({ text: this.extra, placeholder: '今天做了什么，有什么反思' })
              .onChange((v: string) => { this.extra = v })
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          }
          AppButton({ label: '保存', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
