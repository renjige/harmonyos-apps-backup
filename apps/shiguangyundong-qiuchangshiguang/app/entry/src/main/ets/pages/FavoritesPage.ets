import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { VenueListCard } from '../components/court/VenueListCard'
import { CourtBizService } from '../services/CourtBizService'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { CourtFavoriteStore } from '../services/CourtFavoriteStore'
import { VenueItem } from '../models/CourtModels'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('courtFavoriteIds') favCsv: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State venues: VenueItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    await CourtBizService.loadVenues()
    this.venues = CourtBizService.venuesByIds(CourtFavoriteStore.listIds())
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .rotate({ angle: 180 })
        .onClick(() => {
          CourtDetailNav.close()
        })
        Text('我的收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.venues.length === 0) {
        AppEmpty({
          title: '还没有收藏',
          description: '在场馆详情点「收藏场馆」，方便下次一键预约',
          actionLabel: '关闭',
          onAction: (): void => {
            CourtDetailNav.close()
          }
        }).padding(Theme.space.pageX)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.venues, (v: VenueItem) => {
              VenueListCard({
                item: v,
                showDistance: true,
                onTap: (): void => {
                  CourtDetailNav.openVenue(v.id)
                }
              })
            }, (v: VenueItem) => v.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
