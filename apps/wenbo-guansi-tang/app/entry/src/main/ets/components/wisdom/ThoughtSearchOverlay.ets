import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { ThoughtListCard } from './ThoughtListCard'
import { WisdomItem } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'

@Component
export struct ThoughtSearchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('whRefresh') @Watch('onRefresh') whRefresh: number = 0
  @State query: string = ''
  @State allItems: WisdomItem[] = []
  @State results: WisdomItem[] = []
  @State searched: boolean = false

  aboutToAppear(): void {
    void this.loadAll()
  }

  onRefresh(): void {
    if (this.searched) {
      void this.runSearch()
    }
  }

  private async loadAll(): Promise<void> {
    this.allItems = await WisdomHallBizService.loadThoughts()
  }

  private async runSearch(): Promise<void> {
    await this.loadAll()
    const q = this.query.trim()
    this.searched = true
    if (q.length === 0) {
      this.results = []
      return
    }
    const next: WisdomItem[] = []
    for (const n of this.allItems) {
      if (n.title.indexOf(q) >= 0 || n.body.indexOf(q) >= 0 || n.tags.indexOf(q) >= 0) {
        next.push(n)
      }
    }
    this.results = next
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
        .onClick((): void => { WisdomHallNav.closeSearch() })
        TextInput({ text: this.query, placeholder: '搜索笔记标题、正文或标签' })
          .layoutWeight(1)
          .onChange((v: string) => { this.query = v })
          .onSubmit(() => { void this.runSearch() })
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: 8 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (!this.searched) {
            Text('输入关键词后搜索你的笔记')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else if (this.results.length === 0) {
            AppEmpty({ title: '未找到匹配的笔记', description: '' })
          } else {
            ForEach(this.results, (item: WisdomItem) => {
              ThoughtListCard({
                itemId: item.id,
                title: item.title,
                summary: item.summaryLine(),
                category: item.category,
                coverKey: item.coverKey,
                onOpen: (): void => { WisdomHallNav.openDetail('thought', item.id) }
              })
            }, (item: WisdomItem) => item.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
