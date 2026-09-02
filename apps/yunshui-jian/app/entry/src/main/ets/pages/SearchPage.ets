import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { YunNoteCard } from '../components/yun/YunNoteCard'
import { YunNoteItem } from '../models/YunModels'
import { YunLocalStore } from '../services/YunLocalStore'
import { YunDetailNav } from '../services/YunDetailNav'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State query: string = ''
  @State results: YunNoteItem[] = []

  aboutToAppear(): void {
    void this.search()
  }

  onRefreshChange(): void {
    if (this.refreshToken > 0) {
      void this.search()
    }
  }

  private async search(): Promise<void> {
    this.results = await YunLocalStore.searchNotes(this.query)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { YunDetailNav.closeSearch() })
        TextInput({ text: this.query, placeholder: '搜索札记、标签…' })
          .layoutWeight(1)
          .height(44)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .caretColor(Theme.colors().brandDeep)
          .backgroundColor('#FFFFFF')
          .borderRadius(Theme.radius.sm)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => {
            this.query = v
            void this.search()
          })
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.results.length === 0) {
            AppEmpty({
              title: '未找到匹配札记',
              description: '试试其他关键词，或创建新札记',
              actionLabel: '新建札记',
              onAction: (): void => {
                YunDetailNav.closeSearch()
                YunDetailNav.openNoteEditor('')
              }
            })
          } else {
            Text(`共 ${this.results.length} 条结果`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
            ForEach(this.results, (note: YunNoteItem) => {
              YunNoteCard({
                note: note,
                onTap: (): void => { YunDetailNav.openNote(note.id) }
              })
            }, (note: YunNoteItem) => note.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
