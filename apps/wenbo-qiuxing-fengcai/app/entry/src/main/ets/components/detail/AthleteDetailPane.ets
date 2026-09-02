import { pasteboard } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { AthleteItem, EventItem } from '../../models/StarModels'
import { StarBizService } from '../../services/StarBizService'
import { StarMedia } from '../../services/StarMedia'
import { StarDetailNav } from '../../services/StarDetailNav'
import { AuthService } from '../../services/AuthService'
import { ReminderService } from '../../services/ReminderService'
import { BrowseHistoryService } from '../../services/BrowseHistoryService'
import { EventStatusUtil } from '../../services/EventStatusUtil'

class RemindOption {
  minutes: number = 30
  label: string = ''
}

@Component
export struct AthleteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State item: AthleteItem | undefined = undefined
  @State upcomingEvents: EventItem[] = []
  @State loading: boolean = true
  @State favoriteId: string = ''
  @State toastText: string = ''
  @State savingReminder: boolean = false
  private remindOptions: RemindOption[] = AthleteDetailPane.buildRemindOptions()
  private uiContext: common.UIAbilityContext | null = null

  private static buildRemindOptions(): RemindOption[] {
    const out: RemindOption[] = []
    const o10 = new RemindOption()
    o10.minutes = 10
    o10.label = '提前 10 分钟'
    out.push(o10)
    const o30 = new RemindOption()
    o30.minutes = 30
    o30.label = '提前 30 分钟'
    out.push(o30)
    const o60 = new RemindOption()
    o60.minutes = 60
    o60.label = '提前 60 分钟'
    out.push(o60)
    return out
  }

  aboutToAppear(): void {
    this.uiContext = getContext(this) as common.UIAbilityContext
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
    this.item = await StarBizService.findAthlete(this.itemId)
    if (this.item !== undefined) {
      void BrowseHistoryService.record(this.item.id, this.item.title, 'athlete')
      this.upcomingEvents = await StarBizService.loadEvents('', this.item.id, 'upcoming')
    } else {
      this.upcomingEvents = []
    }
    this.loading = false
  }

  private async loadFavoriteState(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.favoriteId = ''
      return
    }
    const list = await StarBizService.loadFavorites('')
    this.favoriteId = ''
    for (const fav of list) {
      if (fav.targetType === 'athlete' && fav.targetId === this.itemId) {
        this.favoriteId = fav.id
        break
      }
    }
  }

  private nearestEvent(): EventItem | undefined {
    if (this.upcomingEvents.length === 0) {
      return undefined
    }
    return this.upcomingEvents[0]
  }

  private async handleFollow(): Promise<void> {
    if (!AuthService.requireAuth('follow_athlete')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    if (this.favoriteId.length > 0) {
      const ok = await StarBizService.removeFavorite(this.favoriteId)
      if (ok) {
        this.favoriteId = ''
        this.showToast('已取消关注')
        this.onChanged()
      } else {
        this.showToast(StarBizService.lastError.length > 0 ?
          StarBizService.lastError : '取消关注失败')
      }
      return
    }
    const row = await StarBizService.createFavorite(this.item.id, this.item.title)
    if (row !== undefined) {
      this.favoriteId = row.id
      this.showToast('已关注球星')
      this.onChanged()
    } else {
      this.showToast(StarBizService.lastError.length > 0 ?
        StarBizService.lastError : '关注失败')
    }
  }

  private async handleReminder(minutes: number): Promise<void> {
    if (this.item === undefined || this.savingReminder) {
      return
    }
    const event = this.nearestEvent()
    if (event === undefined) {
      this.showToast('暂无即将开始的赛事可提醒')
      return
    }
    if (!EventStatusUtil.isFuture(event.startAt)) {
      this.showToast('该赛事已开始或已结束，无法设置提醒')
      return
    }
    this.savingReminder = true
    const ok = await ReminderService.scheduleForEvent(event, this.item, minutes)
    if (ok) {
      this.showToast(`已记下${minutes}分钟前提醒，打开应用时会提示`)
      this.onChanged()
    } else {
      this.showToast(ReminderService.lastError.length > 0 ?
        ReminderService.lastError : '设置提醒失败')
    }
    this.savingReminder = false
  }

  private handleOpenScoutNotes(): void {
    if (this.item === undefined) {
      return
    }
    StarDetailNav.openScoutNotes(this.item.id)
  }

  private handleShare(): void {
    if (this.item === undefined) {
      return
    }
    if (!AuthService.requireAuth('share_card')) {
      this.onRequireAuth()
      return
    }
    try {
      const text = this.item.shareText()
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.showToast('球星卡片已复制，可粘贴分享')
    } catch {
      this.showToast('分享失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载球星资料…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '球星不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '球星详情',
          onClose: (): void => { StarDetailNav.close() },
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
            .maxLines(3)
            .textAlign(TextAlign.Center)
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
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(StarMedia.coverMedia(this.item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.82)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.sportLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            if (this.item.metaLine().length > 0) {
              Text(this.item.metaLine())
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textOnInverse)
            }
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '简介', variant: 'plain' }) {
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '详细资料', variant: 'plain' }) {
            Text(this.item.description.length > 0 ? this.item.description : this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.achievements.length > 0) {
          Column() {
            AppCard({ title: '主要成就', variant: 'plain' }) {
              Text(this.item.achievements)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .lineHeight(24)
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.item.statsValue.length > 0) {
          Column() {
            AppCard({
              title: this.item.statsLabel.length > 0 ? this.item.statsLabel : '数据概览',
              variant: 'plain'
            }) {
              Text(this.item.statsValue)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: this.favoriteId.length > 0 ? '已关注' : '关注球星',
            variant: this.favoriteId.length > 0 ? 'secondary' : 'primary',
            onTap: (): void => { void this.handleFollow() }
          })
            .layoutWeight(1)
          AppButton({
            label: '分享卡片',
            variant: 'secondary',
            onTap: (): void => { this.handleShare() }
          })
            .layoutWeight(1)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '写球探笔记',
            variant: 'secondary',
            onTap: (): void => { this.handleOpenScoutNotes() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .onClick((): void => { this.handleOpenScoutNotes() })

        Column() {
          AppCard({ title: '关联赛程', variant: 'plain' }) {
            Column({ space: Theme.space.s3 }) {
              if (this.upcomingEvents.length === 0) {
                Text('暂无即将开始的赛事')
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              } else {
                Text('以下赛程距离开赛尚早，可设置开赛前提醒（游客可用）')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                ForEach(this.upcomingEvents.slice(0, 3), (ev: EventItem) => {
                  Column({ space: 4 }) {
                    Text(`${ev.title} · ${ev.timeLabel()}`)
                      .fontSize(Theme.type.callout)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text('查看赛事详情')
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .width('100%')
                      .onClick((): void => { StarDetailNav.openEvent(ev.id) })
                  }
                  .width('100%')
                  .padding({ top: 4, bottom: 4 })
                }, (ev: EventItem) => ev.id)
              }
              Row({ space: Theme.space.s2 }) {
                ForEach(this.remindOptions, (opt: RemindOption) => {
                  AppButton({
                    label: opt.label,
                    variant: 'secondary',
                    onTap: (): void => { void this.handleReminder(opt.minutes) }
                  })
                    .layoutWeight(1)
                }, (opt: RemindOption) => `${opt.minutes}`)
              }
              .width('100%')
            }
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
