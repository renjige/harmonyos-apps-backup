import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CategoryTabBar } from '../components/wanxiang/CategoryTabBar'
import { InfoRowCard } from '../components/wanxiang/InfoRowCard'
import { KnowledgeListCard } from '../components/wanxiang/KnowledgeListCard'
import { InfoItem } from '../models/InfoModels'
import { UserKnowledge, Spark } from '../models/UserKnowledgeModels'
import { InfoRepository } from '../services/InfoRepository'
import { KnowledgeStore } from '../services/KnowledgeStore'
import { SparkStore } from '../services/SparkStore'
import { WanXiangDetailNav } from '../services/WanXiangDetailNav'
import { WanXiangNav } from '../services/WanXiangNav'

class LibraryFilter {
  key: string = 'all'
  label: string = '全部'

  static all(): LibraryFilter[] {
    const list: LibraryFilter[] = []
    const defs: string[][] = [
      ['all', '全部'],
      ['featured', '平台精选'],
      ['mine', '我的知识'],
      ['spark', '灵感']
    ]
    for (const d of defs) {
      const f = new LibraryFilter()
      f.key = d[0]
      f.label = d[1]
      list.push(f)
    }
    return list
  }
}

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('wanxiangTabIndex') @Watch('onTabVisible') mainTabIndex: number = 0
  @StorageLink('wanxiangStoreReady') @Watch('onStoreReady') storeReady: boolean = false
  @Prop bottomInset: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State filterKey: string = 'all'
  @State categoryKey: string = 'recommend'
  @State featuredItems: InfoItem[] = []
  @State knowledgeItems: UserKnowledge[] = []
  @State sparks: Spark[] = []
  @State loading: boolean = true
  private filters: LibraryFilter[] = LibraryFilter.all()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onTabVisible(): void {
    if (this.mainTabIndex === 1) {
      void this.reload()
    }
  }

  onStoreReady(): void {
    if (this.storeReady) {
      void this.reload()
    }
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.featuredItems = InfoRepository.filterByCategory(this.categoryKey)
    this.knowledgeItems = await KnowledgeStore.listAll()
    this.sparks = await SparkStore.listAll()
    this.loading = false
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('知识库')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('精选内容 + 你的个人知识')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => WanXiangNav.openSearch())
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.filters, (f: LibraryFilter) => {
              Text(f.label)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.filterKey === f.key ? '#FFFFFF' : Theme.colors().textPrimary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.filterKey === f.key ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.filterKey = f.key })
            }, (f: LibraryFilter) => f.key)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        if (this.filterKey === 'featured' || this.filterKey === 'all') {
          CategoryTabBar({
            selectedKey: this.categoryKey,
            onSelect: (key: string): void => {
              this.categoryKey = key
              this.featuredItems = InfoRepository.filterByCategory(key)
            }
          })
        }

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.filterKey === 'mine' || this.filterKey === 'all') {
              Text('我的知识')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')

              if (this.knowledgeItems.length === 0) {
                if (this.filterKey === 'mine') {
                  AppEmpty({
                    title: '还没有自建知识',
                    description: '从阅读中转化，或直接新建一条',
                    actionLabel: '新建知识',
                    onAction: (): void => WanXiangNav.openEditor()
                  })
                } else {
                  Text('暂无自建知识，点击右下角 + 新建')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                    .padding({ top: Theme.space.s1, bottom: Theme.space.s2 })
                }
              } else {
                ForEach(this.knowledgeItems, (k: UserKnowledge) => {
                  KnowledgeListCard({
                    item: k,
                    onTap: (): void => WanXiangNav.openKnowledge(k.id)
                  })
                }, (k: UserKnowledge) => k.id)
              }
            }

            if (this.filterKey === 'spark' || this.filterKey === 'all') {
              if (this.sparks.length > 0 || this.filterKey === 'spark') {
                Text('灵感记录')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                  .margin({ top: Theme.space.s2 })
              }
              if (this.sparks.length === 0 && this.filterKey === 'spark') {
                AppEmpty({
                  title: '还没有灵感',
                  description: '随时记下突然想到的观点',
                  actionLabel: '记一条灵感',
                  onAction: (): void => WanXiangNav.openSparkEditor()
                })
              }
              ForEach(this.sparks, (s: Spark) => {
                this.sparkRow(s)
              }, (s: Spark) => s.id)
            }

            if (this.filterKey === 'featured' || this.filterKey === 'all') {
              Text('平台精选')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .margin({ top: Theme.space.s2 })
              ForEach(this.featuredItems, (item: InfoItem) => {
                InfoRowCard({
                  item: item,
                  onTap: (): void => WanXiangDetailNav.open(item.id)
                })
              }, (item: InfoItem) => `lib-${item.id}`)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: this.bottomInset + 72
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: '#FFFFFF' })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .shadow({ radius: 16, color: 'rgba(0,122,255,0.35)', offsetY: 4 })
      .margin({ right: Theme.space.pageX, bottom: this.bottomInset + 16 })
      .onClick((): void => WanXiangNav.openEditor())
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  sparkRow(s: Spark) {
    Column({ space: 4 }) {
      Text(s.title.length > 0 ? s.title : '灵感')
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(s.body)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .maxLines(3)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
