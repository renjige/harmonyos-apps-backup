import { pasteboard } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { MatchItem } from '../../models/MatchModels'
import { SportsBizService } from '../../services/SportsBizService'
import { SportsMedia } from '../../services/SportsMedia'
import { DetailNav } from '../../services/DetailNav'
import { AuthService } from '../../services/AuthService'
import { ResearchStore } from '../../services/ResearchStore'
import { MatchPreviewPane } from './MatchPreviewPane'

@Component
export struct MatchDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onOpenReminder: (match: MatchItem) => void = () => {}
  onChanged: () => void = () => {}
  @State item: MatchItem | undefined = undefined
  @State loading: boolean = true
  @State favoriteId: string = ''
  @State toastText: string = ''
  @State inFolder: boolean = false
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    this.uiContext = getContext(this) as common.UIAbilityContext
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
    this.item = await SportsBizService.findMatch(this.itemId)
    if (this.item !== undefined) {
      this.inFolder = ResearchStore.has('match', this.item.id)
    } else {
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
      if (fav.targetType === 'match' && fav.targetId === this.itemId) {
        this.favoriteId = fav.id
        break
      }
    }
  }

  private async handleFollow(): Promise<void> {
    if (!AuthService.requireAuth('follow_match')) {
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
    const row = await SportsBizService.createFavorite('match', this.item.id, this.item.title)
    if (row !== undefined) {
      this.favoriteId = row.id
      this.showToast('已加入关注')
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
    if (this.item !== undefined) {
      this.onOpenReminder(this.item)
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
      this.showToast('比赛信息已复制，可粘贴分享')
    } catch {
      this.showToast('分享失败，请稍后重试')
    }
  }

  private async handleFolder(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    if (this.inFolder) {
      await ResearchStore.remove('match', this.item.id)
      this.inFolder = false
      this.showToast('已移出研判收藏夹')
      return
    }
    await ResearchStore.add('match', this.item.id, this.item.title, this.item.leagueName)
    this.inFolder = true
    this.showToast('已保存重点比赛')
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载比赛…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '比赛不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '比赛详情',
          onClose: (): void => { DetailNav.close() },
          body: (): void => { this.DetailBody() }
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
            Text(`${this.item.sportLabel()} · ${this.item.statusLabel()}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            if (this.item.homeScore >= 0 && this.item.awayScore >= 0) {
              Text(this.item.scoreText())
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textOnInverse)
            }
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s2 }) {
          Text(this.item.leagueName)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
          Text(this.item.timeLabel())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          if (this.item.venue.length > 0) {
            Text(this.item.venue)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '比赛摘要', variant: 'plain' }) {
            Text(this.item.summary.length > 0 ? this.item.summary : this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.description.length > 0 && this.item.description !== this.item.summary) {
          Column({ space: 8 }) {
            Text('赛事说明')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.description)
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

        if (this.item.statsLabel.length > 0 && this.item.statsValue.length > 0) {
          Row({ space: Theme.space.s3 }) {
            Text(this.item.statsLabel)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Text(this.item.statsValue)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          MatchPreviewPane({
            homeTeam: this.item.homeTeam,
            awayTeam: this.item.awayTeam
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: this.favoriteId.length > 0 ? '已关注' : '关注比赛',
              variant: this.favoriteId.length > 0 ? 'secondary' : 'primary',
              onTap: (): void => { void this.handleFollow() }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: '设置提醒',
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
            label: this.inFolder ? '已保存重点比赛' : '保存到研判收藏夹',
            variant: 'secondary',
            onTap: (): void => { void this.handleFolder() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '复制分享',
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
