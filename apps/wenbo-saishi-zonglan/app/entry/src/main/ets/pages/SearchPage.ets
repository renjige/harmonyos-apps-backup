import { Theme, ThemeColors } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { MatchListCard } from '../components/sports/MatchListCard'
import { LeagueListCard } from '../components/sports/LeagueListCard'
import { TeamListCard } from '../components/sports/TeamListCard'
import { LeagueItem, MatchItem, TeamItem } from '../models/MatchModels'
import { SearchBundle, SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

@Component
export struct SearchPage {
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @State keyword: string = ''
  @State loading: boolean = false
  @State result: SearchBundle = new SearchBundle()
  onClose: () => void = () => {}

  private palette(): ThemeColors {
    return Theme.palette(this.themeColorMode === 'dark')
  }

  private async runSearch(): Promise<void> {
    if (this.keyword.trim().length === 0) {
      this.result = new SearchBundle()
      return
    }
    this.loading = true
    this.result = await SportsBizService.search(this.keyword, '')
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          Text('‹')
            .fontSize(24)
            .fontColor(this.palette().textPrimary)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        TextInput({ text: this.keyword, placeholder: '搜索比赛、球队、联赛' })
          .layoutWeight(1)
          .height(44)
          .padding({ left: 12, right: 12 })
          .backgroundColor(this.palette().surfaceSubtle)
          .borderRadius(Theme.radius.sm)
          .border({ width: 1, color: this.palette().strokeStrong })
          .fontColor(this.palette().textPrimary)
          .placeholderColor(this.palette().textTertiary)
          .caretColor(this.palette().brandPrimary)
          .onChange((v: string): void => { this.keyword = v })
          .onSubmit((): void => { void this.runSearch() })
        Text('搜索')
          .fontSize(Theme.type.subhead)
          .fontColor(this.palette().brandPrimary)
          .padding({ left: 8, right: 8 })
          .onClick((): void => { void this.runSearch() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })

      if (this.loading) {
        AppLoading({ label: '搜索中…' }).layoutWeight(1)
      } else if (this.keyword.trim().length === 0) {
        AppEmpty({
          title: '搜索赛事内容',
          description: '输入球队名、联赛名或对阵关键词'
        }).layoutWeight(1)
      } else if (this.result.matches.length === 0 &&
        this.result.teams.length === 0 && this.result.leagues.length === 0) {
        AppEmpty({
          title: '未找到相关内容',
          description: '换个关键词试试，或浏览赛事 Tab'
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.result.matches.length > 0) {
              Text(`比赛 · ${this.result.matches.length}`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.palette().textPrimary)
                .width('100%')
              ForEach(this.result.matches, (row: MatchItem) => {
                MatchListCard({
                  item: row,
                  onTap: (): void => { DetailNav.openMatch(row.id) }
                })
              }, (row: MatchItem) => row.id)
            }
            if (this.result.teams.length > 0) {
              Text(`球队 · ${this.result.teams.length}`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.palette().textPrimary)
                .width('100%')
              ForEach(this.result.teams, (row: TeamItem) => {
                TeamListCard({
                  item: row,
                  onTap: (): void => { DetailNav.openTeam(row.id) }
                })
              }, (row: TeamItem) => row.id)
            }
            if (this.result.leagues.length > 0) {
              Text(`联赛 · ${this.result.leagues.length}`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.palette().textPrimary)
                .width('100%')
              ForEach(this.result.leagues, (row: LeagueItem) => {
                LeagueListCard({
                  item: row,
                  onTap: (): void => { DetailNav.openLeague(row.id) }
                })
              }, (row: LeagueItem) => row.id)
            }
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
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.palette().surfacePage)
  }
}
