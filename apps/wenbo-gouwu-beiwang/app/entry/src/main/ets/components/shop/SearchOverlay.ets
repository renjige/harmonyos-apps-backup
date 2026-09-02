import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { SearchFilter, SearchHit } from '../../models/ShoppingModels'
import { GrowthService } from '../../services/GrowthService'
import { ShoppingCatalog } from '../../services/ShoppingCatalog'

@Component
export struct SearchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State keyword: string = ''
  @State hits: SearchHit[] = []
  @State status: string = 'all'
  @State tag: string = ''
  @State category: string = ''
  onClose: () => void = () => {}
  onOpenList: (id: string) => void = () => {}
  onOpenMemo: (id: string) => void = () => {}
  onOpenItem: (itemId: string, listId: string) => void = () => {}
  onOpenTopic: (id: string) => void = () => {}
  onAddLibrary: (title: string) => void = () => {}

  private runSearch(): void {
    const filter = new SearchFilter()
    filter.keyword = this.keyword
    filter.status = this.status
    filter.tag = this.tag
    filter.category = this.category
    this.hits = GrowthService.searchWithFilter(filter)
  }

  @Builder
  FilterChip(label: string, active: boolean, action: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(active ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .margin({ right: 6, bottom: 6 })
      .backgroundColor(active ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => action())
  }

  build() {
    Column() {
      Row() {
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('全局搜索')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      TextInput({ text: this.keyword, placeholder: '搜清单、物品、备忘、主题' })
        .height(44)
        .margin({ left: 20, right: 20, bottom: 8 })
        .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.lg)
        .padding({ left: 14, right: 14 })
        .onChange((v: string) => {
          this.keyword = v
          this.runSearch()
        })

      Scroll() {
        Column({ space: 8 }) {
          Text('状态')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            this.FilterChip('全部', this.status === 'all', (): void => {
              this.status = 'all'
              this.runSearch()
            })
            this.FilterChip('待购', this.status === 'pending', (): void => {
              this.status = 'pending'
              this.runSearch()
            })
            this.FilterChip('已购', this.status === 'done', (): void => {
              this.status = 'done'
              this.runSearch()
            })
          }
          .width('100%')

          Text('标签')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            this.FilterChip('不限', this.tag.length === 0, (): void => {
              this.tag = ''
              this.runSearch()
            })
            ForEach(ShoppingCatalog.itemTags(), (t: string) => {
              this.FilterChip(t, this.tag === t, (): void => {
                this.tag = t
                this.runSearch()
              })
            }, (t: string) => t)
          }
          .width('100%')

          Text('分类')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            this.FilterChip('不限', this.category.length === 0, (): void => {
              this.category = ''
              this.runSearch()
            })
            ForEach(ShoppingCatalog.listKinds(), (c: string) => {
              this.FilterChip(c, this.category === c, (): void => {
                this.category = c
                this.runSearch()
              })
            }, (c: string) => c)
          }
          .width('100%')
        }
        .padding({ left: 20, right: 20 })
      }
      .height(160)
      .scrollBar(BarState.Off)

      Scroll() {
        Column({ space: 8 }) {
          if (this.keyword.trim().length === 0 && this.status === 'all' &&
            this.tag.length === 0 && this.category.length === 0) {
            Text('输入关键词或选择筛选条件')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
              .padding({ left: 4, right: 4 })
          } else if (this.hits.length === 0) {
            AppEmpty({ title: '没有匹配结果', description: '换个关键词或筛选试试' })
          } else {
            ForEach(this.hits, (hit: SearchHit) => {
              Row() {
                Column({ space: 4 }) {
                  Text(hit.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(`${hit.kind} · ${hit.subtitle}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                    .maxLines(1)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => {
                if (hit.kind === 'list') {
                  this.onOpenList(hit.id)
                  return
                }
                if (hit.kind === 'memo') {
                  this.onOpenMemo(hit.id)
                  return
                }
                if (hit.kind === 'item') {
                  this.onOpenItem(hit.id, hit.listId)
                  return
                }
                if (hit.kind === 'topic') {
                  this.onOpenTopic(hit.id)
                  return
                }
                if (hit.kind === 'library') {
                  this.onAddLibrary(hit.title)
                }
              })
            }, (hit: SearchHit) => `${hit.kind}_${hit.id}`)
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
