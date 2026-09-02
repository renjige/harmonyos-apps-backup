import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecipeCover } from '../components/kitchen/RecipeCover'
import { RecipeMatch } from '../models/KitchenModels'
import { KitchenStore } from '../services/KitchenStore'

@Component
export struct IdeaResultPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selected: string = ''
  @Prop refreshToken: number = 0
  onClose: () => void = () => {}
  onOpenRecipe: (id: string) => void = (_id: string) => {}

  private parts(): string[] {
    const out: string[] = []
    if (this.selected.length === 0) return out
    for (const p of this.selected.split(',')) {
      if (p.trim().length > 0) out.push(p.trim())
    }
    return out
  }

  private results(): RecipeMatch[] {
    return KitchenStore.matches(this.parts())
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.onClose())
        Column({ space: 2 }) {
          Text('今日妙想')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`根据 ${this.selected} 为你挑选`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.results().length === 0) {
            AppEmpty({
              title: '暂时没有合适搭配',
              description: '换几样食材试试，会有更多厨房灵感。'
            })
          } else {
            ForEach(this.results(), (item: RecipeMatch) => {
              this.ResultCard(item)
            }, (item: RecipeMatch) => item.recipe.id)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  ResultCard(item: RecipeMatch) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        RecipeCover({
          coverKey: item.recipe.coverKey,
          title: '',
          imageHeight: 104,
          rounded: Theme.radius.lg
        })
      }
      .width(120)
      Column({ space: Theme.space.s2 }) {
        Text(item.recipe.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
        Text(`匹配食材：${item.matchedIngredients.join('、')}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .maxLines(1)
        Text(`${item.recipe.timeText} · ${item.recipe.difficulty}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(item.reason)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(18)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onOpenRecipe(item.recipe.id))
  }
}
