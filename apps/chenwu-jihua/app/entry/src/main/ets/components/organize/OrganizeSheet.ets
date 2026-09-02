import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { CwOrganizeHint } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'

@Component
export struct OrganizeSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State hints: CwOrganizeHint[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.hints = await ChenwuStore.buildOrganizeHints()
  }

  private handleHint(h: CwOrganizeHint): void {
    ChenwuDetailNav.closeOrganize()
    if (h.actionKind === 'add_plan') {
      ChenwuDetailNav.openPlanEditor('')
      return
    }
    if (h.actionKind === 'add_task') {
      ChenwuStore.findPhase(h.targetId).then((ph) => {
        if (ph !== undefined) {
          ChenwuStore.findPlan(ph.planId).then((p) => {
            if (p !== undefined) {
              ChenwuDetailNav.openPlan(p.id)
            }
          })
        }
      })
      return
    }
    if (h.actionKind === 'habit_checkin') {
      ChenwuDetailNav.openHabitRecord(h.targetId)
      return
    }
    if (h.actionKind === 'phase_review') {
      ChenwuDetailNav.openReview(h.targetId)
      return
    }
    if (h.actionKind === 'journal_write') {
      ChenwuDetailNav.openJournalEditor('')
    }
  }

  build() {
    DetailShell({ title: '智慧整理', onClose: (): void => { ChenwuDetailNav.closeOrganize() } }) {
      if (this.hints.length === 0) {
        AppEmpty({ title: '一切就绪', description: '当前没有待整理项，继续保持' })
      } else {
        List() {
          ForEach(this.hints, (h: CwOrganizeHint) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(h.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(h.body)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Text('去处理')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 12 })
              .onClick((): void => { this.handleHint(h) })
            }
          }, (h: CwOrganizeHint) => `${h.actionKind}_${h.targetId}`)
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
  }
}
