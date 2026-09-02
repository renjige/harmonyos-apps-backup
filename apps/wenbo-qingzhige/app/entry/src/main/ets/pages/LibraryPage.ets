import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CategoryChips } from '../components/knowledge/CategoryChips'
import { KnowledgeListCard } from '../components/knowledge/KnowledgeListCard'
import { KnowledgeItem } from '../models/KnowledgeModels'
import { KnowledgeStore } from '../services/KnowledgeStore'
import { KnowledgeNav } from '../services/KnowledgeNav'
import { CategorySuggest } from '../services/CategorySuggest'

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: KnowledgeItem[] = []
  @State filter: string = '全部'
  @State query: string = ''
  @State cats: string[] = CategorySuggest.filters()

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    let list = KnowledgeStore.byCategory(this.filter)
    if (this.query.trim().length > 0) {
      const q = this.query.trim()
      const next: KnowledgeItem[] = []
      for (const n of list) {
        if (n.title.indexOf(q) >= 0 || n.body.indexOf(q) >= 0 || n.tags.indexOf(q) >= 0 ||
          n.category.indexOf(q) >= 0) {
          next.push(n)
        }
      }
      list = next
    }
    this.items = list
  }

  build() {
    Column() {
      Row() {
        Text('知识库')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { KnowledgeNav.openWrite('') })
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { KnowledgeNav.openSearch() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      List({ space: Theme.space.s3 }) {
        ListItem() {
          TextInput({ text: this.query, placeholder: '搜索知识库' })
            .onChange((v: string) => {
              this.query = v
              this.reload()
            })
            .width('100%')
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        ListItem() {
          CategoryChips({
            selected: this.filter,
            options: this.cats,
            onSelect: (name: string) => {
              this.filter = name
              this.reload()
            }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX })

        ListItem() {
          Row() {
            Text('灵感记录')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { KnowledgeNav.openSparks() })
            Blank()
            Text('记下一条')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .onClick((): void => { KnowledgeNav.openWrite('') })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.items.length === 0) {
          ListItem() {
            AppEmpty({
              title: '你的轻知阁，正等待第一条内容。',
              description: '点右上角加号，轻轻记一条即可。',
              actionLabel: '记录一条知识',
              onAction: (): void => { KnowledgeNav.openWrite('') }
            })
          }
          .width('100%')
        } else {
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
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }, (item: KnowledgeItem) => item.id)
        }

        ListItem() {
          Column()
            .height(Theme.space.s10)
            .width('100%')
        }
      }
      .width('100%')
      .layoutWeight(1)
      .constraintSize({ minHeight: 0 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .constraintSize({ minHeight: 0 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
