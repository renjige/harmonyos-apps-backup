import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { PatchPlanRequest } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'

/** 计划编辑 / 删除确认 */
@Component
export struct PlanEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = 'edit'
  @Prop planId: string = ''
  @Prop initialTitle: string = ''
  @Prop initialGoal: string = ''
  @Prop initialDeadline: string = ''
  @Prop initialMinutes: number = 0
  onClose: () => void = () => {}
  onDone: (kind: string) => void = (kind: string) => { if (kind.length < 0) { return } }
  @State formTitle: string = ''
  @State formGoal: string = ''
  @State formDeadline: string = ''
  @State formMinutes: string = ''
  @State submitting: boolean = false
  @State errorText: string = ''

  aboutToAppear(): void {
    this.formTitle = this.initialTitle
    this.formGoal = this.initialGoal
    this.formDeadline = this.initialDeadline
    this.formMinutes = this.initialMinutes > 0 ? `${this.initialMinutes}` : ''
  }

  private async saveEdit(): Promise<void> {
    if (this.formTitle.trim().length === 0) {
      this.errorText = '请填写计划名称'
      return
    }
    this.submitting = true
    const req = new PatchPlanRequest()
    req.title = this.formTitle.trim()
    req.goal = this.formGoal.trim()
    req.summary = req.goal
    req.deadline = this.formDeadline
    const mins = Number(this.formMinutes)
    req.readingMinutes = mins > 0 ? mins : 0
    const updated = await ReadingBizService.patchPlan(this.planId, req)
    this.submitting = false
    if (updated !== undefined) {
      this.onDone('saved')
      return
    }
    this.errorText = '保存失败，请稍后重试'
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text(this.mode === 'delete' ? '删除计划' : '编辑计划')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.mode === 'delete') {
            Text(`确认删除「${this.initialTitle}」？删除后不可恢复。`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            AppButton({
              label: '确认删除',
              variant: 'danger',
              onTap: (): void => { this.onDone('delete') }
            })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.onClose() }
            })
          } else {
            TextInput({ text: this.formTitle, placeholder: '计划名称' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
            TextArea({ text: this.formGoal, placeholder: '阅读目标…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(120)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formGoal = v })
            AppDatePickerField({
              label: '完成时间',
              value: this.formDeadline,
              placeholder: '请选择截止日期',
              minDaysFromToday: 0,
              maxDaysFromToday: 180,
              onChange: (v: string): void => { this.formDeadline = v }
            })
            TextInput({ text: this.formMinutes, placeholder: '每天阅读分钟数' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formMinutes = v })
            AppButton({
              label: this.submitting ? '保存中…' : '保存修改',
              disabled: this.submitting,
              onTap: (): void => { void this.saveEdit() }
            })
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
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
