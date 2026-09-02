import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { VenueListCard } from '../components/court/VenueListCard'
import { CourtMedia } from '../config/CourtMedia'
import { CourtBizService } from '../services/CourtBizService'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { VenueItem } from '../models/CourtModels'
import { AppTextField } from '../components/design-system/AppTextField'

@Component
export struct DiscoverPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State listMode: boolean = true
  @State venues: VenueItem[] = []
  @State searchText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    await CourtBizService.loadVenues()
    this.venues = CourtBizService.assignDistances(CourtBizService.venues())
    this.loading = false
  }

  private filteredVenues(): VenueItem[] {
    const out: VenueItem[] = []
    const q = this.searchText.trim()
    for (let v of this.venues) {
      if (q.length > 0 && v.title.indexOf(q) < 0 && v.category.indexOf(q) < 0) {
        continue
      }
      out.push(v)
    }
    return out
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      AppHeader({ title: '发现', subtitle: '附近可订运动场馆' })

      Row({ space: Theme.space.s2 }) {
        AppTextField({
          text: this.searchText,
          placeholder: '搜索场馆或运动类型',
          fieldHeight: 40,
          pill: true,
          onChange: (v: string): void => {
            this.searchText = v
          }
        })
          .layoutWeight(1)
        Row({ space: Theme.space.s1 }) {
          this.ModeChip('列表', this.listMode, (): void => {
            this.listMode = true
          })
          this.ModeChip('距离', !this.listMode, (): void => {
            this.listMode = false
          })
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.filteredVenues().length === 0) {
        AppEmpty({
          title: '附近暂无场馆',
          description: '试试更换关键词或稍后刷新',
          actionLabel: '刷新',
          onAction: (): void => {
            void this.reload()
          }
        }).padding(Theme.space.pageX)
      } else if (this.listMode) {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.filteredVenues(), (v: VenueItem) => {
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
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Stack({ alignContent: Alignment.TopStart }) {
              Image(CourtMedia.heroCourt())
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
                .opacity(0.85)
              Column({ space: 4 }) {
                Row({ space: Theme.space.s2 }) {
                  AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                  Text('按距离近到远 · 点卡片进详情预约')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
              }
              .padding(Theme.space.s4)
            }

            ForEach(this.filteredVenues(), (v: VenueItem, idx: number) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  Text(`${idx + 1}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandOnPrimary)
                }
                .width(28)
                .height(28)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)

                Column({ space: 2 }) {
                  Text(v.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(`${v.distanceKm} km · ${v.category}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick(() => {
                CourtDetailNav.openVenue(v.id)
              })
            }, (v: VenueItem) => `map-${v.id}`)
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

  @Builder
  ModeChip(label: string, active: boolean, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(active ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(active ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick(() => {
        onTap()
      })
  }
}
