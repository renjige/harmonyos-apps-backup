import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { RecipeItem } from '../../models/SolarModels'
import { SolarRecipesBizService } from '../../services/SolarRecipesBizService'
import { SolarDetailNav } from '../../services/SolarDetailNav'
import { SolarMedia } from '../../services/SolarMedia'
import { AuthService } from '../../services/AuthService'
import { HistoryStore } from '../../services/HistoryStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct RecipeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecipeIdChange') recipeId: string = ''
  @Prop @Watch('onRecipeIdChange') refreshToken: number = 0
  @State item: RecipeItem | undefined = undefined
  @State loading: boolean = true
  @State favored: boolean = false
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRecipeIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await SolarRecipesBizService.findRecipe(this.recipeId)
    this.favored = await SolarRecipesBizService.isFavored(this.recipeId)
    this.loading = false
    if (this.item !== undefined) {
      await HistoryStore.push(this.item.id)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private current(): RecipeItem {
    if (this.item !== undefined) {
      return this.item
    }
    return new RecipeItem()
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    this.favored = await SolarRecipesBizService.toggleFavorite(this.item)
    this.showToast(this.favored ? '已收藏这道食谱' : '已取消收藏')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        AppLoading({ label: '正在打开食谱' })
      } else if (this.item === undefined) {
        Column() {
          AppEmpty({ title: '没有找到这道食谱', description: '返回食谱库再选一道', actionLabel: '返回', onAction: () => SolarDetailNav.close() })
        }
        .width('100%')
        .height('100%')
      } else {
        DetailShell({
          title: this.current().title,
          contentKey: this.recipeId,
          onClose: () => SolarDetailNav.close()
        }) {
          this.Body()
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#CC2C2420')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(SolarMedia.resource(this.current().coverKey))
          .width('100%')
          .height(240)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(96)
          .linearGradient({ direction: GradientDirection.Bottom, colors: [['#00000000', 0], ['#CC2C2420', 1]] })
        Text(this.current().title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
          .width('100%')
      }
      .width('100%')
      .clip(true)

      Column({ space: 6 }) {
        Text(this.current().metaLine())
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(`${CategoryEmojiUtil.markForIngredient(this.current().ingredientType)} ${this.current().ingredientType} · ${CategoryEmojiUtil.markForEffect(this.current().effect)} ${this.current().effect}${this.current().isVegetarian ? ' · 🥬 素食' : ''}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column({ space: 8 }) {
        Text('食养摘要')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.current().summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.current().body)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      this.LineList('食材', this.current().ingredients)
      this.StepList()

      Column({ space: 8 }) {
        Text('功效说明')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.current().healthBenefits.length > 0 ? this.current().healthBenefits : this.current().effect)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.current().suitableFor)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        AppButton({
          label: this.favored ? '取消收藏' : '收藏食谱',
          onTap: (): void => { void this.toggleFav() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  LineList(title: string, lines: string[]) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(lines, (line: string, idx: number) => {
        Text(`· ${line}`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }, (line: string, idx: number) => `${title}-${idx}`)
    }
    .padding(Theme.space.s4)
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  StepList() {
    Column({ space: 8 }) {
      Text('制作步骤')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.current().steps, (line: string, idx: number) => {
        Text(`${idx + 1}. ${line}`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }, (line: string, idx: number) => `st-${idx}`)
    }
    .padding(Theme.space.s4)
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}
