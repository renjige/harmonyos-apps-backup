import { DailyPromptPane } from './DailyPromptPane'
import { WeekReviewPane } from './WeekReviewPane'
import { JudgmentBoardPane } from './JudgmentBoardPane'
import { RecallPane } from './RecallPane'
import { QuoteWallPane } from './QuoteWallPane'

@Component
export struct InsightToolHost {
  @Prop toolKind: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onMutated: () => void = () => {}

  build() {
    if (this.toolKind === 'prompt') {
      DailyPromptPane({
        onClose: (): void => { this.onClose() },
        onSaved: (): void => { this.onSaved() }
      })
    } else if (this.toolKind === 'week') {
      WeekReviewPane({
        onClose: (): void => { this.onClose() },
        onSaved: (): void => { this.onSaved() }
      })
    } else if (this.toolKind === 'judgment') {
      JudgmentBoardPane({
        onClose: (): void => { this.onClose() },
        onOpen: (id: string) => { this.onOpen(id) },
        onMutated: (): void => { this.onMutated() }
      })
    } else if (this.toolKind === 'recall') {
      RecallPane({
        onClose: (): void => { this.onClose() },
        onOpen: (id: string) => { this.onOpen(id) },
        onMutated: (): void => { this.onMutated() }
      })
    } else if (this.toolKind === 'quotes') {
      QuoteWallPane({
        onClose: (): void => { this.onClose() },
        onOpen: (id: string) => { this.onOpen(id) }
      })
    } else {
      Column()
    }
  }
}
