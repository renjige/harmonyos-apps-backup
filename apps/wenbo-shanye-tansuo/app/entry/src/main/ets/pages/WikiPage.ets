import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { WikiListCard } from '../components/mx/WikiListCard'
import { WikiItem } from '../models/MxModels'
import { MxBizService } from '../services/MxBizService'
import { MxDetailNav } from '../services/MxDetailNav'

@Component
export struct WikiPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @State category: string = ''
  @State items: WikiItem[] = []
  @State shown: WikiItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await MxBizService.loadArticles('')
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const out: WikiItem[] = []
    for (const w of this.items) {
      if (this.category.length > 0 && w.category !== this.category) {
        continue
      }
      out.push(w)
    }
    this.shown = out
  }

  private setCategory(next: string): void {
    this.category = next
    this.applyFilter()
  }

  build() {
    Column() {
      AppHeader({ title: '百科馆', subtitle: '把路上看见的东西对上名字' })
      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.CatChip('全部', '')
          this.CatChip('植物', '植物')
          this.CatChip('动物', '动物')
          this.CatChip('地质', '地质')
          this.CatChip('天文', '天文')
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.loading) {
        AppLoading({ label: '打开条目' })
      } else if (this.shown.length === 0) {
        AppEmpty({
          title: '这一类还没有条目',
          description: '换一个标签，或稍后刷新。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        List() {
          ForEach(this.shown, (w: WikiItem) => {
            ListItem() {
              WikiListCard({
                item: w,
                onTap: (): void => MxDetailNav.openWiki(w.id)
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (w: WikiItem) => w.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ top: Theme.space.s3, bottom: Theme.space.s10 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  CatChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.category === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.category === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setCategory(value))
  }
}
