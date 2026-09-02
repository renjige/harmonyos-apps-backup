import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { RecordItem, WeatherItem } from '../models/RoadModels'
import { RoadBizService } from '../services/RoadBizService'
import { RoadDetailNav } from '../services/RoadDetailNav'
import { RoadMedia } from '../services/RoadMedia'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State trips: RecordItem[] = []
  @State weather: WeatherItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.weather = await RoadBizService.loadWeather()
    if (AuthService.isLoggedIn()) {
      this.trips = await RoadBizService.loadItineraries()
    } else {
      this.trips = []
    }
    this.loading = false
  }

  private addPlan(): void {
    if (!AuthService.requireAuth('create_itinerary')) {
      this.onRequireAuth()
      return
    }
    RoadDetailNav.openPlanNew('')
  }

  build() {
    Column() {
      Row() {
        Text('规划')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('新建')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.addPlan())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '读取行程' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('季节气候备忘（非实时预报）')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            ForEach(this.weather, (w: WeatherItem) => {
              Row({ space: 12 }) {
                Image(RoadMedia.resource(w.coverKey))
                  .width(72)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
                Column({ space: 4 }) {
                  Text(w.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`${w.season} · ${w.tempRange}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  Text(w.hint)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (w: WeatherItem) => w.id)

            Text('我的行程')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            if (!AuthService.isLoggedIn()) {
              AppEmpty({
                title: '登录后规划行程',
                description: '游客可以先逛路线，规划需要账号',
                actionLabel: '去登录',
                onAction: (): void => { this.onRequireAuth() }
              })
            } else if (this.trips.length === 0) {
              Column({ space: 12 }) {
                Image(RoadMedia.resource('empty_plan'))
                  .width('100%')
                  .height(140)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                AppEmpty({
                  title: '还没有家庭行程',
                  description: '从一条研学路线点「开始规划」，或在这里新建',
                  actionLabel: '新建行程',
                  onAction: (): void => { this.addPlan() }
                })
              }
            } else {
              ForEach(this.trips, (t: RecordItem) => {
                Column({ space: 6 }) {
                  Text(t.title)
                    .fontSize(Theme.type.subtitleL)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${t.startAt} 至 ${t.endAt}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  Text(t.itemsJson.length > 0 ? t.itemsJson : '尚未添加每日清单')
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(3)
                    .width('100%')
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick(() => RoadDetailNav.openPlanEdit(t.id))
              }, (t: RecordItem) => t.id)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
