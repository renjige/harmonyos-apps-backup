import { Theme } from '../design-system/Theme'
import { FeedItem } from '../../models/SilanModels'
import { SilanQuery } from '../../services/SilanQuery'
import { SilanNav } from '../../services/SilanNav'
import { FeedCardFromItem } from '../archive/FeedCard'
import { AppEmpty } from '../design-system/AppEmpty'

@Component
export struct GlobalSearchSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State results: FeedItem[] = []

  aboutToAppear(): void {
    void this.runSearch()
  }

  private async runSearch(): Promise<void> {
    this.results = await SilanQuery.search(this.query)
  }

  private openItem(it: FeedItem): void {
    SilanNav.closeSearch()
    if (it.kind === 'reading') {
      SilanNav.openReading(it.id)
      return
    }
    if (it.kind === 'card') {
      SilanNav.openCard(it.id)
      return
    }
    if (it.kind === 'spark') {
      SilanNav.openSpark(it.id)
      return
    }
    SilanNav.openThought(it.id)
  }

  build() {
    Column() {
      Row() {
        Text('搜索')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { SilanNav.closeSearch() })
      }
      .padding(Theme.space.s4)
      .width('100%')

      TextInput({ text: this.query, placeholder: '搜索标题、正文、标签' })
        .onChange((v: string) => { this.query = v; void this.runSearch() })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(Theme.colors().surfaceCard)

      if (this.results.length === 0) {
        AppEmpty({ title: '没有匹配的档案', description: '换个关键词，或先写下一条思考' })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.results, (it: FeedItem) => {
            ListItem() {
              FeedCardFromItem({ item: it, onTap: (): void => { this.openItem(it) } })
            }
            .padding({ bottom: Theme.space.s3 })
          }, (it: FeedItem) => `${it.kind}_${it.id}`)
        }
        .layoutWeight(1)
        .padding(Theme.space.pageX)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
