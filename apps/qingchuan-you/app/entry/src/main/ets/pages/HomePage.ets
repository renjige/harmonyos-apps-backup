import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DestCard } from '../components/scenic/DestCard'
import { InspCard } from '../components/scenic/InspCard'
import { DestItem, InspItem } from '../models/ScenicModels'
import { ScenicBizService } from '../services/ScenicBizService'
import { ScenicDetailNav } from '../services/ScenicDetailNav'
import { ScenicMedia } from '../services/ScenicMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '晴川游'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State dests: DestItem[] = []
  @State banners: DestItem[] = []
  @State wisdom: DestItem[] = []
  @State insps: InspItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.dests = await ScenicBizService.loadDestinations()
    this.banners = ScenicBizService.featuredBanners(this.dests)
    this.wisdom = ScenicBizService.wisdomRecommend(this.dests)
    this.insps = await ScenicBizService.loadInspirations()
    this.loading = false
  }

  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text(this.appName)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('晴日山川，把路走成风景')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => ScenicDetailNav.openSearch())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '风景正在展开' }).layoutWeight(1)
      } else if (this.dests.length === 0) {
        AppEmpty({
          title: '暂时没有目的地',
          description: '请检查网络后重试',
          actionLabel: '重试',
          onAction: () => { void this.reload() }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Swiper() {
              ForEach(this.banners, (d: DestItem) => {
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image(ScenicMedia.resource(d.coverKey))
                    .width('100%')
                    .height(200)
                    .objectFit(ImageFit.Cover)
                  Column()
                    .width('100%')
                    .height(110)
                    .linearGradient({
                      angle: 180,
                      colors: [['rgba(15,23,42,0)', 0], ['rgba(27,58,92,0.82)', 1]]
                    })
                  Column({ space: 4 }) {
                    Text(d.title)
                      .fontSize(Theme.type.title3)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#F8FAFC')
                    Text(d.subtitle)
                      .fontSize(Theme.type.footnote)
                      .fontColor('#F8FAFC')
                      .maxLines(1)
                  }
                  .padding(16)
                }
                .width('100%')
                .height(200)
                .borderRadius(Theme.radius.lg)
                .clip(true)
                .onClick(() => ScenicDetailNav.openDest(d.id))
              }, (d: DestItem) => d.id)
            }
            .height(200)
            .indicator(true)
            .loop(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Row() {
              Text('智慧推荐')
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text('出行偏好')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick(() => ScenicDetailNav.openDiagnose())
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.wisdom, (d: DestItem) => {
                  Column() {
                    DestCard({
                      item: d,
                      onTap: () => ScenicDetailNav.openDest(d.id)
                    })
                  }
                  .width(168)
                }, (d: DestItem) => `w-${d.id}`)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .height(210)

            Row() {
              Text('旅行灵感')
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Grid() {
              ForEach(this.insps, (it: InspItem) => {
                GridItem() {
                  InspCard({
                    item: it,
                    onTap: () => ScenicDetailNav.openInsp(it.id)
                  })
                }
              }, (it: InspItem) => it.id)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
          }
          .width('100%')
          .padding({ bottom: Theme.space.s6 })
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
}
