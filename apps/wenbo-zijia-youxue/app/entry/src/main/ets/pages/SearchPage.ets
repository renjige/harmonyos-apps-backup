import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { RouteCard } from '../components/road/RouteCard'
import { RouteItem, SpotItem } from '../models/RoadModels'
import { RoadBizService } from '../services/RoadBizService'
import { RoadDetailNav } from '../services/RoadDetailNav'
import { RoadMedia } from '../services/RoadMedia'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State query: string = ''
  @State loading: boolean = true
  @State routes: RouteItem[] = []
  @State spots: SpotItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.routes = await RoadBizService.loadRoutes()
    this.spots = await RoadBizService.loadSpots()
    this.loading = false
  }

  private shownRoutes(): RouteItem[] {
    return RoadBizService.searchRoutes(this.routes, this.query)
  }

  private shownSpots(): SpotItem[] {
    return RoadBizService.searchSpots(this.spots, this.query)
  }

  build() {
    DetailShell({ title: '搜索', contentKey: `${this.refreshToken}`, onClose: (): void => { RoadDetailNav.close() } }) {
      Column({ space: 12 }) {
        TextInput({ text: this.query, placeholder: '目的地、路线或景点' })
          .onChange((v: string) => { this.query = v })
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .padding({ left: 12, right: 12 })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.loading) {
          AppLoading({ label: '正在检索' })
        } else if (this.shownRoutes().length === 0 && this.shownSpots().length === 0) {
          AppEmpty({ title: '没有匹配结果', description: '换个城市或主题词再试' })
        } else {
          Text('研学路线')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .padding({ left: Theme.space.pageX })
            .width('100%')
          ForEach(this.shownRoutes(), (r: RouteItem) => {
            RouteCard({
              title: r.title,
              summary: r.summary,
              coverKey: r.coverKey,
              duration: r.duration,
              mileage: r.mileage,
              ageRange: r.ageRange,
              themeLabel: r.themeLabel(),
              onTap: (): void => { RoadDetailNav.openRoute(r.id) }
            })
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          }, (r: RouteItem) => r.id)

          Text('景点百科')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .padding({ left: Theme.space.pageX, top: 8 })
            .width('100%')
          ForEach(this.shownSpots(), (s: SpotItem) => {
            Row({ space: 12 }) {
              Image(RoadMedia.resource(s.coverKey))
                .width(72)
                .height(64)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 4 }) {
                Text(s.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(`${s.city} · ${s.summary}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height(64)
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            .onClick(() => RoadDetailNav.openSpot(s.id))
          }, (s: SpotItem) => s.id)
        }
      }
      .width('100%')
    }
  }
}
