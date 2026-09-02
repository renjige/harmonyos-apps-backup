import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CwPhase, CwPhaseReview } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'

@Component
export struct PhaseReviewSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwReviewPhaseId') phaseId: string = ''
  onChanged: () => void = () => {}
  @State phase: CwPhase = new CwPhase()
  @State harvest: string = ''
  @State problems: string = ''
  @State nextSteps: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    const found = await ChenwuStore.findPhase(this.phaseId)
    if (found !== undefined) {
      this.phase = found
    }
    const existing = await ChenwuStore.reviewForPhase(this.phaseId)
    if (existing !== undefined) {
      this.harvest = existing.harvest
      this.problems = existing.problems
      this.nextSteps = existing.nextSteps
    }
  }

  private async save(): Promise<void> {
    if (this.harvest.trim().length === 0) {
      this.toastText = '请填写阶段收获'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let r = CwPhaseReview.createNew(this.phaseId)
    const existing = await ChenwuStore.reviewForPhase(this.phaseId)
    if (existing !== undefined) {
      r = existing
    }
    r.harvest = this.harvest
    r.problems = this.problems
    r.nextSteps = this.nextSteps
    await ChenwuStore.saveReview(r)
    this.onChanged()
    ChenwuDetailNav.closeReview()
  }

  build() {
    Stack() {
      DetailShell({ title: '阶段复盘', onClose: (): void => { ChenwuDetailNav.closeReview() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(this.phase.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.harvest, placeholder: '本阶段收获' })
              .onChange((v: string): void => { this.harvest = v })
              .height(80)
            TextArea({ text: this.problems, placeholder: '遇到的问题（可选）' })
              .onChange((v: string): void => { this.problems = v })
              .height(80)
            TextArea({ text: this.nextSteps, placeholder: '下一步行动（可选）' })
              .onChange((v: string): void => { this.nextSteps = v })
              .height(80)
            AppButton({ label: '保存复盘', onTap: (): void => { void this.save() } })
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
}
