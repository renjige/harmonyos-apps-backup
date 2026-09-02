import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { QuoteListCard } from './QuoteListCard'
import { WisdomItem } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'

@Component
export struct QuoteSearchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State keyword: string = ''
  @State allQuotes: WisdomItem[] = []
  @State results: WisdomItem[] = []

  aboutToAppear(): void {
    void this.loadAll()
  }

  private async loadAll(): Promise<void> {
    this.allQuotes = await WisdomHallBizService.loadAllQuotes()
    this.search()
  }

  private search(): void {
    this.results = WisdomHallBizService.filterQuotes(this.allQuotes, '全部', this.keyword)
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
        .onClick((): void => { WisdomHallNav.closeQuoteSearch() })
        TextInput({ text: this.keyword, placeholder: '搜索语录或作者' })
          .layoutWeight(1)
          .height(44)
          .onChange((v: string) => {
            this.keyword = v
            this.search()
          })
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: 8 })

      if (this.results.length === 0) {
        AppEmpty({ title: '未找到相关语录', description: '试试其他关键词或作者名' })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.results, (item: WisdomItem) => {
            ListItem() {
              QuoteListCard({
                item: item,
                onOpen: (): void => {
                  WisdomHallNav.closeQuoteSearch()
                  WisdomHallNav.openDetail('quote', item.id)
                }
              })
            }
          }, (item: WisdomItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
