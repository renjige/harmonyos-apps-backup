import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppLoading } from '../components/design-system/AppLoading'
import {
  CategoryChip,
  InspirationItem
} from '../models/LanguageCraftModels'
import { LanguageCraftBizService } from '../services/LanguageCraftBizService'
import { LanguageCraftMedia } from '../services/LanguageCraftMedia'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { FavoriteStore } from '../services/FavoriteStore'
import { HubStore } from '../services/HubStore'

@Component
export struct InspirePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onFavRefresh') favRefreshToken: number = 0
  @State items: InspirationItem[] = []
  @State loading: boolean = true
  @State errorText: string = ''
  @State category: string = ''
  @State favSet: string = ''
  private categories: CategoryChip[] = LanguageCraftBizService.categoryChips()

  aboutToAppear(): void {
    void this.load()
  }

  onFavRefresh(): void {
    void this.refreshFavorites()
  }

  private async load(): Promise<void> {
    this.loading = true
    this.errorText = ''
    this.items = await LanguageCraftBizService.loadInspirations(this.category)
    if (this.items.length === 0) {
      this.errorText = '暂无灵感范例，请稍后重试'
    }
    await this.refreshFavorites()
    this.loading = false
  }

  private async refreshFavorites(): Promise<void> {
    const favs = await FavoriteStore.list()
    const ids: string[] = []
    for (const f of favs) {
      ids.push(f.inspirationId)
    }
    this.favSet = ids.join('|')
  }

  private isFav(id: string): boolean {
    return this.favSet.indexOf(id) >= 0
  }

  private async toggleFav(item: InspirationItem): Promise<void> {
    const wasFav = await FavoriteStore.isFavorited(item.id)
    await FavoriteStore.toggle(item)
    if (!wasFav) {
      await HubStore.recordFavorite(item.title, item.id)
    }
    await this.refreshFavorites()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.categories, (chip: CategoryChip) => {
            Column() {
              Text(chip.label)
                .fontSize(Theme.type.footnote)
                .fontColor(this.category === chip.key ?
                  Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
            }
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .constraintSize({ minHeight: 40 })
            .backgroundColor(this.category === chip.key ?
              Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => {
              this.category = chip.key
              void this.load()
            })
          }, (chip: CategoryChip) => chip.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Text('点卡片看范例与说明；详情里可「套用到润色台」改写成自己的稿。')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.of(this.darkModeOn).textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')

      if (this.loading) {
        AppLoading({ label: '加载灵感…' })
          .layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '暂无内容',
          description: this.errorText.length > 0 ? this.errorText : '换个分类试试'
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: InspirationItem) => {
              Row({ space: Theme.space.s3 }) {
                Image(LanguageCraftMedia.cover(item.coverKey))
                  .width(88)
                  .height(88)
                  .borderRadius(Theme.radius.md)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(item.category)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).brandAccent)
                    .width('100%')
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .maxLines(2)
                    .width('100%')
                  Text(item.summary)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Column() {
                  AppIcon({
                    name: 'heart',
                    iconSize: Theme.icon.md,
                    color: this.isFav(item.id) ? Theme.of(this.darkModeOn).danger : Theme.of(this.darkModeOn).textSecondary
                  })
                }
                .width(36)
                .height(36)
                .justifyContent(FlexAlign.Center)
                .onClick((): void => {
                  void this.toggleFav(item)
                })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              .onClick((): void => {
                LanguageCraftNav.openDetail(item.id)
              })
            }, (item: InspirationItem) => item.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }
}
