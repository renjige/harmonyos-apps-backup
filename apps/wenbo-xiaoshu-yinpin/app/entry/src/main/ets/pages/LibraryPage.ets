import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { DrinkListCard } from '../components/drink/DrinkListCard'
import { DrinkItem } from '../models/DrinkModels'
import { DrinkBizService } from '../services/DrinkBizService'
import { DrinkDetailNav } from '../services/DrinkDetailNav'

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('libraryCategory') category: string = ''
  @State drinks: DrinkItem[] = []
  @State loading: boolean = true
  @State keyword: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.drinks = await DrinkBizService.loadDrinks()
    this.loading = false
  }

  private shown(): DrinkItem[] {
    const out: DrinkItem[] = []
    const q = this.keyword.trim()
    for (const d of this.drinks) {
      let ok = true
      if (this.category.length > 0 && d.category !== this.category) {
        ok = false
      }
      if (ok && q.length > 0) {
        let ings = ''
        for (const ing of d.ingredients) {
          ings += ing
        }
        const blob = `${d.title}${d.summary}${d.effect}${d.category}${ings}`
        if (blob.indexOf(q) < 0) {
          ok = false
        }
      }
      if (ok) {
        out.push(d)
      }
    }
    return out
  }

  private openDrink(id: string): void {
    DrinkDetailNav.openDrink(id)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('饮品库')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        TextInput({ text: this.keyword, placeholder: '搜名称、功效、分类' })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .placeholderColor(Theme.colors().textSecondary)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .caretColor(Theme.colors().brandPrimary)
          .onChange((v: string) => {
            this.keyword = v
          })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.Chip('全部', '')
          ForEach(DrinkBizService.categories(), (c: string) => {
            this.Chip(c, c)
          }, (c: string) => `c-${c}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      if (this.loading) {
        AppLoading({ label: '正在打开饮品库' })
      } else if (this.shown().length === 0) {
        AppEmpty({ title: '没有符合的饮品', description: '换个分类或关键词' })
      } else {
        Grid() {
          ForEach(this.shown(), (d: DrinkItem) => {
            GridItem() {
              DrinkListCard({
                drink: d,
                onOpen: (id: string): void => this.openDrink(id)
              })
            }
          }, (d: DrinkItem) => d.id)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Chip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.category === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.category === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.category = value
      })
  }
}
