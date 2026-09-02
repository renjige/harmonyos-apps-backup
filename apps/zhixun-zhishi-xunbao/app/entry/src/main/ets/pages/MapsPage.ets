import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppError } from '../components/design-system/AppError'
import { MapGridCard } from '../components/quest/QuestCards'
import { CatChip, QuestMap } from '../models/QuestModels'
import { QuestBizService } from '../services/QuestBizService'
import { QuestNav } from '../services/QuestNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct MapsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State maps: QuestMap[] = []
  @State chips: CatChip[] = []
  @State category: string = 'all'
  @State loading: boolean = true
  @State failed: boolean = false
  @StorageLink('questTick') tick: number = 0

  aboutToAppear(): void {
    this.chips = MapsPage.buildChips()
    void this.reload()
  }

  static buildChips(): CatChip[] {
    const ids: string[] = ['all', 'history', 'science', 'culture', 'nature', 'life']
    const labels: string[] = ['全部', '历史探秘', '科学发现', '文化艺术', '自然奇观', '生活智慧']
    const out: CatChip[] = []
    for (let i = 0; i < ids.length; i++) {
      const c = new CatChip()
      c.id = ids[i]
      c.label = labels[i]
      out.push(c)
    }
    return out
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    this.maps = await QuestBizService.loadMapsByCategory(this.category === 'all' ? '' : this.category)
    this.failed = this.maps.length === 0
    this.loading = false
  }

  private selectCat(id: string): void {
    this.category = id
    void this.reload()
  }

  build() {
    Column() {
      AppHeader({ title: '知识地图', subtitle: '五个主题，二十张可闯关地图' })
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.chips, (c: CatChip) => {
            Text(c.label)
              .fontSize(13)
              .fontColor(this.category === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.category === c.id ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .constraintSize({ minHeight: 36 })
              .onClick(() => this.selectCat(c.id))
          }, (c: CatChip) => c.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: 16, right: 16, bottom: 8 })

      if (this.failed && !this.loading) {
        AppError({
          title: '地图列表暂时无法加载',
          message: QuestBizService.lastHint,
          retryLabel: '重试',
          onRetry: () => { void this.reload() }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Grid() {
            ForEach(this.maps, (m: QuestMap) => {
              GridItem() {
                MapGridCard({
                  title: m.title,
                  coverKey: m.coverKey,
                  meta: `${m.totalQuestions} 题 · ${QuestBizService.difficultyStars(m)}`,
                  done: ProgressStore.isCompleted(m.id),
                  onTap: () => QuestNav.openMap(m.id)
                })
              }
            }, (m: QuestMap) => m.id)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .width('100%')
          .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
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
