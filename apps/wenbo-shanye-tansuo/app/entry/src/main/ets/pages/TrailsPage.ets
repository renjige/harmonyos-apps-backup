import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { TrailListCard } from '../components/mx/TrailListCard'
import { TrailItem } from '../models/MxModels'
import { MxBizService } from '../services/MxBizService'
import { MxDetailNav } from '../services/MxDetailNav'

@Component
export struct TrailsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @State difficulty: string = ''
  @State mode: string = ''
  @State trails: TrailItem[] = []
  @State shown: TrailItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.trails = await MxBizService.loadTrails('', '')
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const out: TrailItem[] = []
    for (const t of this.trails) {
      if (this.difficulty.length > 0 && t.difficulty !== this.difficulty) {
        continue
      }
      if (this.mode.length > 0 && t.mode !== this.mode) {
        continue
      }
      out.push(t)
    }
    this.shown = out
  }

  private setDifficulty(next: string): void {
    this.difficulty = next
    this.applyFilter()
  }

  private setMode(next: string): void {
    this.mode = next
    this.applyFilter()
  }

  build() {
    Column() {
      AppHeader({ title: '路线图鉴', subtitle: '按难度与走法翻开一条山路' })
      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s2 }) {
          this.DiffChip('全部', '')
          this.DiffChip('初级', '初级')
          this.DiffChip('中级', '中级')
          this.DiffChip('高级', '高级')
        }
        .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.ModeChip('徒步', 'hike')
          this.ModeChip('骑行', 'bike')
        }
        .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      if (this.loading) {
        AppLoading({ label: '展开路线' })
      } else if (this.shown.length === 0) {
        AppEmpty({
          title: '没有匹配的路线',
          description: '换一个难度或走法再试。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        List() {
          ForEach(this.shown, (t: TrailItem) => {
            ListItem() {
              TrailListCard({
                item: t,
                onTap: (): void => MxDetailNav.openTrail(t.id)
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (t: TrailItem) => t.id)
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
  DiffChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.difficulty === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.difficulty === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setDifficulty(value))
  }

  @Builder
  ModeChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.mode === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.mode === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setMode(this.mode === value ? '' : value))
  }
}
