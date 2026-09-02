import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppLoading } from '../components/design-system/AppLoading'
import { SportCategoryChips } from '../components/sports/SportCategoryChips'
import { MatchListCard } from '../components/sports/MatchListCard'
import { LeagueListCard } from '../components/sports/LeagueListCard'
import { TeamListCard } from '../components/sports/TeamListCard'
import { LeagueItem, MatchItem, TeamItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

class StatusFilter {
  key: string = ''
  label: string = ''

  static all(): StatusFilter[] {
    const out: StatusFilter[] = []
    const all = new StatusFilter()
    all.key = ''
    all.label = '全部'
    out.push(all)
    const live = new StatusFilter()
    live.key = 'live'
    live.label = '进行中'
    out.push(live)
    const upcoming = new StatusFilter()
    upcoming.key = 'upcoming'
    upcoming.label = '未开始'
    out.push(upcoming)
    const finished = new StatusFilter()
    finished.key = 'finished'
    finished.label = '已结束'
    out.push(finished)
    return out
  }
}

class BrowseMode {
  key: string = ''
  label: string = ''

  static all(): BrowseMode[] {
    const out: BrowseMode[] = []
    const m = new BrowseMode()
    m.key = 'matches'
    m.label = '赛程'
    out.push(m)
    const l = new BrowseMode()
    l.key = 'leagues'
    l.label = '联赛'
    out.push(l)
    const t = new BrowseMode()
    t.key = 'teams'
    t.label = '球队'
    out.push(t)
    return out
  }
}

@Component
export struct EventsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @State browseMode: string = 'matches'
  @State selectedSport: string = ''
  @State statusFilter: string = ''
  @State matchItems: MatchItem[] = []
  @State leagueItems: LeagueItem[] = []
  @State teamItems: TeamItem[] = []
  @State loading: boolean = true
  @State loadError: string = ''
  private browseModes: BrowseMode[] = BrowseMode.all()
  private statusFilters: StatusFilter[] = StatusFilter.all()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadError = ''
    if (this.browseMode === 'leagues') {
      this.leagueItems = await SportsBizService.loadLeagues(this.selectedSport)
      if (this.leagueItems.length === 0 && SportsBizService.lastError.length > 0) {
        this.loadError = SportsBizService.lastError
      }
    } else if (this.browseMode === 'teams') {
      this.teamItems = await SportsBizService.loadTeams(this.selectedSport)
      if (this.teamItems.length === 0 && SportsBizService.lastError.length > 0) {
        this.loadError = SportsBizService.lastError
      }
    } else {
      if (this.selectedSport.length === 0 && this.statusFilter.length === 0) {
        this.matchItems = await SportsBizService.loadMatches('', true, '')
        if (this.matchItems.length === 0) {
          this.matchItems = await SportsBizService.loadMatches('', false, '')
        }
      } else {
        this.matchItems = await SportsBizService.loadMatches(
          this.selectedSport,
          false,
          this.statusFilter
        )
      }
      if (this.matchItems.length === 0 && SportsBizService.lastError.length > 0) {
        this.loadError = SportsBizService.lastError
      }
    }
    this.loading = false
  }

  private handleCategory(key: string): void {
    this.selectedSport = key
    void this.reload()
  }

  private handleBrowseMode(key: string): void {
    this.browseMode = key
    void this.reload()
  }

  private handleStatus(key: string): void {
    this.statusFilter = key
    void this.reload()
  }

  @Builder
  BrowseTabs() {
    Row({ space: Theme.space.s2 }) {
      ForEach(this.browseModes, (m: BrowseMode) => {
        Text(m.label)
          .fontSize(Theme.type.subhead)
          .fontWeight(this.browseMode === m.key ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.browseMode === m.key ?
            Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(this.browseMode === m.key ?
            Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.handleBrowseMode(m.key) })
      }, (m: BrowseMode) => m.key)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  StatusTabs() {
    Row({ space: Theme.space.s2 }) {
      ForEach(this.statusFilters, (s: StatusFilter) => {
        Text(s.label)
          .fontSize(Theme.type.caption)
          .fontWeight(this.statusFilter === s.key ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.statusFilter === s.key ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.statusFilter === s.key ?
            Theme.colors().brandPrimaryContainer : 'transparent')
          .borderRadius(Theme.radius.pill)
          .border({
            width: 1,
            color: this.statusFilter === s.key ?
              Theme.colors().brandPrimary : Theme.colors().strokeHairline
          })
          .onClick((): void => { this.handleStatus(s.key) })
      }, (s: StatusFilter) => s.key)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  build() {
    Column() {
      AppHeader({ title: '赛事', subtitle: '赛程 · 联赛 · 球队' })
      this.BrowseTabs()
      SportCategoryChips({
        selectedKey: this.selectedSport,
        onSelect: (key: string): void => { this.handleCategory(key) }
      })
      if (this.browseMode === 'matches') {
        this.StatusTabs()
      }
      if (this.loading) {
        AppLoading({ label: '加载中…' }).layoutWeight(1)
      } else if (this.loadError.length > 0 &&
        this.matchItems.length === 0 && this.leagueItems.length === 0 && this.teamItems.length === 0) {
        AppError({
          message: this.loadError,
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else if (this.browseMode === 'leagues') {
        if (this.leagueItems.length === 0) {
          AppEmpty({ title: '暂无联赛', description: '切换分类或稍后再试' }).layoutWeight(1)
        } else {
          List() {
            ForEach(this.leagueItems, (row: LeagueItem) => {
              ListItem() {
                LeagueListCard({
                  item: row,
                  onTap: (): void => { DetailNav.openLeague(row.id) }
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s3
              })
            }, (row: LeagueItem) => row.id)
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      } else if (this.browseMode === 'teams') {
        if (this.teamItems.length === 0) {
          AppEmpty({ title: '暂无球队', description: '切换分类或稍后再试' }).layoutWeight(1)
        } else {
          List() {
            ForEach(this.teamItems, (row: TeamItem) => {
              ListItem() {
                TeamListCard({
                  item: row,
                  onTap: (): void => { DetailNav.openTeam(row.id) }
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s3
              })
            }, (row: TeamItem) => row.id)
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      } else if (this.matchItems.length === 0) {
        AppEmpty({
          title: '暂无比赛',
          description: '切换分类或状态筛选'
        }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.matchItems, (row: MatchItem) => {
            ListItem() {
              MatchListCard({
                item: row,
                onTap: (): void => { DetailNav.openMatch(row.id) }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (row: MatchItem) => row.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.themeColorMode === 'dark').surfacePage)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
