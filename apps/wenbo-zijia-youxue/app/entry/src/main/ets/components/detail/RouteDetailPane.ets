import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { RouteItem, RouteStop } from '../../models/RoadModels'
import { AuthService } from '../../services/AuthService'
import { RoadBizService } from '../../services/RoadBizService'
import { RoadDetailNav } from '../../services/RoadDetailNav'
import { RoadMedia } from '../../services/RoadMedia'

@Component
export struct RouteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRouteIdChange') routeId: string = ''
  @Prop @Watch('onRouteIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: RouteItem | undefined = undefined
  @State loading: boolean = true
  @State favored: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRouteIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await RoadBizService.findRoute(this.routeId)
    this.favored = await RoadBizService.isFavorite(this.routeId)
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('favorite_route')) {
      this.onRequireAuth()
      return
    }
    if (this.favored) {
      const id = await RoadBizService.favoriteId(this.routeId)
      if (id.length > 0) {
        await RoadBizService.removeFavorite(id)
      }
      this.favored = false
      this.showToast('已取消收藏')
      return
    }
    const title = this.item !== undefined ? this.item.title : '研学路线'
    const ok = await RoadBizService.addFavorite(title, this.routeId, 'route')
    if (ok) {
      this.favored = true
      this.showToast('已收藏')
    }
  }

  private startPlan(): void {
    if (!AuthService.requireAuth('create_itinerary')) {
      this.onRequireAuth()
      return
    }
    RoadDetailNav.openPlanNew(this.routeId)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        AppLoading({ label: '正在打开路线' })
      } else if (this.item === undefined) {
        DetailShell({ title: '路线', onClose: (): void => { RoadDetailNav.close() } }) {
          AppEmpty({ title: '路线不存在', description: '请返回发现页再试' })
        }
      } else {
        this.Body(this.item as RouteItem)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(20,61,40,0.92)')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body(item: RouteItem) {
    DetailShell({ title: item.title, contentKey: item.id, onClose: (): void => { RoadDetailNav.close() } }) {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(RoadMedia.resource(item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(96)
            .linearGradient({
              angle: 180,
              colors: [['rgba(20,61,40,0)', 0.0], ['rgba(20,61,40,0.78)', 1.0]]
            })
          Column({ space: 4 }) {
            Text(item.themeLabel())
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text(item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 16, right: 16, bottom: 16 })
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.lg)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(`${item.city} · ${item.duration} · ${item.mileage} · 适龄 ${item.ageRange}`)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard() {
            Column({ space: 8 }) {
              Text('路线导语')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text(item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(item.body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .lineHeight(24)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(item.climateNote)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text('途经研学点')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        ForEach(item.stops, (s: RouteStop) => {
          Row() {
            Column({ space: 2 }) {
              Text(s.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`建议停留 ${s.hours}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
          }
          .width('100%')
          .height(64)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .onClick(() => {
            if (s.spotId.length > 0) {
              RoadDetailNav.openSpot(s.spotId)
            }
          })
        }, (s: RouteStop) => s.id)

        Row({ space: 12 }) {
          AppButton({
            label: this.favored ? '已收藏' : '收藏路线',
            variant: 'secondary',
            onTap: (): void => { void this.toggleFav() }
          }).layoutWeight(1)
          AppButton({
            label: '开始规划',
            onTap: (): void => { this.startPlan() }
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%')
    }
  }
}
