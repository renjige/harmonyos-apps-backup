import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppTextField } from '../design-system/AppTextField'
import { Journey } from '../../models/SaituModels'
import { JourneyPlan, PlanTask } from '../../models/SaituGrowthModels'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituPlanStore } from '../../services/SaituPlanStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'
import { SaituAchievementStore } from '../../services/SaituAchievementStore'

@Component
export struct PlanEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituPlanEditorId') @Watch('onTargetChange') editorId: string = ''
  @StorageLink('saituPlanJourneyId') journeyPrefill: string = ''
  onSaved: () => void = () => {}
  @State title: string = ''
  @State targetCount: string = '10'
  @State taskInput: string = ''
  @State journeys: Journey[] = []
  @State selectedJourneyId: string = ''
  @State tasks: PlanTask[] = []
  @State toastText: string = ''
  private editing: JourneyPlan = new JourneyPlan()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onTargetChange(): void {
    void this.bootstrap()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async bootstrap(): Promise<void> {
    this.journeys = await SaituLocalStore.loadJourneys()
    if (this.editorId.length > 0) {
      const found = await SaituPlanStore.findPlan(this.editorId)
      if (found !== undefined) {
        this.editing = found
        this.title = found.title
        this.targetCount = `${found.targetCount}`
        this.selectedJourneyId = found.journeyId
        this.tasks = found.tasks.slice()
        return
      }
    }
    this.editing = JourneyPlan.create(this.journeyPrefill.length > 0 ? this.journeyPrefill : '')
    this.title = ''
    this.targetCount = '10'
    this.tasks = []
    if (this.journeyPrefill.length > 0) {
      this.selectedJourneyId = this.journeyPrefill
    } else if (this.journeys.length > 0) {
      this.selectedJourneyId = this.journeys[0].id
    }
  }

  private addTask(): void {
    const t = this.taskInput.trim()
    if (t.length === 0) {
      return
    }
    const task = PlanTask.create(t)
    const next: PlanTask[] = []
    for (const x of this.tasks) {
      next.push(x)
    }
    next.push(task)
    this.tasks = next
    this.taskInput = ''
  }

  private toggleTask(id: string): void {
    const next: PlanTask[] = []
    for (const t of this.tasks) {
      const copy = new PlanTask()
      copy.id = t.id
      copy.title = t.title
      copy.done = t.id === id ? !t.done : t.done
      next.push(copy)
    }
    this.tasks = next
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写计划标题')
      return
    }
    if (this.selectedJourneyId.length === 0) {
      this.showToast('请选择旅途')
      return
    }
    this.editing.title = this.title.trim()
    this.editing.journeyId = this.selectedJourneyId
    const tc = parseInt(this.targetCount, 10)
    this.editing.targetCount = isNaN(tc) || tc <= 0 ? 10 : tc
    this.editing.tasks = this.tasks
    let done = 0
    for (const t of this.tasks) {
      if (t.done) {
        done++
      }
    }
    if (this.tasks.length > 0 && done === this.tasks.length) {
      this.editing.status = 'done'
    }
    await SaituPlanStore.savePlan(this.editing)
    await SaituAchievementStore.evaluateAndUnlock()
    SaituDetailNav.closePlanEditor()
    this.onSaved()
  }

  @Builder
  JourneyChip(j: Journey) {
    Text(j.name)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.selectedJourneyId === j.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.selectedJourneyId === j.id ? j.color : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.selectedJourneyId = j.id })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: this.editorId.length > 0 ? '编辑计划' : '新建赛途计划',
          onBack: (): void => SaituDetailNav.closePlanEditor()
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            AppTextField({
              text: this.title,
              placeholder: '计划名称，如 8 周备赛',
              onChange: (v: string): void => { this.title = v }
            })
            AppTextField({
              text: this.targetCount,
              placeholder: '目标次数（无任务清单时生效）',
              inputType: InputType.Number,
              onChange: (v: string): void => { this.targetCount = v }
            })
            Text('归属旅途')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.journeys, (j: Journey) => {
                this.JourneyChip(j)
              }, (j: Journey) => j.id)
            }
            Text('任务清单（可选）')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
            Column({ space: Theme.space.s2 }) {
              AppTextField({
                text: this.taskInput,
                placeholder: '输入子任务，如 每周跑量 20km',
                onChange: (v: string): void => { this.taskInput = v }
              })
              Row() {
                Blank()
                AppButton({
                  label: '添加',
                  variant: 'secondary',
                  block: false,
                  onTap: (): void => this.addTask()
                })
              }
              .width('100%')
            }
            .width('100%')
            ForEach(this.tasks, (t: PlanTask) => {
              Row({ space: Theme.space.s3 }) {
                Text(t.done ? '☑' : '☐')
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().brandPrimary)
                Text(t.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
              }
              .width('100%')
              .onClick((): void => this.toggleTask(t.id))
            }, (t: PlanTask) => `${t.id}_${t.done ? '1' : '0'}`)
            AppButton({ label: '保存计划', variant: 'primary', onTap: (): void => { void this.save() } })
            Blank().height(Theme.space.s10)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
