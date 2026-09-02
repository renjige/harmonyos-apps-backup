import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { CategoryChips } from '../components/common/CategoryChips'
import { NewsRow } from '../components/common/NewsRow'
import { ContentService } from '../services/ContentService'
import { NewsItem, CategoryTab } from '../models/ZhukeModels'
import { AppEmpty } from '../components/design-system/AppEmpty'

@Component
export struct NewsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State category: string = 'all'
  @State news: NewsItem[] = []
  @State tabs: CategoryTab[] = []
  @Prop @Watch('onContentVersionChange') contentVersion: number = 0
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.tabs = ContentService.newsCategories()
    this.reload()
  }

  private reload(): void {
    this.news = ContentService.news(this.category)
  }

  onContentVersionChange(): void {
    this.reload()
  }

  build() {
    Column() {
      AppHeader({ title: '新闻资讯', subtitle: '企业动态 · 行业资讯 · 通知公告' })
      CategoryChips({
        tabs: this.tabs,
        selected: this.category,
        onSelect: (key: string) => {
          this.category = key
          this.reload()
        }
      })
      .margin({ bottom: Theme.space.s3 })

      if (this.news.length === 0) {
        AppEmpty({ title: '暂无资讯', description: '请稍后再来查看' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.news, (n: NewsItem) => {
              NewsRow({
                item: n,
                onTap: () => this.onOpenDetail(n.id)
              })
            }, (n: NewsItem) => n.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s8
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
