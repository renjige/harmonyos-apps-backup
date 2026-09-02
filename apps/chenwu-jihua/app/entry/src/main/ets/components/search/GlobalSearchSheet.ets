import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { CwTimelineRow } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'

class SearchKindLabels {
  static label(kind: string): string {
    if (kind === 'goal') {
      return '目标'
    }
    if (kind === 'plan') {
      return '计划'
    }
    if (kind === 'journal') {
      return '晨记'
    }
    if (kind === 'habit') {
      return '习惯'
    }
    return kind
  }
}

@Component
export struct GlobalSearchSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State rows: CwTimelineRow[] = []

  aboutToAppear(): void {
    void this.runSearch()
  }

  private async runSearch(): Promise<void> {
    this.rows = await ChenwuStore.searchAll(this.query)
  }

  private openRow(r: CwTimelineRow): void {
    ChenwuDetailNav.closeSearch()
    if (r.kind === 'goal') {
      ChenwuDetailNav.openGoal(r.sourceId)
      return
    }
    if (r.kind === 'plan') {
      ChenwuDetailNav.openPlan(r.sourceId)
      return
    }
    if (r.kind === 'journal') {
      ChenwuDetailNav.openJournal(r.sourceId)
      return
    }
    if (r.kind === 'habit') {
      ChenwuDetailNav.openHabit(r.sourceId)
    }
  }

  build() {
    DetailShell({ title: '搜索成长档案', onClose: (): void => { ChenwuDetailNav.closeSearch() } }) {
      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.query, placeholder: '目标、计划、晨记、习惯' })
          .onChange((v: string): void => {
            this.query = v
            void this.runSearch()
          })
          .height(44)
          .backgroundColor(Theme.colors().surfaceCard)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        if (this.rows.length === 0) {
          AppEmpty({ title: '没有匹配', description: '换个词，或先创建目标与计划' })
        } else {
          List() {
            ForEach(this.rows, (r: CwTimelineRow) => {
              ListItem() {
                Column({ space: 4 }) {
                  Text(r.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${SearchKindLabels.label(r.kind)} · ${r.dateKey}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 10, bottom: 10 })
                .onClick((): void => { this.openRow(r) })
              }
            }, (r: CwTimelineRow) => `${r.kind}_${r.id}`)
          }
          .layoutWeight(1)
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
