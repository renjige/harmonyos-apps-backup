import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppBarChart } from '../design-system/AppChart'
import { MatchListCard } from '../sports/MatchListCard'
import { BarChartItem, MatchItem, TeamItem } from '../../models/MatchModels'
import { SportsBizService } from '../../services/SportsBizService'
import { TeamAnalysisService, H2HStat } from '../../services/TeamAnalysisService'
import { DetailNav } from '../../services/DetailNav'

@Component
export struct MatchPreviewPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onNamesChange') homeTeam: string = ''
  @Prop @Watch('onNamesChange') awayTeam: string = ''
  @State home: TeamItem | undefined = undefined
  @State away: TeamItem | undefined = undefined
  @State h2h: MatchItem[] = []
  @State h2hStat: H2HStat = new H2HStat()
  @State formHome: BarChartItem[] = []
  @State formAway: BarChartItem[] = []
  @State trendHome: string = ''
  @State trendAway: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onNamesChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.homeTeam.length === 0 || this.awayTeam.length === 0) {
      return
    }
    this.home = await SportsBizService.findTeamByTitle(this.homeTeam)
    this.away = await SportsBizService.findTeamByTitle(this.awayTeam)
    this.h2h = await SportsBizService.loadHeadToHead(this.homeTeam, this.awayTeam)
    this.h2hStat = TeamAnalysisService.summarizeH2H(this.homeTeam, this.awayTeam, this.h2h)
    const matchesA = await SportsBizService.loadMatchesForTeam(this.homeTeam)
    const matchesB = await SportsBizService.loadMatchesForTeam(this.awayTeam)
    this.formHome = TeamAnalysisService.formBars(this.homeTeam, matchesA)
    this.formAway = TeamAnalysisService.formBars(this.awayTeam, matchesB)
    this.trendHome = TeamAnalysisService.formTrend(this.homeTeam, matchesA)
    this.trendAway = TeamAnalysisService.formTrend(this.awayTeam, matchesB)
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text('比赛前瞻')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('对照双方近期状态与历史交锋，仅供观察参考，不构成结果承诺。')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      Column({ space: 6 }) {
        Text(`${this.homeTeam} 近期：${this.trendHome}`)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        if (this.home !== undefined && this.home.attackNote.length > 0) {
          Text(`进攻参考：${this.home.attackNote}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        Text(`${this.awayTeam} 近期：${this.trendAway}`)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        if (this.away !== undefined && this.away.defenseNote.length > 0) {
          Text(`防守参考：${this.away.defenseNote}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      AppBarChart({ title: `${this.homeTeam} 战绩分（近场）`, items: this.formHome })
      AppBarChart({ title: `${this.awayTeam} 战绩分（近场）`, items: this.formAway })

      Text('历史交锋')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.h2hStat.summary)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      if (this.h2h.length === 0) {
        AppEmpty({
          title: '暂无交锋记录',
          description: '公开赛程中还没有双方已结束对阵'
        })
      } else {
        ForEach(this.h2h, (row: MatchItem) => {
          MatchListCard({
            item: row,
            compact: true,
            onTap: (): void => { DetailNav.openMatch(row.id) }
          })
        }, (row: MatchItem) => `pv-h2h-${row.id}`)
      }
    }
    .width('100%')
  }
}
