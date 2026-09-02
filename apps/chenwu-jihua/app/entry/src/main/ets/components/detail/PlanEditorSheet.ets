import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { DetailShell } from './DetailShell'
import { CwDateUtil, CwGoal, CwPlan } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'

@Component
export struct PlanEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwPlanId') editId: string = ''
  @StorageLink('cwPlanEditorGoalId') presetGoalId: string = ''
  onChanged: () => void = () => {}
  @State title: string = ''
  @State summary: string = ''
  @State goalId: string = ''
  @State horizonType: string = 'phase'
  @State startDate: string = CwDateUtil.todayKey()
  @State endDate: string = ''
  @State status: string = 'active'
  @State goals: CwGoal[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.goals = await ChenwuStore.loadGoals()
    if (this.editId.length > 0) {
      const found = await ChenwuStore.findPlan(this.editId)
      if (found !== undefined) {
        this.title = found.title
        this.summary = found.summary
        this.goalId = found.goalId
        this.horizonType = found.horizonType
        this.startDate = found.startDate
        this.endDate = found.endDate
        this.status = found.status
      }
    } else if (this.presetGoalId.length > 0) {
      this.goalId = this.presetGoalId
    } else if (this.goals.length > 0) {
      this.goalId = this.goals[0].id
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写计划标题'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let p = new CwPlan()
    if (this.editId.length > 0) {
      const found = await ChenwuStore.findPlan(this.editId)
      if (found !== undefined) {
        p = found
      }
    } else {
      p = CwPlan.createNew(this.title.trim(), this.goalId, this.horizonType)
    }
    p.title = this.title.trim()
    p.summary = this.summary
    p.goalId = this.goalId
    p.horizonType = this.horizonType
    p.startDate = this.startDate
    p.endDate = this.endDate
    p.status = this.status
    await ChenwuStore.savePlan(p)
    this.onChanged()
    const returnGoalId = this.presetGoalId
    ChenwuDetailNav.closePlanEditor()
    if (returnGoalId.length > 0) {
      ChenwuDetailNav.openGoal(returnGoalId)
      return
    }
    ChenwuDetailNav.openPlan(p.id)
  }

  build() {
    Stack() {
      DetailShell({ title: this.editId.length > 0 ? '编辑计划' : '新建计划', onClose: (): void => { ChenwuDetailNav.closePlanEditor() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '计划标题' })
              .onChange((v: string): void => { this.title = v })
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
            TextArea({ text: this.summary, placeholder: '计划摘要（可选）' })
              .onChange((v: string): void => { this.summary = v })
              .height(80)
            Text('时间跨度')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              this.hChip('long', '长期')
              this.hChip('phase', '阶段')
              this.hChip('short', '短期')
            }
            if (this.goals.length > 0) {
              Text('关联目标')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.goals, (g: CwGoal) => {
                  Text(g.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.goalId === g.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.goalId === g.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.goalId = g.id })
                }, (g: CwGoal) => g.id)
              }
            }
            AppDatePickerField({
              label: '开始日期',
              value: this.startDate,
              minDaysFromToday: -3650,
              maxDaysFromToday: 365,
              onChange: (v: string): void => { this.startDate = v }
            })
            AppDatePickerField({
              label: '结束日期',
              value: this.endDate.length > 0 ? this.endDate : this.startDate,
              minDaysFromToday: -3650,
              maxDaysFromToday: 3650,
              onChange: (v: string): void => { this.endDate = v }
            })
            AppButton({ label: '保存', onTap: (): void => { void this.save() } })
            Column().height(Theme.space.s8)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .width('100%')
        .layoutWeight(1)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  hChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.horizonType === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.horizonType === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.horizonType = key })
  }
}
