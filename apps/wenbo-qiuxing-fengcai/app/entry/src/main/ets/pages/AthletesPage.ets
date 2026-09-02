import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { SportCategoryBar, SportCategoryKey } from '../components/sports/SportCategoryBar'
import { AthleteListCard } from '../components/sports/AthleteListCard'
import { AthleteItem } from '../models/StarModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'

@Component
export struct AthletesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @Prop embedded: boolean = false
  @State selectedCategory: SportCategoryKey = 'all'
  @State items: AthleteItem[] = []
  @State filtered: AthleteItem[] = []
  @State loading: boolean = true
  @State keyword: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private sportFilter(): string {
    if (this.selectedCategory === 'all') {
      return ''
    }
    return this.selectedCategory
  }

  private applyFilter(): void {
    const kw = this.keyword.trim().toLowerCase()
    if (kw.length === 0) {
      this.filtered = this.items
      return
    }
    const out: AthleteItem[] = []
    for (const item of this.items) {
      const hay = `${item.title}${item.team}${item.position}${item.summary}`.toLowerCase()
      if (hay.indexOf(kw) >= 0) {
        out.push(item)
      }
    }
    this.filtered = out
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await StarBizService.loadAthletes(this.sportFilter(), false)
    this.applyFilter()
    this.loading = false
  }

  build() {
    Column() {
      if (!this.embedded) {
        AppHeader({ title: '球星', subtitle: '搜索 · 分类 · 对比资料' })
      }
      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        TextInput({ text: this.keyword, placeholder: '搜索姓名、球队或位置' })
          .layoutWeight(1)
          .fontSize(Theme.type.body)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .onChange((v: string): void => {
            this.keyword = v
            this.applyFilter()
          })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      SportCategoryBar({
        selected: this.selectedCategory,
        onSelect: (key: SportCategoryKey): void => {
          this.selectedCategory = key
          void this.reload()
        }
      })
      .margin({ bottom: Theme.space.s3 })

      if (this.loading) {
        AppLoading({ label: '加载球星…' }).layoutWeight(1)
      } else if (this.filtered.length === 0) {
        AppEmpty({
          title: this.keyword.length > 0 ? '未找到匹配球星' : '暂无球星',
          description: '切换分类或修改搜索词',
          actionLabel: '刷新',
          onAction: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.filtered, (item: AthleteItem) => {
            ListItem() {
              AthleteListCard({
                item: item,
                onTap: (): void => { StarDetailNav.openAthlete(item.id) }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }, (item: AthleteItem) => item.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
