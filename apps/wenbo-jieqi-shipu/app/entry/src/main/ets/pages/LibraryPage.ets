import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecipeListCard } from '../components/recipe/RecipeListCard'
import { RecipeListRow } from '../components/recipe/RecipeListRow'
import { RecipeItem, RecipeFilter, TermItem } from '../models/SolarModels'
import { SolarRecipesBizService } from '../services/SolarRecipesBizService'
import { SolarDetailNav } from '../services/SolarDetailNav'
import { PreferencesStore } from '../services/PreferencesStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('librarySolarTermId') solarTermId: string = ''
  @StorageLink('libraryIngredientType') ingredientType: string = ''
  @StorageLink('libraryEffect') effect: string = ''
  @State recipes: RecipeItem[] = []
  @State termChips: TermItem[] = []
  @State loading: boolean = true
  @State keyword: string = ''
  @State cardView: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (this.termChips.length === 0) {
      this.termChips = await SolarRecipesBizService.loadTerms()
    }
    const filter = new RecipeFilter()
    if (this.solarTermId.length > 0) {
      filter.solarTermId = this.solarTermId
    }
    if (this.ingredientType.length > 0) {
      filter.ingredientType = this.ingredientType
    }
    if (this.effect.length > 0) {
      filter.effect = this.effect
    }
    const kw = this.keyword.trim()
    if (kw.length > 0) {
      filter.q = kw
    }
    this.recipes = await SolarRecipesBizService.loadRecipes(filter)
    this.loading = false
  }

  private shown(): RecipeItem[] {
    const out: RecipeItem[] = []
    for (const r of this.recipes) {
      let ok = true
      if (PreferencesStore.vegetarianOnly() && !r.isVegetarian) {
        ok = false
      }
      if (ok) {
        out.push(r)
      }
    }
    return out
  }

  private openRecipe(id: string): void {
    SolarDetailNav.openRecipe(id)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(40)
            .height(40)
            .linearGradient({
              angle: 135,
              colors: [[Theme.colors().brandPrimary, 0], [Theme.colors().brandAccent, 1]]
            })
            .borderRadius(12)
          AppIcon({ name: 'book', iconSize: Theme.icon.sm, color: Theme.colors().brandOnPrimary })
        }
        Column({ space: 2 }) {
          Text('📖 食谱库')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('按节气 · 食材 · 功效筛选')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Row({ space: 0 }) {
          Column() {
            AppIcon({
              name: 'grid',
              iconSize: Theme.icon.sm,
              color: this.cardView ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
            })
          }
          .width(36)
          .height(32)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.cardView ? Theme.colors().brandPrimary : Color.Transparent)
          .borderRadius({ topLeft: 8, bottomLeft: 8 })
          .onClick((): void => { this.cardView = true })
          Column() {
            AppIcon({
              name: 'list',
              iconSize: Theme.icon.sm,
              color: !this.cardView ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
            })
          }
          .width(36)
          .height(32)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(!this.cardView ? Theme.colors().brandPrimary : Color.Transparent)
          .borderRadius({ topRight: 8, bottomRight: 8 })
          .onClick((): void => { this.cardView = false })
        }
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .borderRadius(8)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        TextInput({ text: this.keyword, placeholder: '搜名称、食材、功效' })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .placeholderColor(Theme.colors().textSecondary)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .caretColor(Theme.colors().brandPrimary)
          .onChange((v: string) => {
            this.keyword = v
          })
          .onSubmit(() => { void this.reload() })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.Chip(CategoryEmojiUtil.chipLabelSolarTerm('全部'), '')
          ForEach(this.termChips, (t: TermItem) => {
            Text(CategoryEmojiUtil.chipLabelSolarTerm(t.title))
              .fontSize(Theme.type.caption)
              .fontColor(this.solarTermId === t.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.solarTermId === t.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                this.solarTermId = t.id
                void this.reload()
              })
          }, (t: TermItem) => t.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.IngChip(CategoryEmojiUtil.chipLabelIngredient('全部食材'), '')
          ForEach(SolarRecipesBizService.ingredientTypes(), (t: string) => {
            this.IngChip(CategoryEmojiUtil.chipLabelIngredient(t), t)
          }, (t: string) => `i-${t}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.EffChip(CategoryEmojiUtil.chipLabelEffect('全部功效'), '')
          ForEach(SolarRecipesBizService.effects(), (e: string) => {
            this.EffChip(CategoryEmojiUtil.chipLabelEffect(e), e)
          }, (e: string) => `e-${e}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      if (this.loading) {
        AppLoading({ label: '正在打开食谱库' })
      } else if (this.shown().length === 0) {
        AppEmpty({
          title: '没有符合的食谱',
          description: '换个筛选或关键词试试',
          actionLabel: '重试',
          emojiMark: '🥗',
          iconName: 'search',
          onAction: (): void => { void this.reload() }
        })
      } else if (this.cardView) {
        Grid() {
          ForEach(this.shown(), (r: RecipeItem) => {
            GridItem() {
              RecipeListCard({
                recipe: r,
                onOpen: (id: string): void => this.openRecipe(id)
              })
            }
          }, (r: RecipeItem) => r.id)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        .edgeEffect(EdgeEffect.Spring)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.shown(), (r: RecipeItem) => {
            ListItem() {
              RecipeListRow({
                recipe: r,
                onOpen: (id: string): void => this.openRecipe(id)
              })
            }
          }, (r: RecipeItem) => r.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
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
      .fontColor(this.solarTermId === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.solarTermId === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.solarTermId = value
        void this.reload()
      })
  }

  @Builder
  IngChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.ingredientType === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.ingredientType === value ? Theme.colors().brandAccent : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.ingredientType = value
        void this.reload()
      })
  }

  @Builder
  EffChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.effect === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.effect === value ? Theme.colors().brandDeep : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.effect = value
        void this.reload()
      })
  }
}
