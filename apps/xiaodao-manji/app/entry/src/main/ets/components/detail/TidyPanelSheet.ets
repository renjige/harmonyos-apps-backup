import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { XdTidySuggestion } from '../../models/XdModels'
import { XdStore } from '../../services/XdStore'
import { XdDetailNav } from '../../services/XdDetailNav'

@Component
export struct TidyPanelSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('xdDataRev') @Watch('onDataRev') dataRev: number = 0
  @State suggestions: XdTidySuggestion[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.suggestions = await XdStore.buildTidySuggestions()
  }

  private openSuggestion(s: XdTidySuggestion): void {
    if (s.actionKind === 'entry' && s.targetId.length > 0) {
      XdDetailNav.closeTidyPanel()
      XdDetailNav.openEntry(s.targetId)
      return
    }
    if (s.actionKind === 'journal_inbox') {
      XdDetailNav.closeTidyPanel()
      AppStorage.setOrCreate('xdJumpJournalInbox', true)
      AppStorage.setOrCreate('xdActiveTab', 1)
    }
  }

  build() {
    DetailShell({ title: '智慧整理', onClose: (): void => { XdDetailNav.closeTidyPanel() } }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('根据已有记录给出的整理建议，不含生成式 AI')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          if (this.suggestions.length === 0) {
            AppEmpty({ title: '暂无整理建议', description: '继续记录，有待分类内容时会出现在这里' })
          } else {
            ForEach(this.suggestions, (s: XdTidySuggestion) => {
              Column({ space: 4 }) {
                Text(s.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(s.hint)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openSuggestion(s) })
            }, (s: XdTidySuggestion) => s.id)
          }
          Column().height(Theme.space.s10)
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
  }
}
