import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppIcon } from '../components/design-system/AppIcon'
import { EventItem, WatchPlanItem, AthleteItem } from '../models/StarModels'
import { WatchReview } from '../models/FanGrowthModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'
import { WatchPlanService } from '../services/WatchPlanService'
import { ReminderService, ReminderEntry } from '../services/ReminderService'
import { EventStatusUtil } from '../services/EventStatusUtil'
import { WatchReviewService } from '../services/WatchReviewService'
import { StreakService } from '../services/StreakService'
import { FanStatsService } from '../services/FanStatsService'

@Component
export struct WatchPlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('planTick') planTick: number = 0
  @Prop embedded: boolean = false
  @State mine: WatchPlanItem[] = []
  @State upcoming: EventItem[] = []
  @State reminders: ReminderEntry[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  @State showReview: boolean = false
  @State reviewEventId: string = ''
  @State reviewTitle: string = ''
  @State reviewAthlete: string = ''
  @State reviewRating: number = 4
  @State reviewNote: string = ''

  aboutToAppear(): void {
    this.restoreTabBarIfEmbedded()
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.mine = WatchPlanService.list()
    this.upcoming = await StarBizService.loadEvents('', '', 'upcoming')
    this.reminders = ReminderService.listScheduled()
    this.loading = false
  }

  private async addPlan(ev: EventItem): Promise<void> {
    await WatchPlanService.addEvent(ev)
    this.mine = WatchPlanService.list()
    const ach = await FanStatsService.bumpAndEvaluate()
    if (ach.length > 0) {
      this.showToast(ach)
    } else {
      this.showToast('已加入观赛计划')
    }
  }

  private openReviewSheet(item: WatchPlanItem): void {
    this.reviewEventId = item.eventId
    this.reviewTitle = item.title
    this.reviewAthlete = item.athleteName
    this.reviewRating = 4
    this.reviewNote = ''
    this.showReview = true
    // Tab 内嵌模式不隐藏底栏；全屏 Overlay 模式才隐藏
    if (!this.embedded) {
      AppStorage.setOrCreate('tabBarHidden', true)
    }
  }

  private closeReview(): void {
    this.showReview = false
    if (this.embedded) {
      AppStorage.setOrCreate('tabBarHidden', false)
    } else {
      AppStorage.setOrCreate('tabBarHidden', StarDetailNav.isOpen())
    }
  }

  private restoreTabBarIfEmbedded(): void {
    if (this.embedded) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private async saveReview(): Promise<void> {
    const r = new WatchReview()
    r.eventId = this.reviewEventId
    r.eventTitle = this.reviewTitle
    r.athleteName = this.reviewAthlete
    r.rating = this.reviewRating
    r.note = this.reviewNote.trim()
    await WatchReviewService.save(r)
    this.closeReview()
    const ach = await FanStatsService.bumpAndEvaluate()
    if (ach.length > 0) {
      this.showToast(ach)
    } else {
      this.showToast('观赛评已保存')
    }
  }

  private async markWatched(item: WatchPlanItem): Promise<void> {
    const nowWatched = await WatchPlanService.toggleWatched(item.eventId)
    this.mine = WatchPlanService.list()
    if (nowWatched) {
      await StreakService.recordWatch()
      this.openReviewSheet(item)
      const ach = await FanStatsService.bumpAndEvaluate()
      if (ach.length > 0) {
        this.showToast(ach)
      }
      return
    }
    this.restoreTabBarIfEmbedded()
    this.showToast('已取消已看标记')
  }

  private async drop(id: string): Promise<void> {
    await WatchPlanService.remove(id)
    this.mine = WatchPlanService.list()
    this.showToast('已移出计划')
  }

  private async scheduleReminder(ev: EventItem): Promise<void> {
    if (!EventStatusUtil.isFuture(ev.startAt)) {
      this.showToast('该赛事已开始或已结束，无法设置提醒')
      return
    }
    let athlete: AthleteItem | undefined = undefined
    if (ev.athleteId.length > 0) {
      athlete = await StarBizService.findAthlete(ev.athleteId)
    }
    if (athlete === undefined) {
      const stub = new AthleteItem()
      stub.id = ev.athleteId
      stub.title = ev.athleteName.length > 0 ? ev.athleteName : '球星'
      athlete = stub
    }
    const ok = await ReminderService.scheduleForEvent(ev, athlete, 30)
    if (ok) {
      this.reminders = ReminderService.listScheduled()
      this.showToast('已设置开赛前 30 分钟提醒')
      return
    }
    this.showToast(ReminderService.lastError.length > 0 ?
      ReminderService.lastError : '设置提醒失败')
  }

  private async cancelReminder(eventId: string): Promise<void> {
    await ReminderService.cancelForEvent(eventId)
    this.reminders = ReminderService.listScheduled()
    this.showToast('已取消提醒')
  }

  private reminderFireLabel(entry: ReminderEntry): string {
    const d = new Date(entry.fireAt)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    const hh = h < 10 ? `0${h}` : `${h}`
    const mi = min < 10 ? `0${min}` : `${min}`
    return `${mm}-${dd} ${hh}:${mi}`
  }

  private countdownOf(item: WatchPlanItem): string {
    const ev = new EventItem()
    ev.startAt = item.startAt
    ev.status = item.watched ? 'finished' : 'upcoming'
    return ev.countdownLabel()
  }

  build() {
    Stack() {
      Column() {
        if (this.embedded) {
          AppHeader({ title: '计划', subtitle: '观赛清单 · 提醒 · 赛后点评' })
        } else {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick((): void => { StarDetailNav.close() })
            Text('观赛计划')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
        }

        if (this.loading) {
          AppLoading({ label: '整理赛程…' }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Text(`我的计划 ${WatchPlanService.watchedCount()}/${WatchPlanService.count()} 场已看`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              if (this.reminders.length > 0) {
                Column({ space: Theme.space.s2 }) {
                  Text(`我的提醒 (${this.reminders.length})`)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  ForEach(this.reminders, (entry: ReminderEntry) => {
                    Row({ space: Theme.space.s2 }) {
                      Column({ space: 2 }) {
                        Text(entry.title)
                          .fontSize(Theme.type.callout)
                          .fontColor(Theme.colors().textPrimary)
                          .width('100%')
                        Text(`${this.reminderFireLabel(entry)} · ${entry.content}`)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().textSecondary)
                          .maxLines(2)
                          .width('100%')
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      Text('取消')
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandPrimary)
                        .onClick((): void => { void this.cancelReminder(entry.eventId) })
                    }
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.lg)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                  }, (entry: ReminderEntry) => entry.eventId)
                }
                .width('100%')
              }

              if (this.mine.length === 0) {
                AppEmpty({
                  title: '还没有观赛计划',
                  description: '从下方赛程点「加入计划」，生成你自己的观赛清单'
                })
              } else {
                ForEach(this.mine, (item: WatchPlanItem) => {
                  Column({ space: 6 }) {
                    Text(item.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(`${this.countdownOf(item)} · ${item.venue}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    Row({ space: Theme.space.s2 }) {
                      AppButton({
                        label: item.watched ? '已看过' : '标记已看',
                        variant: item.watched ? 'secondary' : 'primary',
                        onTap: (): void => { void this.markWatched(item) }
                      })
                        .layoutWeight(1)
                      AppButton({
                        label: '详情',
                        variant: 'secondary',
                        onTap: (): void => { StarDetailNav.openEvent(item.eventId) }
                      })
                        .layoutWeight(1)
                      AppButton({
                        label: '移出',
                        variant: 'secondary',
                        onTap: (): void => { void this.drop(item.eventId) }
                      })
                        .layoutWeight(1)
                    }
                    .width('100%')
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.xl)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                }, (item: WatchPlanItem) => item.eventId)
              }

              Text('近期可加入')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              ForEach(this.upcoming.slice(0, 8), (ev: EventItem) => {
                Column({ space: 6 }) {
                  Text(ev.title)
                    .fontSize(Theme.type.callout)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${ev.countdownLabel()} · ${ev.leagueName}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  Row({ space: Theme.space.s2 }) {
                    AppButton({
                      label: WatchPlanService.has(ev.id) ? '已在计划中' : '加入计划',
                      variant: WatchPlanService.has(ev.id) ? 'secondary' : 'primary',
                      onTap: (): void => { void this.addPlan(ev) }
                    })
                      .layoutWeight(1)
                    AppButton({
                      label: '设提醒',
                      variant: 'secondary',
                      onTap: (): void => { void this.scheduleReminder(ev) }
                    })
                      .layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }, (ev: EventItem) => ev.id)
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
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showReview) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Text('观赛后点评')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.reviewTitle)
              .fontSize(Theme.type.callout)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text(`评分 ${this.reviewRating} / 5`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Slider({
              value: this.reviewRating,
              min: 1,
              max: 5,
              step: 1
            })
              .width('100%')
              .onChange((v: number): void => { this.reviewRating = Math.round(v) })
            TextInput({ text: this.reviewNote, placeholder: '写下观赛感受（可选）' })
              .width('100%')
              .fontSize(Theme.type.body)
              .onChange((v: string): void => { this.reviewNote = v })
            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: '跳过',
                variant: 'secondary',
                onTap: (): void => { this.closeReview() }
              })
                .layoutWeight(1)
              AppButton({
                label: '保存点评',
                onTap: (): void => { void this.saveReview() }
              })
                .layoutWeight(1)
            }
            .width('100%')
          }
          .padding(Theme.space.s5)
          .width('100%')
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          .onClick((): void => { /* 阻止点击穿透关闭 */ })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
        .backgroundColor('rgba(15,23,42,0.45)')
        .zIndex(30)
        .onClick((): void => { this.closeReview() })
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
        .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }
}
