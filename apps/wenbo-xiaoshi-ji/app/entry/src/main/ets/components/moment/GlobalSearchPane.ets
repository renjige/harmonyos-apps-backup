import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { SearchHit } from '../../models/MomentModels'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct GlobalSearchPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State hits: SearchHit[] = []

  private async runSearch(): Promise<void> {
    this.hits = await MomentStore.searchAll(this.query)
  }

  private openHit(h: SearchHit): void {
    if (h.kind === 'note') {
      MomentNav.openNote(h.refId)
    } else if (h.kind === 'todo') {
      MomentNav.openTodo(h.refId)
    } else if (h.kind === 'plan') {
      MomentNav.openPlan(h.refId)
    }
  }

  build() {
    DetailShell({ title: '搜索', onClose: (): void => MomentNav.close() }) {
      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.query, placeholder: '搜索小事、待办、计划…' })
          .width('100%')
          .onChange((v: string): void => {
            this.query = v
            void this.runSearch()
          })
        if (this.query.trim().length === 0) {
          AppEmpty({ title: '输入关键词', description: '可搜索记录正文、标签、待办与计划' })
        } else if (this.hits.length === 0) {
          AppEmpty({ title: '没有匹配结果', description: '换个关键词试试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.hits, (h: SearchHit) => {
                Column({ space: 4 }) {
                  Text(h.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                  Text(h.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(12)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(12)
                .onClick((): void => this.openHit(h))
              }, (h: SearchHit) => `${h.kind}_${h.refId}`)
            }
            .width('100%')
          }
          .layoutWeight(1)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2, bottom: Theme.space.s10 })
      .width('100%')
      .height('100%')
    }
  }
}
