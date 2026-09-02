import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { RouteCard } from '../components/wander/RouteCard'
import { RouteItem } from '../models/WanderModels'
import { WanderBizService } from '../services/WanderBizService'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderMedia } from '../services/WanderMedia'

class MapPin {
  id: string = ''
  x: number = 0
  y: number = 0
}

@Component
export struct MapHomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '夏日漫游'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State routes: RouteItem[] = []
  @State pins: MapPin[] = []
  @State listMode: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.routes = await WanderBizService.loadRoutes()
    this.pins = MapHomePage.buildPins(this.routes)
    this.loading = false
  }

  private static buildPins(routes: RouteItem[]): MapPin[] {
    const out: MapPin[] = []
    const slots: number[][] = [[22, 28], [58, 22], [38, 48], [72, 42], [18, 58], [64, 62], [46, 34], [82, 30]]
    let i = 0
    for (const r of routes) {
      if (i >= slots.length) {
        break
      }
      const p = new MapPin()
      p.id = r.id
      p.x = slots[i][0]
      p.y = slots[i][1]
      out.push(p)
      i += 1
    }
    return out
  }

  private kindLabel(r: RouteItem): string {
    const d = r.durationKind === 'weekend' ? '周末' : (r.durationKind === 'day' ? '一日' : '半日')
    const s = r.sceneKind === 'city' ? '城市' : '自然'
    return `${d} · ${s}`
  }

  private todayHint(): string {
    const d = new Date()
    return `${d.getMonth() + 1}月 · 宜慢走`
  }

  @Builder
  MapCanvas() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(WanderMedia.resource('hero_summer'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.92)
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['rgba(78,205,196,0.15)', 0], ['rgba(69,183,209,0.35)', 1]]
        })
      ForEach(this.pins, (p: MapPin) => {
        Column({ space: 2 }) {
          Column() {
            AppIcon({ name: 'location', iconSize: 14, color: Theme.colors().brandOnPrimary })
          }
          .width(28)
          .height(28)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(14)
          .border({ width: 2, color: '#FFFFFF' })
        }
        .position({ x: `${p.x}%`, y: `${p.y}%` })
        .onClick(() => WanderDetailNav.openRoute(p.id))
      }, (p: MapPin) => p.id)
    }
    .width('100%')
    .height(240)
    .borderRadius(Theme.radius.lg)
    .clip(true)
  }

  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text('周边漫游')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('精选夏日漫游点 · 示意地图非实时导航')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Row({ space: 8 }) {
          Text(this.todayHint())
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => WanderDetailNav.openSearch())
          Column() {
            AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => WanderDetailNav.openMessages())
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      Row({ space: 8 }) {
        Text('🌿 智慧匹配')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => WanderDetailNav.openDiagnose())
        Text('🔍 搜索漫游点')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick((): void => WanderDetailNav.openSearch())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '正在加载漫游点' }).layoutWeight(1)
      } else if (this.routes.length === 0) {
        AppEmpty({
          title: '附近暂无漫游点',
          description: '请检查网络后重试',
          actionLabel: '重试',
          onAction: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else {
        Column({ space: Theme.space.s4 }) {
          if (!this.listMode) {
            this.MapCanvas()
          }

          Row() {
            Text(this.listMode ? '列表视图' : '地图视图')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Blank()
            Text(this.listMode ? '切到地图' : '切到列表')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick(() => { this.listMode = !this.listMode })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.routes, (r: RouteItem) => {
                Column() {
                  RouteCard({
                    title: r.title,
                    summary: r.summary,
                    coverKey: r.coverKey,
                    duration: r.duration,
                    difficulty: r.difficulty,
                    kindLabel: this.kindLabel(r),
                    onTap: (): void => WanderDetailNav.openRoute(r.id)
                  })
                  .width(280)
                }
              }, (r: RouteItem) => r.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .layoutWeight(1)
      }

      Row() {
        AppButton({
          label: '记录漫游',
          variant: 'primary',
          onTap: (): void => WanderDetailNav.openJournalNew('', '', '')
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
