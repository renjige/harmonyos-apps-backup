import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { KnowledgeObject } from '../models/KnowledgeModels'
import { KnowledgeCatalog } from '../services/KnowledgeCatalog'
import { GewuMedia } from '../services/GewuMedia'
import { GewuStore } from '../services/GewuStore'
import { GewuDetailNav } from '../services/GewuDetailNav'
import { DateHelper } from '../services/DateHelper'
import { DailyRecallCard } from '../components/gewu/DailyRecallCard'
import { DailyWorkbench } from '../components/gewu/DailyWorkbench'
import { GewuQuizPane } from '../components/gewu/GewuQuizPane'
import { GewuPathCard } from '../components/gewu/GewuPathCard'
import { GewuInquiryCompact } from '../components/gewu/GewuInquiryCompact'
import { DailyTheme, DashStats, FieldRecord, GewuPathStatus } from '../models/FieldModels'
import { FieldStore } from '../services/FieldStore'
import { GewuPathService } from '../services/GewuPathService'

@Component
export struct DailyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @StorageLink('themeRevision') themeRevision: number = 0
  @StorageLink('homeRefreshTick') @Watch('onHomeTick') homeRefreshTick: number = 0
  @State todayItem: KnowledgeObject = new KnowledgeObject()
  @State dayIndex: number = 0
  @State poolSize: number = 22
  @State dateLabel: string = ''
  @State weekdayLabel: string = ''
  @State readToday: boolean = false
  @State isFavorite: boolean = false
  @State isDeepen: boolean = false
  @State toastText: string = ''
  @State dash: DashStats = new DashStats()
  @State recent: FieldRecord[] = []
  @State pathDoneCount: number = 0
  @State pathStepRead: boolean = false
  @State pathStepInquiry: boolean = false
  @State pathStepQuiz: boolean = false
  @State pathStepObserve: boolean = false
  @State pathStepCheckin: boolean = false

  aboutToAppear(): void {
    this.dateLabel = DateHelper.displayDate(DateHelper.todayKey())
    this.weekdayLabel = DateHelper.displayWeekday(DateHelper.todayKey())
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onHomeTick(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private refreshPathCount(): void {
    let n = 0
    if (this.pathStepRead) {
      n++
    }
    if (this.pathStepInquiry) {
      n++
    }
    if (this.pathStepQuiz) {
      n++
    }
    if (this.pathStepObserve) {
      n++
    }
    if (this.pathStepCheckin) {
      n++
    }
    this.pathDoneCount = n
  }

  private applyPathFromStatus(pathStatus: GewuPathStatus): void {
    this.pathStepRead = false
    this.pathStepInquiry = false
    this.pathStepQuiz = false
    this.pathStepObserve = false
    this.pathStepCheckin = false
    for (const s of pathStatus.steps) {
      if (s.key === 'read') {
        this.pathStepRead = s.done
      } else if (s.key === 'inquiry') {
        this.pathStepInquiry = s.done
      } else if (s.key === 'quiz') {
        this.pathStepQuiz = s.done
      } else if (s.key === 'observe') {
        this.pathStepObserve = s.done
      } else if (s.key === 'checkin') {
        this.pathStepCheckin = s.done
      }
    }
    this.pathDoneCount = pathStatus.doneCount
  }

  private async reload(): Promise<void> {
    const pool = KnowledgeCatalog.loadPool()
    this.poolSize = pool.length
    this.dayIndex = KnowledgeCatalog.dayOfYear()
    this.todayItem = KnowledgeCatalog.todayObject()
    this.readToday = await GewuStore.isReadToday()
    this.isFavorite = await GewuStore.isFavorite(this.todayItem.id)
    this.isDeepen = await GewuStore.isDeepen(this.todayItem.id)
    const favs = await GewuStore.favoriteIds()
    this.dash = await FieldStore.loadDash(favs.length)
    const pathStatus = await GewuPathService.loadTodayPath(this.todayItem.id)
    this.applyPathFromStatus(pathStatus)
    const recs = await FieldStore.loadRecords()
    const top: FieldRecord[] = []
    let n = 0
    for (const r of recs) {
      if (n < 3) {
        top.push(r)
        n++
      }
    }
    this.recent = top
  }

  private openDetail(): void {
    GewuDetailNav.open(this.todayItem.id)
  }

  private async markRead(): Promise<void> {
    await GewuStore.markReadToday()
    this.readToday = true
    this.pathStepRead = true
    this.refreshPathCount()
    await this.reload()
    this.showToast('今日一格已读')
  }

  private async toggleFavorite(): Promise<void> {
    const added = await GewuStore.toggleFavorite(this.todayItem.id)
    this.isFavorite = added
    await this.reload()
    this.showToast(added ? '已加入收藏' : '已取消收藏')
  }

  private async toggleDeepen(): Promise<void> {
    const added = await GewuStore.toggleDeepen(this.todayItem.id)
    this.isDeepen = added
    await this.reload()
    this.showToast(added ? '已标记想深究' : '已取消深究')
  }

  private onQuizFinished(): void {
    this.pathStepQuiz = true
    this.refreshPathCount()
    void this.reload()
  }

  private onInquirySaved(): void {
    this.pathStepInquiry = true
    this.refreshPathCount()
    void this.reload()
  }

  private seedTodayObservation(): void {
    GewuDetailNav.seedAndEdit(
      this.todayItem.title,
      this.todayItem.atlasKind,
      this.todayItem.coverKey,
      this.todayItem.id
    )
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column({ space: Theme.space.s1 }) {
            Text('格物集')
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandPrimary)
            Text(`${this.dateLabel} · ${this.weekdayLabel}`)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
            Text('图鉴格物 · 非简单记事')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          GewuPathCard({
            doneCount: this.pathDoneCount,
            total: 5,
            stepRead: this.pathStepRead,
            stepInquiry: this.pathStepInquiry,
            stepQuiz: this.pathStepQuiz,
            stepObserve: this.pathStepObserve,
            stepCheckin: this.pathStepCheckin,
            onRead: (): void => {
              if (!this.readToday) {
                void this.markRead()
              }
            },
            onInquiry: (): void => { },
            onQuiz: (): void => { },
            onObserve: (): void => { this.seedTodayObservation() },
            onCheckin: (): void => { GewuDetailNav.openPractice('checkin', '') }
          })

          Text(`第 ${this.dayIndex} 日 · 库中 ${this.poolSize} 物`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image(GewuMedia.coverResource('hero_gewu'))
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,58,92,0.08)', 0], ['rgba(26,58,92,0.55)', 1]]
              })
              .borderRadius(Theme.radius.lg)
            Text('每日一物，格物致知')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s3 })
          }
          .width('100%')

          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(GewuMedia.coverResource(this.todayItem.coverKey))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column()
                .width('100%')
                .height(180)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,58,92,0.05)', 0], ['rgba(26,58,92,0.68)', 1]]
                })
                .borderRadius(Theme.radius.lg)
              Column({ space: Theme.space.s1 }) {
                Text(this.todayItem.category)
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor('rgba(201,169,110,0.9)')
                  .borderRadius(Theme.radius.pill)
                Text(this.todayItem.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .maxLines(2)
              }
              .width('100%')
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .onClick((): void => { this.openDetail() })

            Text(this.todayItem.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
              .maxLines(4)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            GewuInquiryCompact({
              objectId: this.todayItem.id,
              refreshToken: this.refreshToken,
              onSaved: (): void => { this.onInquirySaved() }
            })

            DailyRecallCard({ objectId: this.todayItem.id })

            GewuQuizPane({
              item: this.todayItem,
              refreshToken: this.refreshToken,
              onFinished: (): void => { this.onQuizFinished() }
            })

            Column({ space: Theme.space.s2 }) {
              Text('今日探索方向')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(DailyTheme.today())
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(22)
                .width('100%')
              AppButton({
                label: '写今日观察札',
                variant: 'secondary',
                onTap: (): void => { this.seedTodayObservation() }
              })
              AppButton({
                label: '查看功课与观察札',
                variant: 'ghost',
                onTap: (): void => { AppStorage.setOrCreate('switchTabIndex', 2) }
              })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)

            Row({ space: Theme.space.s2 }) {
              if (this.readToday) {
                Row({ space: 4 }) {
                  AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().success })
                  Text('今日已读')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().success)
                }
              } else {
                Column() {
                  AppButton({
                    label: '标记已读',
                    variant: 'primary',
                    onTap: (): void => { void this.markRead() }
                  })
                }
                .layoutWeight(1)
              }
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              Column() {
                AppButton({
                  label: this.isFavorite ? '已收藏' : '收藏',
                  variant: this.isFavorite ? 'secondary' : 'ghost',
                  onTap: (): void => { void this.toggleFavorite() }
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: this.isDeepen ? '想深究 ✓' : '想深究',
                  variant: this.isDeepen ? 'secondary' : 'ghost',
                  onTap: (): void => { void this.toggleDeepen() }
                })
              }
              .layoutWeight(1)
            }
            .width('100%')

            AppButton({
              label: '图鉴详情 · 两物对照与札记',
              variant: 'primary',
              onTap: (): void => { this.openDetail() }
            })
            AppButton({
              label: '浏览全部知识库',
              variant: 'secondary',
              onTap: (): void => {
                AppStorage.setOrCreate('folioListMode', 'all')
                AppStorage.setOrCreate('switchTabIndex', 1)
              }
            })
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({
            radius: 12,
            color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(26,58,92,0.08)',
            offsetY: 4
          })

          DailyWorkbench({
            recordCount: this.dash.recordCount,
            favCount: this.dash.favCount,
            streak: this.dash.streak,
            checkinCount: this.dash.checkinCount,
            questDone: this.dash.questDone,
            ritualDone: this.dash.ritualDone,
            ritualTotal: this.dash.ritualTotal,
            checkinToday: this.dash.checkinToday,
            planTitle: this.dash.planTitle,
            planId: this.dash.planId,
            planDone: this.dash.planDone,
            planTarget: this.dash.planTarget,
            weekLine: this.dash.weekLine,
            dateLabel: this.dateLabel,
            weekdayLabel: this.weekdayLabel,
            showTitle: false,
            recent: this.recent,
            onWrite: (): void => { this.seedTodayObservation() },
            onCheckin: (): void => { GewuDetailNav.openPractice('checkin', '') },
            onPlan: (): void => { GewuDetailNav.openPractice('plan', 'new') },
            onFolio: (): void => {
              AppStorage.setOrCreate('folioListMode', 'all')
              AppStorage.setOrCreate('switchTabIndex', 1)
            }
          })

          Image(GewuMedia.coverResource('banner_lattice'))
            .width('100%')
            .height(80)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBg())
  }

  private pageBg(): string {
    if (this.themeRevision < 0) {
      return Theme.colors().surfacePage
    }
    return Theme.colors().surfacePage
  }
}
