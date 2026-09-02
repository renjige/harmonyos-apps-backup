import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { MatchListCard } from '../components/sports/MatchListCard'
import { LeagueListCard } from '../components/sports/LeagueListCard'
import { KpiItem, LeagueItem, MatchItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

@Component
export struct DiscoverPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @StorageLink('themeRevision') themeRevision: number = 0
  onOpenCompare: () => void = () => {}
  onOpenCalendar: () => void = () => {}
  onOpenStandings: () => void = () => {}
  onOpenActivity: () => void = () => {}
  onOpenDaily: () => void = () => {}
  onOpenNews: () => void = () => {}
  onOpenResearch: () => void = () => {}
  onOpenFollow: () => void = () => {}
  @State kpis: KpiItem[] = []
  @State leagues: LeagueItem[] = []
  @State liveMatches: MatchItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.kpis = await SportsBizService.loadKpis()
    this.leagues = await SportsBizService.loadLeagues('')
    const all = await SportsBizService.loadMatches('', false, '')
    const live: MatchItem[] = []
    for (const row of all) {
      if (row.status === 'live') {
        live.push(row)
      }
    }
    this.liveMatches = live
    this.loading = false
  }

  @Builder
  ToolTile(title: string, hint: string, onTap: () => void) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
    }
    .layoutWeight(1)
    .height(76)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .onClick((): void => { onTap() })
  }

  @Builder
  KpiGrid() {
    if (this.kpis.length === 0) {
      Row({ space: Theme.space.s3 }) {
        Column({ space: 4 }) {
          Text(`${this.leagues.length}`)
            .fontSize(Theme.type.display)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('公开联赛')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .alignItems(HorizontalAlign.Start)
        Column({ space: 4 }) {
          Text(`${this.liveMatches.length}`)
            .fontSize(Theme.type.display)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('进行中')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    } else {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.kpis, (row: KpiItem) => {
          Column({ space: 4 }) {
            Text(`${row.value}`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text(row.label)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(1)
          }
          .width('48%')
          .padding(Theme.space.s4)
          .margin({ bottom: Theme.space.s3 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .alignItems(HorizontalAlign.Start)
        }, (row: KpiItem) => `kpi-${row.key}`)
      }
      .width('100%')
    }
  }

  build() {
    Column() {
      AppHeader({ title: '发现', subtitle: '数据看板 · 联赛 · 工具入口' })
      if (this.loading) {
        AppLoading({ label: '加载发现页…' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Image($r('app.media.banner_02'))
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)

            Column({ space: Theme.space.s3 }) {
              Text('赛事数据看板')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              this.KpiGrid()
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('研判工具')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Row({ space: Theme.space.s3 }) {
                this.ToolTile('球队对比', '积分·交锋·简报', (): void => { this.onOpenCompare() })
                this.ToolTile('赛事日历', '按月浏览赛程', (): void => { this.onOpenCalendar() })
              }
              .width('100%')
              Row({ space: Theme.space.s3 }) {
                this.ToolTile('联赛积分榜', '排名与净胜', (): void => { this.onOpenStandings() })
                this.ToolTile('我的动态', '关注·提醒汇总', (): void => { this.onOpenActivity() })
              }
              .width('100%')
              Row({ space: Theme.space.s3 }) {
                this.ToolTile('每日观察', '推荐关注球队', (): void => { this.onOpenDaily() })
                this.ToolTile('球队资讯', '动态整理收藏', (): void => { this.onOpenNews() })
              }
              .width('100%')
              Row({ space: Theme.space.s3 }) {
                this.ToolTile('研判收藏夹', '本机研究库', (): void => { this.onOpenResearch() })
                this.ToolTile('我的关注', '关注列表', (): void => { this.onOpenFollow() })
              }
              .width('100%')
            }
            .width('100%')

            if (this.liveMatches.length > 0) {
              Column({ space: Theme.space.s3 }) {
                Text('进行中')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.liveMatches, (row: MatchItem) => {
                  MatchListCard({
                    item: row,
                    compact: true,
                    onTap: (): void => { DetailNav.openMatch(row.id) }
                  })
                }, (row: MatchItem) => `live-${row.id}`)
              }
              .width('100%')
            }

            Column({ space: Theme.space.s3 }) {
              Text('公开联赛')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              if (this.leagues.length === 0) {
                AppEmpty({
                  title: '暂无联赛',
                  description: '请稍后刷新或检查网络'
                })
              } else {
                ForEach(this.leagues, (row: LeagueItem) => {
                  LeagueListCard({
                    item: row,
                    onTap: (): void => { DetailNav.openLeague(row.id) }
                  })
                }, (row: LeagueItem) => row.id)
              }
            }
            .width('100%')
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
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
    .backgroundColor(Theme.colors().surfacePage)
  }
}
