import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { RenoDates, RenoSuggestion, RenoTask } from '../../models/RenoModels'
import { RenoService } from '../../services/RenoService'
import { RenoMedia } from '../../services/RenoMedia'

@Component
export struct SuggestionDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoSuggestion = new RenoSuggestion()
  @State toast: string = ''
  onClose: () => void = () => {}
  onAdded: () => void = () => {}
  onNeedProject: () => void = () => {}

  private async add(): Promise<void> {
    const current = RenoService.currentProject()
    if (current === null) {
      this.onNeedProject()
      return
    }
    const draft = new RenoTask()
    draft.title = this.item.title
    draft.stage = this.item.category.length > 0 ? this.item.category : current.stage
    draft.status = 'todo'
    draft.date = RenoDates.today()
    draft.remark = this.item.summary
    draft.projectId = current.id
    await RenoService.saveTask(draft, false)
    this.toast = '已加入事项'
    setTimeout(() => { this.toast = '' }, 1600)
    this.onAdded()
  }

  build() {
    Stack() {
      DetailShell({
        title: this.item.title,
        coverKey: RenoMedia.coverKeyForSuggestion(this.item.id, this.item.coverKey),
        onBack: () => this.onClose()
      }) {
        Column({ space: Theme.space.s4 }) {
          Text(this.item.category)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Column({ space: 8 }) {
            Text(this.item.summary)
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          AppButton({ label: '加入当前项目事项', onTap: () => { void this.add() } })
        }
        .width('100%')
      }
      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().success)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
