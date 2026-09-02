import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { NoteFieldCard } from '../note/NoteFieldCard'
import { OverlayShell } from './OverlayShell'
import { ReadingPlan } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct ReadingPlanEditorPane {
  @Prop planId: string = ''
  @State title: string = ''
  @State bookName: string = ''
  @State targetText: string = '10'
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.planId.length === 0) {
      const now = new Date()
      this.title = `${now.getMonth() + 1}月阅读计划`
      return
    }
    const found = await StudyStore.findPlan(this.planId)
    if (found === undefined) {
      return
    }
    this.title = found.title
    this.bookName = found.bookName
    this.targetText = `${found.targetCount}`
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private targetCount(): number {
    const n = Number.parseInt(this.targetText, 10)
    if (n !== n || n < 1) {
      return 10
    }
    return n > 100 ? 100 : n
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写计划标题')
      return
    }
    let plan: ReadingPlan
    if (this.planId.length > 0) {
      const found = await StudyStore.findPlan(this.planId)
      plan = found ?? ReadingPlan.createNew()
    } else {
      plan = ReadingPlan.createNew()
    }
    plan.title = this.title.trim()
    plan.bookName = this.bookName.trim()
    plan.targetCount = this.targetCount()
    await StudyStore.savePlan(plan)
    this.showToast('计划已保存')
    this.onSaved()
  }

  build() {
    Stack() {
      OverlayShell({
        title: this.planId.length > 0 ? '编辑计划' : '新建计划',
        onClose: (): void => { this.onClose() },
        body: (): void => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      NoteFieldCard({
        label: '计划标题 *',
        value: this.title,
        placeholder: '如：读完《XX》摘录 20 条',
        onChange: (v: string): void => { this.title = v }
      })
      NoteFieldCard({
        label: '关联书名（可选）',
        value: this.bookName,
        placeholder: '留空则统计本月全部摘录',
        onChange: (v: string): void => { this.bookName = v }
      })
      NoteFieldCard({
        label: '目标摘录条数 *',
        value: this.targetText,
        placeholder: '10',
        numberOnly: true,
        onChange: (v: string): void => { this.targetText = v }
      })
      AppButton({
        label: '保存计划',
        onTap: (): void => { void this.save() }
      })
    }
    .width('100%')
  }
}
