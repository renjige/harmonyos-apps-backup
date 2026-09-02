import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { MatchListCard } from '../sports/MatchListCard'
import { LeagueItem, MatchItem, StandingItem, TeamItem } from '../../models/MatchModels'
import { SportsBizService } from '../../services/SportsBizService'
import { SportsMedia } from '../../services/SportsMedia'
import { DetailNav } from '../../services/DetailNav'

@Component
export struct LeagueDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State item: LeagueItem | undefined = undefined
  @State heroTitle: string = ''
  @State heroCover: string = ''
  @State heroMeta: string = ''
  @State descText: string = ''
  @State topStandings: StandingItem[] = []
  @State topMatches: MatchItem[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  @StorageLink('themeColorMode') themeColorMode: string = 'system'

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  onRefreshChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    const found = await SportsBizService.findLeague(this.itemId)
    this.item = found
    if (found !== undefined) {
      this.heroTitle = found.title
      this.heroCover = found.coverKey
      this.descText = found.description
      const standings = await SportsBizService.loadStandingsForLeague(found.title)
      const matches = await SportsBizService.loadMatchesForLeague(found.title)
      const topS: StandingItem[] = []
      let si = 0
      while (si < standings.length && si < 5) {
        topS.push(standings[si])
        si += 1
      }
      const topM: MatchItem[] = []
      let mi = 0
      while (mi < matches.length && mi < 8) {
        topM.push(matches[mi])
        mi += 1
      }
      this.topStandings = topS
      this.topMatches = topM
      this.heroMeta = `${found.sportLabel()} · ${standings.length} 队参赛 · ${matches.length} 场赛程`
    } else {
      this.heroTitle = ''
      this.heroCover = ''
      this.heroMeta = ''
      this.descText = ''
      this.topStandings = []
      this.topMatches = []
    }
    this.loading = false
  }

  private async copySummary(): Promise<void> {
    if (this.heroTitle.length === 0) {
      return
    }
    const text = `${this.heroTitle} · ${this.heroMeta}`
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('联赛摘要已复制')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private openTeamByName(name: string): void {
    void this.resolveTeam(name)
  }

  private async resolveTeam(name: string): Promise<void> {
    const team: TeamItem | undefined = await SportsBizService.findTeamByTitle(name)
    if (team !== undefined) {
      DetailNav.openTeam(team.id)
    } else {
      this.showToast('暂未找到该球队档案')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载联赛…' })
      } else if (this.item === undefined) {
        Column({ space: Theme.space.s4 }) {
          AppEmpty({ title: '联赛不存在', description: '请返回后重试' })
          AppButton({
            label: '返回',
            variant: 'secondary',
            onTap: (): void => { DetailNav.close() }
          })
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .backgroundColor(Theme.colors().surfacePage)
      } else {
        DetailShell({
          title: this.heroTitle.length > 0 ? this.heroTitle : '联赛详情',
          onClose: (): void => { DetailNav.close() },
          body: (): void => { this.BodyContent() }
        })
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
  }

  @Builder
  BodyContent() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(SportsMedia.coverImage(this.heroCover))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(200)
          .linearGradient({
            angle: 180,
            colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.82)', 1]]
          })
        Column({ space: 6 }) {
          Text(this.heroTitle)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
            .maxLines(2)
          Text(this.heroMeta)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnInverse)
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .borderRadius(Theme.radius.xl)
      .clip(true)

      if (this.descText.length > 0) {
        AppCard({ title: '联赛简介', variant: 'plain' }) {
          Text(this.descText)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
      }

      Column() {
        AppButton({
          label: '复制摘要',
          variant: 'secondary',
          onTap: (): void => { void this.copySummary() }
        })
      }
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        Text('积分榜 TOP5')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.topStandings.length === 0) {
          AppEmpty({ title: '暂无积分榜', description: '该联赛排名数据整理中' })
        } else {
          ForEach(this.topStandings, (row: StandingItem) => {
            Row({ space: Theme.space.s3 }) {
              Text(row.rankText())
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().brandPrimary)
                .width(36)
              Column({ space: 2 }) {
                Text(row.teamName)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                Text(`${row.points} 分 · ${row.recordText()} · 净胜 ${row.goalDiff}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { this.openTeamByName(row.teamName) })
          }, (row: StandingItem) => `lg-stand-${row.id}-${row.teamName}`)
        }
      }
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        Text('联赛赛程')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.topMatches.length === 0) {
          AppEmpty({ title: '暂无赛程', description: '后续场次将同步更新' })
        } else {
          ForEach(this.topMatches, (row: MatchItem) => {
            MatchListCard({
              item: row,
              compact: true,
              onTap: (): void => { DetailNav.openMatch(row.id) }
            })
          }, (row: MatchItem) => `lg-match-${row.id}`)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
