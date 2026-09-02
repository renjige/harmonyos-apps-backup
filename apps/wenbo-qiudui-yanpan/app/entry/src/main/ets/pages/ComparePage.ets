import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { TeamListCard } from '../components/sports/TeamListCard'
import { MatchListCard } from '../components/sports/MatchListCard'
import { CompareMetricPair } from '../components/sports/CompareMetricPair'
import { TeamItem, MatchItem, StandingItem, BarChartItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { SportsMedia } from '../services/SportsMedia'
import { DetailNav } from '../services/DetailNav'
import { TeamInsightService } from '../services/TeamInsightService'
import { TeamAnalysisService, H2HStat } from '../services/TeamAnalysisService'
import { AppBarChart } from '../components/design-system/AppChart'

@Component
export struct ComparePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @Prop showClose: boolean = false
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @StorageLink('themeRevision') themeRevision: number = 0
  onClose: () => void = () => {}
  @State allTeams: TeamItem[] = []
  @State teamA: TeamItem | undefined = undefined
  @State teamB: TeamItem | undefined = undefined
  @State standingA: StandingItem | undefined = undefined
  @State standingB: StandingItem | undefined = undefined
  @State h2h: MatchItem[] = []
  @State matchesA: MatchItem[] = []
  @State matchesB: MatchItem[] = []
  @State previewA: MatchItem[] = []
  @State previewB: MatchItem[] = []
  @State formA: BarChartItem[] = []
  @State formB: BarChartItem[] = []
  @State h2hStat: H2HStat = new H2HStat()
  @State loading: boolean = true
  @State showPickerA: boolean = false
  @State showPickerB: boolean = false
  @State showReport: boolean = false
  @State reportLines: string[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.allTeams = await SportsBizService.loadTeams('', false)
    this.loading = false
  }

  private async refreshCompare(): Promise<void> {
    if (this.teamA === undefined || this.teamB === undefined) {
      this.h2h = []
      this.previewA = []
      this.previewB = []
      this.formA = []
      this.formB = []
      this.h2hStat = new H2HStat()
      return
    }
    this.standingA = await SportsBizService.findStanding(this.teamA.title)
    this.standingB = await SportsBizService.findStanding(this.teamB.title)
    this.h2h = await SportsBizService.loadHeadToHead(this.teamA.title, this.teamB.title)
    this.h2hStat = TeamAnalysisService.summarizeH2H(this.teamA.title, this.teamB.title, this.h2h)
    this.formA = TeamAnalysisService.formBars(this.teamA.title, this.matchesA)
    this.formB = TeamAnalysisService.formBars(this.teamB.title, this.matchesB)
    this.previewA = TeamAnalysisService.takeFirst(this.matchesA, 3)
    this.previewB = TeamAnalysisService.takeFirst(this.matchesB, 3)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private openReport(): void {
    if (this.teamA === undefined || this.teamB === undefined) {
      return
    }
    this.reportLines = TeamInsightService.buildLines(
      this.teamA,
      this.teamB,
      this.standingA,
      this.standingB,
      this.h2h,
      this.matchesA,
      this.matchesB
    )
    this.showReport = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private async copyReport(): Promise<void> {
    const text = TeamInsightService.toPlainText(this.reportLines)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('研判简报已复制到剪贴板')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async selectTeamA(team: TeamItem): Promise<void> {
    this.teamA = team
    this.showPickerA = false
    AppStorage.setOrCreate('tabBarHidden', this.showPickerB)
    this.matchesA = await SportsBizService.loadMatchesForTeam(team.title)
    await this.refreshCompare()
  }

  private async selectTeamB(team: TeamItem): Promise<void> {
    this.teamB = team
    this.showPickerB = false
    AppStorage.setOrCreate('tabBarHidden', this.showPickerA)
    this.matchesB = await SportsBizService.loadMatchesForTeam(team.title)
    await this.refreshCompare()
  }

  @Builder
  CompareSide(team: TeamItem | undefined, side: string, onPick: () => void) {
    Column({ space: Theme.space.s3 }) {
      Text(side)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
      if (team === undefined) {
        AppButton({
          label: '选择球队',
          variant: 'secondary',
          onTap: (): void => { onPick() }
        })
      } else {
        Column({ space: 8 }) {
          Stack({ alignContent: Alignment.Center }) {
            Image(SportsMedia.coverImage(team.coverKey))
              .width('100%')
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Text(team.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
              .padding(8)
              .textAlign(TextAlign.Center)
          }
          Text(`${team.sportLabel()} · ${team.leagueName}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          AppButton({
            label: '更换',
            variant: 'secondary',
            onTap: (): void => { onPick() }
          })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })
      }
    }
    .layoutWeight(1)
  }

  @Builder
  TeamPicker(onSelect: (team: TeamItem) => void, onClose: () => void) {
    Column() {
      Row() {
        Text('选择球队')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({
          label: '关闭',
          variant: 'secondary',
          onTap: (): void => { onClose() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      List() {
        ForEach(this.allTeams, (row: TeamItem) => {
          ListItem() {
            TeamListCard({
              item: row,
              onTap: (): void => { onSelect(row) }
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  build() {
    Stack() {
      Column() {
        if (this.showClose) {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick((): void => { this.onClose() })
            Column() {
              AppHeader({ title: '球队对比', subtitle: '积分、交锋与规则模板研判简报' })
            }
            .layoutWeight(1)
          }
          .width('100%')
        } else {
          AppHeader({ title: '对比', subtitle: '积分、交锋与公开战绩对照' })
        }
        if (this.loading) {
          AppLoading({ label: '加载球队…' }).layoutWeight(1)
        } else if (this.allTeams.length < 2) {
          AppEmpty({
            title: '球队数据不足',
            description: '至少需要两支球队才能对比'
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Row({ space: Theme.space.s3 }) {
                this.CompareSide(this.teamA, '球队 A', (): void => {
                  this.showPickerA = true
                  AppStorage.setOrCreate('tabBarHidden', true)
                })
                this.CompareSide(this.teamB, '球队 B', (): void => {
                  this.showPickerB = true
                  AppStorage.setOrCreate('tabBarHidden', true)
                })
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              if (this.teamA !== undefined && this.teamB !== undefined) {
                CompareMetricPair({
                  label: '联赛战绩',
                  leftText: this.teamA.formStatus(),
                  rightText: this.teamB.formStatus()
                })
                CompareMetricPair({
                  label: '积分榜',
                  leftText: this.standingA !== undefined ?
                    `${this.standingA.rankText()} · ${this.standingA.points} 分` : '暂无',
                  rightText: this.standingB !== undefined ?
                    `${this.standingB.rankText()} · ${this.standingB.points} 分` : '暂无'
                })
                CompareMetricPair({
                  label: '胜率（积分榜）',
                  leftText: this.standingA !== undefined ? this.standingA.winRateText() : '—',
                  rightText: this.standingB !== undefined ? this.standingB.winRateText() : '—'
                })
                CompareMetricPair({
                  label: '胜/平/负',
                  leftText: this.standingA !== undefined ? this.standingA.recordText() : '—',
                  rightText: this.standingB !== undefined ? this.standingB.recordText() : '—'
                })
                CompareMetricPair({
                  label: '净胜',
                  leftText: this.standingA !== undefined ? this.standingA.goalDiff : '—',
                  rightText: this.standingB !== undefined ? this.standingB.goalDiff : '—'
                })
                CompareMetricPair({
                  label: '所属联赛',
                  leftText: this.teamA.leagueName.length > 0 ? this.teamA.leagueName : '—',
                  rightText: this.teamB.leagueName.length > 0 ? this.teamB.leagueName : '—'
                })
                CompareMetricPair({
                  label: '进攻能力',
                  leftText: this.teamA.attackIndex > 0 ?
                    `${this.teamA.attackIndex} · ${this.teamA.attackNote}` : this.teamA.attackNote,
                  rightText: this.teamB.attackIndex > 0 ?
                    `${this.teamB.attackIndex} · ${this.teamB.attackNote}` : this.teamB.attackNote
                })
                CompareMetricPair({
                  label: '防守能力',
                  leftText: this.teamA.defenseIndex > 0 ?
                    `${this.teamA.defenseIndex} · ${this.teamA.defenseNote}` : this.teamA.defenseNote,
                  rightText: this.teamB.defenseIndex > 0 ?
                    `${this.teamB.defenseIndex} · ${this.teamB.defenseNote}` : this.teamB.defenseNote
                })
                CompareMetricPair({
                  label: '近期状态',
                  leftText: TeamAnalysisService.formTrend(this.teamA.title, this.matchesA),
                  rightText: TeamAnalysisService.formTrend(this.teamB.title, this.matchesB)
                })
                CompareMetricPair({
                  label: '历史交锋',
                  leftText: `${this.h2hStat.teamAWins} 胜`,
                  rightText: `${this.h2hStat.teamBWins} 胜`
                })

                Column() {
                  AppBarChart({ title: `${this.teamA.title} 战绩分`, items: this.formA })
                }
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
                Column() {
                  AppBarChart({ title: `${this.teamB.title} 战绩分`, items: this.formB })
                }
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

                AppButton({
                  label: '生成研判简报',
                  onTap: (): void => { this.openReport() }
                })
                  .width('100%')
                  .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

                Column({ space: Theme.space.s3 }) {
                  Text('历史交锋')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.h2hStat.summary)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  if (this.h2h.length === 0) {
                    AppEmpty({
                      title: '暂无交锋记录',
                      description: '双方近期公开赛程中还没有已结束对阵'
                    })
                  } else {
                    ForEach(this.h2h, (row: MatchItem) => {
                      MatchListCard({
                        item: row,
                        compact: true,
                        onTap: (): void => { DetailNav.openMatch(row.id) }
                      })
                    }, (row: MatchItem) => `h2h-${row.id}`)
                  }
                }
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

                Column({ space: Theme.space.s3 }) {
                  Text(`${this.teamA.title} · 近期比赛`)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  ForEach(this.previewA, (row: MatchItem) => {
                    MatchListCard({
                      item: row,
                      compact: true,
                      onTap: (): void => { DetailNav.openMatch(row.id) }
                    })
                  }, (row: MatchItem) => `a-${row.id}`)
                }
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

                Column({ space: Theme.space.s3 }) {
                  Text(`${this.teamB.title} · 近期比赛`)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  ForEach(this.previewB, (row: MatchItem) => {
                    MatchListCard({
                      item: row,
                      compact: true,
                      onTap: (): void => { DetailNav.openMatch(row.id) }
                    })
                  }, (row: MatchItem) => `b-${row.id}`)
                }
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }
            }
            .padding({ bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')

      if (this.showPickerA) {
        Stack() {
          this.TeamPicker(
            (team: TeamItem): void => { void this.selectTeamA(team) },
            (): void => {
              this.showPickerA = false
              AppStorage.setOrCreate('tabBarHidden', this.showPickerB)
            }
          )
        }
        .width('100%')
        .height('100%')
        .zIndex(20)
      }

      if (this.showPickerB) {
        Stack() {
          this.TeamPicker(
            (team: TeamItem): void => { void this.selectTeamB(team) },
            (): void => {
              this.showPickerB = false
              AppStorage.setOrCreate('tabBarHidden', this.showPickerA)
            }
          )
        }
        .width('100%')
        .height('100%')
        .zIndex(20)
      }

      if (this.showReport) {
        Column() {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick((): void => {
              this.showReport = false
              AppStorage.setOrCreate('tabBarHidden', this.showPickerA || this.showPickerB || this.showClose)
            })
            Text('研判简报')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.reportLines, (line: string) => {
                Text(line.length > 0 ? line : ' ')
                  .fontSize(line.startsWith('【') ? Theme.type.subhead : Theme.type.body)
                  .fontWeight(line.startsWith('【') || line.startsWith('一') ? FontWeight.Medium : FontWeight.Normal)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
              }, (line: string) => `rpt-${line.substring(0, 12)}-${line.length}`)
              AppButton({
                label: '复制全文',
                onTap: (): void => { void this.copyReport() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
        .zIndex(25)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
