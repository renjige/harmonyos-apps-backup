import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { TeamListCard } from '../components/sports/TeamListCard'
import { MatchListCard } from '../components/sports/MatchListCard'
import { FavoriteItem, TeamItem, MatchItem, KpiItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '球队研判'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @StorageLink('themeRevision') themeRevision: number = 0
  onOpenMessages: () => void = () => {}
  onOpenFollow: () => void = () => {}
  onOpenStandings: () => void = () => {}
  onOpenSchedule: () => void = () => {}
  onOpenDiscover: () => void = () => {}
  onOpenCompare: () => void = () => {}
  onOpenCalendar: () => void = () => {}
  onOpenActivity: () => void = () => {}
  onOpenDaily: () => void = () => {}
  onOpenNews: () => void = () => {}
  onOpenResearch: () => void = () => {}
  @State catalogTeams: TeamItem[] = []
  @State upcomingMatches: MatchItem[] = []
  @State liveMatches: MatchItem[] = []
  @State kpis: KpiItem[] = []
  @State matchCount: number = 0
  @State followItems: FavoriteItem[] = []
  @State teamCount: number = 0
  @State loading: boolean = true
  @State loadError: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadError = ''
    const all = await SportsBizService.loadTeams('', false)
    this.teamCount = all.length
    const featured = await SportsBizService.loadFeaturedTeams()
    if (featured.length > 0) {
      this.catalogTeams = featured
    } else {
      const catalog: TeamItem[] = []
      let n = 0
      for (const row of all) {
        if (n >= 6) {
          break
        }
        catalog.push(row)
        n += 1
      }
      this.catalogTeams = catalog
    }
    const matches = await SportsBizService.loadMatches('', false, '')
    this.matchCount = matches.length
    const upcoming: MatchItem[] = []
    const live: MatchItem[] = []
    for (const row of matches) {
      if (row.status === 'live') {
        live.push(row)
      }
      if (row.status === 'live' || row.status === 'upcoming') {
        upcoming.push(row)
      }
    }
    this.kpis = await SportsBizService.loadKpis()
    const kpiTop: KpiItem[] = []
    let kpiN = 0
    for (const row of this.kpis) {
      if (kpiN >= 3) {
        break
      }
      kpiTop.push(row)
      kpiN += 1
    }
    this.kpis = kpiTop
    const liveTop: MatchItem[] = []
    let liveN = 0
    for (const row of live) {
      if (liveN >= 3) {
        break
      }
      liveTop.push(row)
      liveN += 1
    }
    this.liveMatches = liveTop
    const upTop: MatchItem[] = []
    let upN = 0
    for (const row of upcoming) {
      if (upN >= 4) {
        break
      }
      upTop.push(row)
      upN += 1
    }
    this.upcomingMatches = upTop
    this.followItems = []
    if (this.accessToken.length > 0) {
      const favs = await SportsBizService.loadFavorites('')
      const follows: FavoriteItem[] = []
      for (const row of favs) {
        if (row.targetType === 'team') {
          follows.push(row)
        }
      }
      this.followItems = follows
    }
    if (this.catalogTeams.length === 0 && SportsBizService.lastError.length > 0) {
      this.loadError = SportsBizService.lastError
    }
    this.loading = false
  }

  @Builder
  ToolChip(title: string, hint: string, onTap: () => void) {
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
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .alignItems(HorizontalAlign.Start)
    .onClick((): void => { onTap() })
  }

  build() {
    Column() {
      if (this.loading) {
        AppLoading({ label: '加载球队数据…' }).layoutWeight(1)
      } else if (this.loadError.length > 0 && this.catalogTeams.length === 0) {
        AppError({
          message: this.loadError,
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_bg'))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column()
                .width('100%')
                .height(180)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.78)', 1]]
                })
                .borderRadius(Theme.radius.xl)
              Column({ space: 6 }) {
                Text(this.appName)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textOnInverse)
                Text(this.tagline)
                  .fontSize(Theme.type.callout)
                  .fontColor(Theme.colors().textOnInverse)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text(`${this.teamCount}`)
                  .fontSize(Theme.type.display)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                Text('公开档案')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .alignItems(HorizontalAlign.Start)

              Column({ space: 4 }) {
                Text(`${this.matchCount}`)
                  .fontSize(Theme.type.display)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                Text('公开赛程')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .alignItems(HorizontalAlign.Start)
              .onClick((): void => { this.onOpenSchedule() })
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              this.ToolChip('发现看板', '联赛·数据·工具', (): void => { this.onOpenDiscover() })
              this.ToolChip('球队对比', '交锋·研判简报', (): void => { this.onOpenCompare() })
              this.ToolChip('赛事日历', '按月查赛程', (): void => { this.onOpenCalendar() })
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              this.ToolChip('每日观察', '推荐一支球队', (): void => { this.onOpenDaily() })
              this.ToolChip('球队资讯', '动态整理收藏', (): void => { this.onOpenNews() })
              this.ToolChip('研判收藏夹', '本机研究库', (): void => { this.onOpenResearch() })
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              this.ToolChip('公开赛程', '按状态筛选', (): void => { this.onOpenSchedule() })
              this.ToolChip('我的关注', '未关注时为空', (): void => { this.onOpenFollow() })
              this.ToolChip('我的动态', '关注·提醒', (): void => { this.onOpenActivity() })
            }
            .width('100%')

            if (this.kpis.length > 0) {
              Row({ space: Theme.space.s3 }) {
                ForEach(this.kpis, (row: KpiItem) => {
                  Column({ space: 4 }) {
                    Text(`${row.value}`)
                      .fontSize(Theme.type.title2)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.colors().brandPrimary)
                    Text(row.label)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .layoutWeight(1)
                  .padding(Theme.space.s4)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.xl)
                  .alignItems(HorizontalAlign.Start)
                }, (row: KpiItem) => `home-kpi-${row.key}`)
              }
              .width('100%')
            }

            Image($r('app.media.banner_01'))
              .width('100%')
              .height(110)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
              .clip(true)

            if (this.liveMatches.length > 0) {
              Column({ space: Theme.space.s3 }) {
                Row() {
                  Text('进行中')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text('去发现')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => { this.onOpenDiscover() })
                }
                .width('100%')
                ForEach(this.liveMatches, (row: MatchItem) => {
                  MatchListCard({
                    item: row,
                    compact: true,
                    onTap: (): void => { DetailNav.openMatch(row.id) }
                  })
                }, (row: MatchItem) => `home-live-${row.id}`)
              }
              .width('100%')
            }

            if (this.upcomingMatches.length > 0) {
              Column({ space: Theme.space.s3 }) {
                Row() {
                  Text('近期赛程')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text('查看全部')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => { this.onOpenSchedule() })
                }
                .width('100%')
                ForEach(this.upcomingMatches, (row: MatchItem) => {
                  MatchListCard({
                    item: row,
                    compact: true,
                    onTap: (): void => { DetailNav.openMatch(row.id) }
                  })
                }, (row: MatchItem) => `home-match-${row.id}`)
              }
              .width('100%')
            }

            Column({ space: Theme.space.s3 }) {
              Text('我的关注')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.followItems.length === 0) {
                AppEmpty({
                  title: '尚未关注球队',
                  description: '公开档案可直接浏览。关注后，本区与桌面卡片才会出现你的球队。'
                })
              } else {
                ForEach(this.followItems, (row: FavoriteItem) => {
                  Row({ space: Theme.space.s3 }) {
                    Column({ space: 2 }) {
                      Text(row.targetTitle)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .width('100%')
                      Text('已关注')
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    }
                    .layoutWeight(1)
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.xl)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                  .onClick((): void => { DetailNav.openTeam(row.targetId) })
                }, (row: FavoriteItem) => `fav-${row.id}`)
              }
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('公开球队档案')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('以下为联赛公开资料，不是您的个人历史记录。')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              if (this.catalogTeams.length === 0) {
                AppEmpty({
                  title: '暂无公开档案',
                  description: '可在球队页浏览全部分类'
                })
              } else {
                ForEach(this.catalogTeams, (row: TeamItem) => {
                  TeamListCard({
                    item: row,
                    showForm: false,
                    onTap: (): void => { DetailNav.openTeam(row.id) }
                  })
                }, (row: TeamItem) => row.id)
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
          .width('100%')
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
