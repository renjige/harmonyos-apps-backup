import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DestCard } from '../components/scenic/DestCard'
import { CatChip, DestItem } from '../models/ScenicModels'
import { ScenicBizService } from '../services/ScenicBizService'
import { ScenicDetailNav } from '../services/ScenicDetailNav'

@Component
export struct ExplorePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State dests: DestItem[] = []
  @State filtered: DestItem[] = []
  @State cat: string = 'all'
  @State query: string = ''
  private chips: CatChip[] = ExplorePage.makeChips()

  private static makeChips(): CatChip[] {
    const out: CatChip[] = []
    out.push(CatChip.of('all', '全部'))
    out.push(CatChip.of('nature', '自然风光'))
    out.push(CatChip.of('history', '人文历史'))
    out.push(CatChip.of('food', '美食之旅'))
    out.push(CatChip.of('city', '城市漫步'))
    return out
  }

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.dests = await ScenicBizService.loadDestinations()
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    let list = ScenicBizService.filterByCategory(this.dests, this.cat)
    list = ScenicBizService.searchDest(list, this.query)
    this.filtered = list
  }

  build() {
    Column() {
      Text('探索')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 4 })

      TextInput({ text: this.query, placeholder: '搜索目的地 / 城市' })
        .onChange((v: string) => {
          this.query = v
          this.applyFilter()
        })
        .height(44)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .padding({ left: 16, right: 16 })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.chips, (c: CatChip) => {
            Text(c.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.cat === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.cat === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                this.cat = c.id
                this.applyFilter()
              })
          }, (c: CatChip) => c.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(44)

      if (this.loading) {
        AppLoading({ label: '正在打开目的地库' }).layoutWeight(1)
      } else if (this.filtered.length === 0) {
        AppEmpty({
          title: '没有匹配的目的地',
          description: '换个分类或关键词试试',
          actionLabel: '重试',
          onAction: () => { void this.reload() }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Grid() {
            ForEach(this.filtered, (d: DestItem) => {
              GridItem() {
                DestCard({
                  item: d,
                  onTap: () => ScenicDetailNav.openDest(d.id)
                })
              }
            }, (d: DestItem) => d.id)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
