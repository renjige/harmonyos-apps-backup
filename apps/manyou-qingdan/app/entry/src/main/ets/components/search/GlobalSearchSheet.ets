import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { RmTimelineRow } from '../../models/RmModels'
import { RmStore } from '../../services/RmStore'
import { RmDetailNav } from '../../services/RmDetailNav'

@Component
export struct GlobalSearchSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State rows: RmTimelineRow[] = []

  aboutToAppear(): void {
    void this.runSearch()
  }

  private async runSearch(): Promise<void> {
    this.rows = await RmStore.searchAll(this.query)
  }

  private openRow(r: RmTimelineRow): void {
    RmDetailNav.closeSearch()
    if (r.kind === 'clip') {
      RmDetailNav.openWish(r.id)
      return
    }
    RmDetailNav.openChecklist(r.id)
  }

  build() {
    DetailShell({ title: '搜索档案', onClose: (): void => { RmDetailNav.closeSearch() } }) {
      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.query, placeholder: '标题、内容、标签、日期' })
          .onChange((v: string): void => {
            this.query = v
            void this.runSearch()
          })
          .height(44)
          .backgroundColor(Theme.colors().surfaceCard)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        if (this.rows.length === 0) {
          AppEmpty({ title: '没有匹配', description: '换个词，或先写下一条片段' })
        } else {
          List() {
            ForEach(this.rows, (r: RmTimelineRow) => {
              ListItem() {
                Column({ space: 4 }) {
                  Text(r.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${r.kind === 'clip' ? '观察' : '记录'} · ${r.dateKey}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 10, bottom: 10 })
                .onClick((): void => { this.openRow(r) })
              }
            }, (r: RmTimelineRow) => `${r.kind}_${r.id}`)
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
