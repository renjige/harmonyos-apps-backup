import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { RouteCard } from '../components/road/RouteCard'
import { RouteItem } from '../models/RoadModels'
import { RoadBizService } from '../services/RoadBizService'
import { RoadDetailNav } from '../services/RoadDetailNav'
import { RoadMedia } from '../services/RoadMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '自驾游学'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State routes: RouteItem[] = []
  @State theme: string = 'all'
  @State appearOpacity: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.routes = await RoadBizService.loadRoutes()
    this.loading = false
    this.appearOpacity = 1
  }

  private shown(): RouteItem[] {
    return RoadBizService.filterByTheme(this.routes, this.theme)
  }

  build() {
    Column() {
      Row() {
        Text(this.appName)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => RoadDetailNav.openSearch())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '正在铺开路线' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(RoadMedia.resource('hero_road'))
                .width('100%')
                .height(210)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(120)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(20,61,40,0)', 0.0], ['rgba(20,61,40,0.82)', 1.0]]
                })
              Column({ space: 6 }) {
                Text('车轮上的课堂')
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                Text('把沿途变成孩子能读懂的风景')
                  .fontSize(Theme.type.subhead)
                  .fontColor('#FFFFFF')
              }
              .padding({ left: 16, right: 16, bottom: 16 })
            }
            .width('100%')
            .clip(true)
            .borderRadius(Theme.radius.lg)
            .onClick(() => RoadDetailNav.openDiagnose())

            Scroll() {
              Row({ space: 8 }) {
                this.ThemeChip('全部', 'all')
                this.ThemeChip('自然探索', 'nature')
                this.ThemeChip('历史文化', 'history')
                this.ThemeChip('科学启蒙', 'science')
                this.ThemeChip('艺术体验', 'art')
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .width('100%')

            Text('智慧路线')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            if (this.shown().length === 0) {
              AppEmpty({ title: '没有这个主题的路线', description: '换一个研学主题看看' })
            } else {
              ForEach(this.shown(), (r: RouteItem) => {
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
              }, (r: RouteItem) => r.id)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
          .opacity(this.appearOpacity)
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

  @Builder
  ThemeChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.theme === key ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      .backgroundColor(this.theme === key ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.theme = key })
  }
}
