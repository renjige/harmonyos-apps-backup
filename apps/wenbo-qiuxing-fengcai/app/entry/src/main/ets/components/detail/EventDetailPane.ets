import { pasteboard } from '@kit.BasicServicesKit'
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
import { WatchPlanService } from '../../services/WatchPlanService'
import { EventStatusUtil } from '../../services/EventStatusUtil'

class RemindOption {
  minutes: number = 30
  label: string = ''
}

@Component
export struct EventDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State item: EventItem | undefined = undefined
  @State athlete: AthleteItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State savingReminder: boolean = false
  @State inPlan: boolean = false
  private remindOptions: RemindOption[] = EventDetailPane.buildRemindOptions()

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
    this.item = await StarBizService.findEvent(this.itemId)
    this.athlete = undefined
    if (this.item !== undefined) {
      void BrowseHistoryService.record(this.item.id, this.item.title, 'event')
      this.inPlan = WatchPlanService.has(this.item.id)
      if (this.item.athleteId.length > 0) {
        this.athlete = await StarBizService.findAthlete(this.item.athleteId)
      }
    }
    this.loading = false
  }

  private shareText(): string {
    if (this.item === undefined) {
      return ''
    }
    const parts: string[] = []
    parts.push(this.item.title)
    parts.push(this.item.sportLabel())
    if (this.item.timeLabel().length > 0) {
      parts.push(this.item.timeLabel())
    }
    if (this.item.venue.length > 0) {
      parts.push(this.item.venue)
    }
    parts.push('来自「球星风采」')
    return parts.join(' · ')
  }

  private async handleAddPlan(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    await WatchPlanService.addEvent(this.item)
    this.inPlan = true
    this.showToast('已加入观赛计划')
    this.onChanged()
  }

  private reminderAthlete(): AthleteItem | undefined {
    if (this.athlete !== undefined) {
      return this.athlete
    }
    if (this.item === undefined) {
      return undefined
    }
    if (this.item.athleteId.length === 0 && this.item.athleteName.length === 0) {
      return undefined
    }
    const stub = new AthleteItem()
    stub.id = this.item.athleteId
    stub.title = this.item.athleteName.length > 0 ? this.item.athleteName : '球星'
    return stub
  }

  private canSetReminder(): boolean {
    if (this.item === undefined) {
      return false
    }
    return this.item.status === 'upcoming' && EventStatusUtil.isFuture(this.item.startAt)
  }

  private async handleReminder(minutes: number): Promise<void> {
    if (this.item === undefined || this.savingReminder) {
      return
    }
    if (!this.canSetReminder()) {
      this.showToast('该赛事已开始或已结束，无法设置提醒')
      return
    }
    const athlete = this.reminderAthlete()
    if (athlete === undefined) {
      this.showToast('暂无关联球星，无法设置提醒')
      return
    }
    this.savingReminder = true
    const ok = await ReminderService.scheduleForEvent(this.item, athlete, minutes)
    if (ok) {
      this.showToast(`已记下${minutes}分钟前提醒，打开应用时会提示`)
      this.onChanged()
    } else {
      this.showToast(ReminderService.lastError.length > 0 ?
        ReminderService.lastError : '设置提醒失败')
    }
    this.savingReminder = false
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
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.shareText())
      pasteboard.getSystemPasteboard().setData(data)
      this.showToast('赛事卡片已复制，可粘贴分享')
    } catch {
      this.showToast('分享失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载赛事详情…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '赛事不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '赛事详情',
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
            Text(`${this.item.sportLabel()} · ${this.item.statusLabel()}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            Text(`${this.item.timeLabel()} · ${this.item.countdownLabel()}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '赛事简介', variant: 'plain' }) {
            Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '对阵信息', variant: 'plain' }) {
            Column({ space: 8 }) {
              if (this.item.leagueName.length > 0) {
                Text(`联赛：${this.item.leagueName}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              if (this.item.opponent.length > 0) {
                Text(`对手：${this.item.opponent}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              if (this.item.athleteName.length > 0) {
                Text(`球星：${this.item.athleteName}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
            }
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.athlete !== undefined) {
          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '查看球星资料',
              variant: 'primary',
              onTap: (): void => {
                StarDetailNav.close()
                StarDetailNav.openAthlete(this.athlete!.id)
              }
            })
              .layoutWeight(1)
            AppButton({
              label: this.inPlan ? '已在观赛计划' : '加入观赛计划',
              variant: this.inPlan ? 'secondary' : 'primary',
              onTap: (): void => { void this.handleAddPlan() }
            })
              .layoutWeight(1)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        } else {
          Column() {
            AppButton({
              label: this.inPlan ? '已在观赛计划' : '加入观赛计划',
              variant: this.inPlan ? 'secondary' : 'primary',
              onTap: (): void => { void this.handleAddPlan() }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppButton({
            label: '分享卡片',
            variant: 'secondary',
            onTap: (): void => { this.handleShare() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '赛事提醒', variant: 'plain' }) {
            Column({ space: Theme.space.s3 }) {
              if (!this.canSetReminder()) {
                Text('该赛事已开始或已结束。可在赛事 Tab「已结束」查看历史赛程。')
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              } else {
                Text('开赛前提醒保存在本机，再次打开应用时会弹出提示（游客可用，登录后同步云端）。')
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.remindOptions, (opt: RemindOption) => {
                    Column() {
                      AppButton({
                        label: opt.label,
                        variant: 'secondary',
                        onTap: (): void => { void this.handleReminder(opt.minutes) }
                      })
                    }
                    .layoutWeight(1)
                    .onClick((): void => { void this.handleReminder(opt.minutes) })
                  }, (opt: RemindOption) => `${opt.minutes}`)
                }
                .width('100%')
              }
            }
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
