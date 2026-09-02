import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { QyTimelineRow } from '../../models/QyModels'
import { QyStore } from '../../services/QyStore'
import { QyDetailNav } from '../../services/QyDetailNav'

@Component
export struct GlobalSearchSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State rows: QyTimelineRow[] = []

  aboutToAppear(): void {
    void this.runSearch()
  }

  private async runSearch(): Promise<void> {
    this.rows = await QyStore.searchAll(this.query)
  }

  private openRow(r: QyTimelineRow): void {
    QyDetailNav.closeSearch()
    if (r.kind === 'clip') {
      QyDetailNav.openClip(r.id)
      return
    }
    QyDetailNav.openEntry(r.id)
  }

  build() {
    DetailShell({ title: '搜索档案', onClose: (): void => { QyDetailNav.closeSearch() } }) {
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
            ForEach(this.rows, (r: QyTimelineRow) => {
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
            }, (r: QyTimelineRow) => `${r.kind}_${r.id}`)
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
