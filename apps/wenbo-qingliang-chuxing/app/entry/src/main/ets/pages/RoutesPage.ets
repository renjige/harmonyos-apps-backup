import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { RouteListCard } from '../components/cool/RouteListCard'
import { RouteItem } from '../models/CoolModels'
import { CoolBizService } from '../services/CoolBizService'

@Component
export struct RoutesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @StorageLink('selectedCityId') selectedCityId: string = 'city-hz'
  @StorageLink('preferredMode') preferredMode: string = ''
  @State origin: string = ''
  @State dest: string = ''
  @State mode: string = ''
  @State routes: RouteItem[] = []
  @State shown: RouteItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    if (this.mode.length === 0 && this.preferredMode.length > 0) {
      this.mode = this.preferredMode
    }
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.routes = await CoolBizService.loadRoutes(this.selectedCityId, '')
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const out: RouteItem[] = []
    for (const r of this.routes) {
      if (this.mode.length > 0 && r.mode !== this.mode) {
        continue
      }
      if (this.origin.length > 0 && r.origin.indexOf(this.origin) < 0 && r.title.indexOf(this.origin) < 0) {
        continue
      }
      if (this.dest.length > 0 && r.dest.indexOf(this.dest) < 0 && r.title.indexOf(this.dest) < 0) {
        continue
      }
      out.push(r)
    }
    this.shown = out
  }

  private setMode(next: string): void {
    this.mode = next
    this.applyFilter()
  }

  build() {
    Column() {
      AppHeader({ title: '智慧路线', subtitle: '对比步行、骑行与公共交通的清凉指数' })
      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.origin, placeholder: '起点，例如 龙翔桥' })
          .width('100%')
          .height(44)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => {
            this.origin = v
            this.applyFilter()
          })
        TextInput({ text: this.dest, placeholder: '终点，例如 湖滨银泰' })
          .width('100%')
          .height(44)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => {
            this.dest = v
            this.applyFilter()
          })
        Row({ space: Theme.space.s2 }) {
          this.ModeChip('全部', '')
          this.ModeChip('步行', 'walk')
          this.ModeChip('骑行', 'bike')
          this.ModeChip('公交', 'transit')
        }
        .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      if (this.loading) {
        AppLoading({ label: '展开清凉路线' })
      } else if (this.shown.length === 0) {
        AppEmpty({
          title: '没有匹配的路线',
          description: '换一个城市、出行方式或起终点关键词再试。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.shown, (r: RouteItem) => {
              RouteListCard({ item: r })
            }, (r: RouteItem) => r.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3,
            bottom: Theme.space.s10
          })
          .width('100%')
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

  @Builder
  ModeChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.mode === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.mode === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setMode(value))
  }
}
