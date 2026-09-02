import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { MatchListCard } from '../sports/MatchListCard'
import { TeamNoteSheet } from './TeamNoteSheet'
import { TeamLibraryBlock } from './TeamLibraryBlock'
import { AppBarChart } from '../design-system/AppChart'
import { BarChartItem, MatchItem, PlayerLine, TeamItem, StandingItem } from '../../models/MatchModels'
import { SportsBizService } from '../../services/SportsBizService'
import { SportsMedia } from '../../services/SportsMedia'
import { DetailNav } from '../../services/DetailNav'
import { AuthService } from '../../services/AuthService'
import { TeamNoteStore } from '../../services/TeamNoteStore'
import { TeamAnalysisService } from '../../services/TeamAnalysisService'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct TeamDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onOpenReminder: (match: MatchItem) => void = () => {}
  onChanged: () => void = () => {}
  @State item: TeamItem | undefined = undefined
  @State standing: StandingItem | undefined = undefined
  @State recentMatches: MatchItem[] = []
  @State loading: boolean = true
  @State favoriteId: string = ''
  @State toastText: string = ''
  @State showNote: boolean = false
  @State notePreview: string = ''
  @State roster: PlayerLine[] = []
  @State formBars: BarChartItem[] = []
  @State goalBars: BarChartItem[] = []
  @State formTrend: string = ''
  @State rankNote: string = ''
  @State inFolder: boolean = false
  @StorageLink('themeColorMode') themeColorMode: string = 'system'

  aboutToAppear(): void {
    void this.loadItem()
    void this.loadFavoriteState()
  }

  onItemIdChange(): void {
    void this.loadItem()
    void this.loadFavoriteState()
  }

  onRefreshChange(): void {
    void this.loadItem()
    void this.loadFavoriteState()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await SportsBizService.findTeam(this.itemId)
    if (this.item !== undefined) {
      this.recentMatches = await SportsBizService.loadMatchesForTeam(this.item.title)
      this.standing = await SportsBizService.findStanding(this.item.title)
      this.notePreview = TeamNoteStore.getNote(this.item.id)
      this.roster = this.item.parseRoster()
      this.formBars = TeamAnalysisService.formBars(this.item.title, this.recentMatches)
      this.goalBars = TeamAnalysisService.goalBars(this.item.title, this.recentMatches)
      this.formTrend = TeamAnalysisService.formTrend(this.item.title, this.recentMatches)
      this.inFolder = ResearchStore.has('team', this.item.id)
      if (this.standing !== undefined) {
        this.rankNote = `${this.standing.rankText()} · ${this.standing.points} 分 · ${this.standing.recordText()}`
      } else {
        this.rankNote = ''
      }
    } else {
      this.recentMatches = []
      this.roster = []
      this.formBars = []
      this.goalBars = []
      this.formTrend = ''
      this.rankNote = ''
      this.inFolder = false
    }
    this.loading = false
  }

  private async loadFavoriteState(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.favoriteId = ''
      return
    }
    const list = await SportsBizService.loadFavorites('')
    this.favoriteId = ''
    for (const fav of list) {
      if (fav.targetType === 'team' && fav.targetId === this.itemId) {
        this.favoriteId = fav.id
        break
      }
    }
  }

  private async handleFollow(): Promise<void> {
    if (!AuthService.requireAuth('follow_team')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    if (this.favoriteId.length > 0) {
      const ok = await SportsBizService.removeFavorite(this.favoriteId)
      if (ok) {
        this.favoriteId = ''
        this.showToast('已取消关注')
        this.onChanged()
      } else {
        this.showToast(SportsBizService.lastError.length > 0 ?
          SportsBizService.lastError : '取消关注失败')
      }
      return
    }
    const row = await SportsBizService.createFavorite('team', this.item.id, this.item.title)
    if (row !== undefined) {
      this.favoriteId = row.id
      this.showToast('已关注球队')
      this.onChanged()
    } else {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '关注失败')
    }
  }

  private handleReminder(): void {
    if (!AuthService.requireAuth('set_reminder')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    let target: MatchItem | undefined = undefined
    for (const m of this.recentMatches) {
      if (m.status === 'upcoming' || m.status === 'live') {
        target = m
        break
      }
    }
    if (target !== undefined) {
      this.onOpenReminder(target)
    } else {
      this.showToast('暂无即将开始的比赛可提醒')
    }
  }

  private handleShare(): void {
    if (this.item === undefined) {
      return
    }
    try {
      const text = this.item.shareText()
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.showToast('球队卡片已复制，可粘贴分享')
    } catch {
      this.showToast('分享失败，请稍后重试')
    }
  }

  private async handleFolder(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    if (this.inFolder) {
      await ResearchStore.remove('team', this.item.id)
      this.inFolder = false
      this.showToast('已移出研判收藏夹')
      return
    }
    await ResearchStore.add('team', this.item.id, this.item.title, this.item.formStatus())
    this.inFolder = true
    this.showToast('已加入研判收藏夹')
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载球队…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '球队不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '球队详情',
          onClose: (): void => { DetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
      }

      if (this.showNote && this.item !== undefined) {
        TeamNoteSheet({
          teamId: this.item.id,
          teamTitle: this.item.title,
          onClose: (): void => { this.showNote = false },
          onSaved: (): void => {
            if (this.item !== undefined) {
              this.notePreview = TeamNoteStore.getNote(this.item.id)
            }
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(40)
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
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(SportsMedia.coverImage(this.item.coverKey))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 6 }) {
            Text(`${this.item.sportLabel()} · ${this.item.leagueName}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.formStatus())
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textOnInverse)
            if (this.standing !== undefined) {
              Text(`${this.standing.rankText()} · ${this.standing.points} 分`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          Column({ space: 4 }) {
            Text(this.item.statsLabel.length > 0 ? this.item.statsLabel : '近期状态')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
            Text(this.item.statsValue.length > 0 ? this.item.statsValue : '—')
              .fontSize(Theme.type.displayS)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 4 }) {
            Text('所属项目')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
            Text(this.item.sportLabel())
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '球队简介', variant: 'plain' }) {
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.body.length > 0) {
          Column({ space: 8 }) {
            Text('详细资料')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }

        Column() {
          TeamLibraryBlock({
            team: this.item,
            roster: this.roster,
            rankNote: this.rankNote
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.formTrend.length > 0) {
          Text(`胜负趋势：${this.formTrend}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppBarChart({ title: '战绩变化（近场积分）', items: this.formBars })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppBarChart({ title: '进球变化', items: this.goalBars })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          Text('近期比赛')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.recentMatches.length === 0) {
            AppEmpty({
              title: '暂无比赛记录',
              description: '该球队近期暂无关联赛程'
            })
          } else {
            ForEach(this.recentMatches, (row: MatchItem) => {
              MatchListCard({
                item: row,
                onTap: (): void => { DetailNav.openMatch(row.id) }
              })
            }, (row: MatchItem) => row.id)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: this.favoriteId.length > 0 ? '已关注' : '关注球队',
              variant: this.favoriteId.length > 0 ? 'secondary' : 'primary',
              onTap: (): void => { void this.handleFollow() }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: '比赛提醒',
              variant: 'secondary',
              onTap: (): void => { this.handleReminder() }
            })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: this.notePreview.length > 0 ? '编辑研判笔记' : '写研判笔记',
            variant: 'secondary',
            onTap: (): void => { this.showNote = true }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: this.inFolder ? '已在研判收藏夹' : '加入研判收藏夹',
            variant: 'secondary',
            onTap: (): void => { void this.handleFolder() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '分享球队卡片',
            variant: 'secondary',
            onTap: (): void => { this.handleShare() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
