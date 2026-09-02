import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { GuideCard } from '../components/escape/GuideCard'
import { CatChip, GuideItem } from '../models/EscapeModels'
import { EscapeBizService } from '../services/EscapeBizService'
import { EscapeDetailNav } from '../services/EscapeDetailNav'

@Component
export struct InspirePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State all: GuideItem[] = []
  @State shown: GuideItem[] = []
  @State kind: string = 'all'
  private chips: CatChip[] = InspirePage.makeChips()

  private static makeChips(): CatChip[] {
    const out: CatChip[] = []
    out.push(CatChip.of('all', '全部'))
    out.push(CatChip.of('guide', '避暑攻略'))
    out.push(CatChip.of('featured', '精选游记'))
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
    this.all = await EscapeBizService.loadGuides()
    this.apply()
    this.loading = false
  }

  private apply(): void {
    if (this.kind === 'all') {
      this.shown = this.all
      return
    }
    const out: GuideItem[] = []
    for (const g of this.all) {
      if (g.kind === this.kind) {
        out.push(g)
      }
    }
    this.shown = out
  }

  build() {
    Column() {
      Text('灵感')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 8 })

      Row({ space: 8 }) {
        ForEach(this.chips, (c: CatChip) => {
          Text(c.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.kind === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.kind === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceGlass)
            .borderRadius(Theme.radius.pill)
            .onClick(() => {
              this.kind = c.id
              this.apply()
            })
        }, (c: CatChip) => c.id)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '把攻略摊开' }).layoutWeight(1)
      } else if (this.shown.length === 0) {
        AppEmpty({ title: '暂时没有文章', actionLabel: '重试', onAction: () => { void this.reload() } }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.shown, (g: GuideItem) => {
            ListItem() {
              GuideCard({ item: g, onTap: () => EscapeDetailNav.openGuide(g.id) })
                .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 12 })
            }
          }, (g: GuideItem) => g.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ bottom: Theme.space.s8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
