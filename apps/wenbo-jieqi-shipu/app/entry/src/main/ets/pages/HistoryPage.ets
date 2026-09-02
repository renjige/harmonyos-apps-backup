import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { RecipeItem } from '../models/SolarModels'
import { SolarRecipesBizService } from '../services/SolarRecipesBizService'
import { SolarDetailNav } from '../services/SolarDetailNav'
import { SolarMedia } from '../services/SolarMedia'
import { HistoryStore } from '../services/HistoryStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct HistoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: RecipeItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const all = await SolarRecipesBizService.loadRecipes()
    const ids = HistoryStore.ids()
    const out: RecipeItem[] = []
    for (const id of ids) {
      for (const r of all) {
        if (r.id === id) {
          out.push(r)
        }
      }
    }
    this.items = out
    this.loading = false
  }

  build() {
    DetailShell({
      title: '浏览历史',
      contentKey: `${this.items.length}`,
      onClose: () => SolarDetailNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        if (this.loading) {
          AppLoading({ label: '正在打开历史' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有浏览记录',
            description: '打开一道食谱详情后会出现在这里',
            emojiMark: '🕐',
            iconName: 'clock',
            actionLabel: '去食谱库',
            onAction: (): void => {
              SolarDetailNav.close()
              AppStorage.setOrCreate('switchTabIndex', 1)
            }
          })
        } else {
          ForEach(this.items, (r: RecipeItem) => {
            Row({ space: Theme.space.s3 }) {
              Image(SolarMedia.resource(r.coverKey))
                .width(64)
                .height(64)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 4 }) {
                Text(r.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .width('100%')
                Text(`${CategoryEmojiUtil.markForSolarTerm(r.solarTerm)} ${r.solarTerm}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => SolarDetailNav.openRecipe(r.id))
          }, (r: RecipeItem) => r.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
