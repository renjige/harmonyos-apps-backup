import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { TreasureEmpty } from '../components/treasure/TreasureEmpty'
import { TreasureListCard } from '../components/treasure/TreasureListCard'
import { CategoryItem, TreasureItem } from '../models/TreasureModels'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct CollectionPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State items: TreasureItem[] = []
  @State categories: CategoryItem[] = []
  @State filterId: string = ''
  @State total: number = 0
  @State organized: number = 0
  @State avgComplete: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.categories = TreasureStore.categories()
    this.items = TreasureStore.filteredItems(this.filterId)
    this.total = TreasureStore.activeItems().length
    this.organized = TreasureStore.organizedCount()
    this.avgComplete = TreasureStore.avgCompleteness()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Column({ space: Theme.space.s1 }) {
            Text('珍藏空间')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('记录每一件值得留下的物品')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Column() {
            AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
          }
          .width(44)
          .height(44)
          .borderRadius(Theme.radius.pill)
          .backgroundColor(Theme.colors().brandPrimary)
          .justifyContent(FlexAlign.Center)
          .onClick(() => TreasureNav.openEditor(''))
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Stack({ alignContent: Alignment.TopStart }) {
          Image($r('app.media.hero_archive'))
            .width('100%')
            .height(160)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
          Column({ space: Theme.space.s2 }) {
            Text('我的珍藏')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(`${this.total} 件`)
              .fontSize(Theme.type.display)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            Text(`${this.categories.length} 个分类 · 档案完整度 ${this.avgComplete}%`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
          }
          .width('100%')
          .height(160)
          .padding(Theme.space.s5)
          .linearGradient({
            angle: 180,
            colors: [['rgba(23,23,23,0.05)', 0], ['rgba(23,23,23,0.72)', 1]]
          })
          .borderRadius(Theme.radius.xl)
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.FilterChip('全部', '')
            ForEach(this.categories, (c: CategoryItem) => {
              this.FilterChip(c.name, c.id)
            }, (c: CategoryItem) => c.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        if (this.items.length === 0) {
          TreasureEmpty({
            onAction: (): void => { TreasureNav.openEditor('') }
          })
        } else {
          GridRow({ columns: 2, gutter: Theme.space.s3 }) {
            ForEach(this.items, (item: TreasureItem) => {
              GridCol({ span: 1 }) {
                TreasureListCard({
                  item: item,
                  onTap: (): void => { TreasureNav.openDetail(item.id) }
                })
              }
            }, (item: TreasureItem) => item.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  FilterChip(label: string, id: string) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(this.filterId === id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.filterId === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick(() => {
        this.filterId = id
        this.items = TreasureStore.filteredItems(this.filterId)
      })
  }
}
