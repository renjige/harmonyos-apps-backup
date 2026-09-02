import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { VenueListCard } from '../components/court/VenueListCard'
import { FanHomeStrip } from '../components/court/FanHomeStrip'
import { CourtMedia } from '../config/CourtMedia'
import { CourtBizService } from '../services/CourtBizService'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { BannerItem, CaseItem, CourtKpiItem, SportCategoryItem, VenueItem } from '../models/CourtModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '球场拾光'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State kpis: CourtKpiItem[] = []
  @State banners: BannerItem[] = []
  @State categories: SportCategoryItem[] = []
  @State venues: VenueItem[] = []
  @State cases: CaseItem[] = []
  @State selectedCategory: string = '全部'
  @State bannerIndex: number = 0
  onGoDiscover: () => void = () => {}
  onGoMemory: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    await CourtBizService.refreshCatalog()
    this.kpis = CourtBizService.kpis()
    this.banners = CourtBizService.homeBanners()
    this.categories = CourtBizService.categories()
    await CourtBizService.loadVenues(this.selectedCategory)
    this.venues = CourtBizService.venues()
    this.cases = CourtBizService.cases()
    this.loading = false
  }

  private async filterCategory(category: string): Promise<void> {
    this.selectedCategory = category
    await CourtBizService.loadVenues(category)
    this.venues = CourtBizService.venues()
  }

  private openBanner(b: BannerItem): void {
    if (b.linkType === 'promotion' && b.linkId.length > 0) {
      CourtDetailNav.openPromotion(b.linkId)
      return
    }
    if (b.linkType === 'diagnose') {
      CourtDetailNav.openDiagnose()
      return
    }
    this.onGoDiscover()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_court'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column({ space: 0 })
            .width('100%')
            .height(200)
            .borderRadius(Theme.radius.xl)
            .linearGradient({
              angle: 180,
              colors: [
                ['rgba(26,42,58,0.05)', 0.0],
                ['rgba(26,42,58,0.88)', 1.0]
              ]
            })
          Column({ space: 6 }) {
            Text(this.appName)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.tagline)
              .fontSize(Theme.type.footnote)
              .fontColor('rgba(255,255,255,0.92)')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }

        if (this.kpis.length > 0) {
          Row({ space: Theme.space.s3 }) {
            ForEach(this.kpis, (k: CourtKpiItem) => {
              AppStatCard({
                label: k.label,
                value: k.value,
                trend: k.hint,
                positive: k.primary
              }).layoutWeight(1)
            }, (k: CourtKpiItem) => k.label)
          }
          .width('100%')
        }

        FanHomeStrip({
          refreshToken: this.refreshToken,
          onGoWorkbench: (): void => {
            this.onGoMemory()
          }
        })

        Row({ space: Theme.space.s3 }) {
          this.QuickEntry('赛后复盘向导', '一次生成 3 条记忆', (): void => {
            CourtDetailNav.openFanWizard()
          })
          this.QuickEntry('成长报告', '分布图与里程碑', (): void => {
            CourtDetailNav.openFanDashboard()
          })
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          this.QuickEntry('智慧选场', '问卷匹配场馆', (): void => {
            CourtDetailNav.openDiagnose()
          })
          this.QuickEntry('全部工具', '12 项球迷能力', (): void => {
            this.onGoMemory()
          })
        }
        .width('100%')

        if (this.banners.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('精选推荐')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Swiper() {
              ForEach(this.banners, (b: BannerItem) => {
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image(b.coverKey === 'banner_hot' ? $r('app.media.banner_hot') : $r('app.media.banner_today'))
                    .width('100%')
                    .height(120)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.lg)
                  Column({ space: 0 })
                    .width('100%')
                    .height(120)
                    .borderRadius(Theme.radius.lg)
                    .linearGradient({
                      angle: 180,
                      colors: [
                        ['rgba(26,42,58,0.08)', 0.0],
                        ['rgba(26,42,58,0.85)', 1.0]
                      ]
                    })
                  Column({ space: 2 }) {
                    Text(b.tag)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().warning)
                    Text(b.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().textOnInverse)
                      .maxLines(1)
                  }
                  .padding(Theme.space.s4)
                  .alignItems(HorizontalAlign.Start)
                  .width('100%')
                }
                .onClick(() => {
                  this.openBanner(b)
                })
              }, (b: BannerItem) => b.id)
            }
            .autoPlay(true)
            .interval(4000)
            .indicator(true)
            .loop(true)
            .height(120)
            .onChange((idx: number) => {
              this.bannerIndex = idx
            })
          }
        }

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(CourtBizService.categoryFilters(), (cat: string) => {
              Text(cat)
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedCategory === cat ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.selectedCategory === cat ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick(() => {
                  void this.filterCategory(cat)
                })
            }, (cat: string) => cat)
          }
          .padding({ right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
          .width('100%')

        if (this.cases.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('球友实记')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.cases, (c: CaseItem) => {
              Row({ space: Theme.space.s3 }) {
                Image(CourtMedia.byKey(c.coverKey))
                  .width(72)
                  .height(72)
                  .borderRadius(Theme.radius.md)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(c.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(c.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick(() => {
                CourtDetailNav.openCase(c.id)
              })
            }, (c: CaseItem) => c.id)
          }
          .width('100%')
        }

        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('可订场馆')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('查看全部')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => {
                this.onGoDiscover()
              })
          }
          .width('100%')

          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
          } else if (this.venues.length === 0) {
            AppEmpty({
              title: '暂无场馆',
              description: '请下拉刷新或切换分类',
              actionLabel: '刷新',
              onAction: (): void => {
                void this.reload()
              }
            })
          } else {
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
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  QuickEntry(title: string, subtitle: string, onTap: () => void) {
    Column({ space: 4 }) {
      AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(subtitle)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => {
      onTap()
    })
  }
}
