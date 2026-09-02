import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { CategoryChips } from './CategoryChips'
import { KnowledgeListCard } from './KnowledgeListCard'
import { KnowledgeItem } from '../../models/KnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { KnowledgeNav } from '../../services/KnowledgeNav'
import { CategorySuggest } from '../../services/CategorySuggest'

@Component
export struct FavoritesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('knowledgeRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: KnowledgeItem[] = []
  @State filter: string = '全部'
  @State query: string = ''
  @State cats: string[] = CategorySuggest.filters()

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    let list = KnowledgeStore.favorites()
    if (this.filter !== '全部') {
      const filtered: KnowledgeItem[] = []
      for (const n of list) {
        if (n.category === this.filter) {
          filtered.push(n)
        }
      }
      list = filtered
    }
    if (this.query.trim().length > 0) {
      const q = this.query.trim()
      const filtered: KnowledgeItem[] = []
      for (const n of list) {
        if (n.title.indexOf(q) >= 0 || n.body.indexOf(q) >= 0) {
          filtered.push(n)
        }
      }
      list = filtered
    }
    this.items = list
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { KnowledgeNav.closeFavorites() })
        Text('我的收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: 8 })

      Text(`已收藏 ${KnowledgeStore.favorites().length} 条轻知`)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      TextInput({ text: this.query, placeholder: '搜索收藏' })
        .onChange((v: string) => {
          this.query = v
          this.reload()
        })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)

      Column() {
        CategoryChips({
          selected: this.filter,
          options: this.cats,
          onSelect: (name: string) => {
            this.filter = name
            this.reload()
          }
        })
      }
      .padding({ left: Theme.space.pageX, top: Theme.space.s3 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '喜欢的轻知，会在这里留下。',
          description: '读到值得记住的，轻轻点一下收藏。'
        })
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (item: KnowledgeItem) => {
            ListItem() {
              KnowledgeListCard({
                itemId: item.id,
                title: item.title,
                summary: item.summaryLine(),
                category: item.category,
                tags: item.tags,
                coverKey: item.coverKey,
                updatedAt: item.updatedAt,
                favorited: item.favorited,
                onOpen: (): void => { KnowledgeNav.openDetail(item.id) }
              })
            }
          }, (item: KnowledgeItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
