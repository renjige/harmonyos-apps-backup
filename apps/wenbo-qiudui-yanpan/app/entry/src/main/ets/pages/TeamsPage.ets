import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppLoading } from '../components/design-system/AppLoading'
import { SportCategoryChips } from '../components/sports/SportCategoryChips'
import { FilterChipRow } from '../components/sports/FilterChipRow'
import { TeamListCard } from '../components/sports/TeamListCard'
import { SportCategory, TeamItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

@Component
export struct TeamsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @StorageLink('themeRevision') themeRevision: number = 0
  @State selectedSport: string = ''
  @State selectedRegion: string = ''
  @State selectedTag: string = ''
  @State selectedLeague: string = ''
  @State keyword: string = ''
  @State items: TeamItem[] = []
  @State visible: TeamItem[] = []
  @State leagueChips: SportCategory[] = []
  @State loading: boolean = true
  @State loadError: string = ''
  private regionChips: SportCategory[] = SportCategory.regionCategories()
  private tagChips: SportCategory[] = SportCategory.styleTagCategories()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private buildLeagueChips(list: TeamItem[]): SportCategory[] {
    const names: string[] = []
    for (const row of list) {
      if (row.leagueName.length > 0 && !names.includes(row.leagueName)) {
        names.push(row.leagueName)
      }
    }
    const out: SportCategory[] = []
    const all = new SportCategory()
    all.key = ''
    all.label = '全部联赛'
    out.push(all)
    for (const name of names) {
      const chip = new SportCategory()
      chip.key = name
      chip.label = name
      out.push(chip)
    }
    return out
  }

  private applyFilter(): void {
    const key = this.keyword.trim()
    const out: TeamItem[] = []
    for (const row of this.items) {
      if (this.selectedRegion === 'domestic' && row.region !== 'domestic') {
        continue
      }
      if (this.selectedRegion === 'international' && row.region !== 'international') {
        continue
      }
      if (this.selectedRegion === 'league' && this.selectedLeague.length > 0 &&
        row.leagueName !== this.selectedLeague) {
        continue
      }
      if (this.selectedTag.length > 0 && row.styleTag !== this.selectedTag) {
        continue
      }
      if (key.length > 0) {
        const hit = row.title.indexOf(key) >= 0 || row.leagueName.indexOf(key) >= 0 ||
          row.summary.indexOf(key) >= 0 || row.styleTagLabel().indexOf(key) >= 0
        if (!hit) {
          continue
        }
      }
      out.push(row)
    }
    this.visible = out
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadError = ''
    this.items = await SportsBizService.loadTeams(this.selectedSport, false)
    this.leagueChips = this.buildLeagueChips(this.items)
    this.applyFilter()
    if (this.items.length === 0 && SportsBizService.lastError.length > 0) {
      this.loadError = SportsBizService.lastError
    }
    this.loading = false
  }

  private handleCategory(key: string): void {
    this.selectedSport = key
    void this.reload()
  }

  build() {
    Column() {
      AppHeader({ title: '球队', subtitle: '资料库 · 国内/国际/联赛 · 风格标签' })
      TextInput({ text: this.keyword, placeholder: '搜索球队、联赛或简介' })
        .onChange((v: string): void => {
          this.keyword = v
          this.applyFilter()
        })
        .height(44)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      SportCategoryChips({
        selectedKey: this.selectedSport,
        onSelect: (key: string): void => { this.handleCategory(key) }
      })
      FilterChipRow({
        selectedKey: this.selectedRegion,
        items: this.regionChips,
        onSelect: (key: string): void => {
          this.selectedRegion = key
          if (key !== 'league') {
            this.selectedLeague = ''
          }
          this.applyFilter()
        }
      })
      if (this.selectedRegion === 'league') {
        FilterChipRow({
          selectedKey: this.selectedLeague,
          items: this.leagueChips,
          onSelect: (key: string): void => {
            this.selectedLeague = key
            this.applyFilter()
          }
        })
      }
      FilterChipRow({
        selectedKey: this.selectedTag,
        items: this.tagChips,
        onSelect: (key: string): void => {
          this.selectedTag = key
          this.applyFilter()
        }
      })
      if (this.loading) {
        AppLoading({ label: '加载球队…' }).layoutWeight(1)
      } else if (this.loadError.length > 0 && this.items.length === 0) {
        AppError({
          message: this.loadError,
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else if (this.visible.length === 0) {
        AppEmpty({
          title: '没有匹配的球队',
          description: '试试其他关键词或切换项目分类'
        }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.visible, (row: TeamItem) => {
            ListItem() {
              TeamListCard({
                item: row,
                showForm: true,
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
