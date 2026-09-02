import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { ItineraryItem, TripItem } from '../../models/TravelModels'
import { TravelService } from '../../services/TravelService'
import { TripSummaryOverlay } from './TripSummaryOverlay'

@Component
export struct TripDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop trip: TripItem = new TripItem()
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  @State liveTrip: TripItem = new TripItem()
  @State timeline: ItineraryItem[] = []
  @State loading: boolean = false
  @State showSummary: boolean = false
  @State summaryText: string = ''
  onClose: () => void = () => {}
  onCreateItinerary: () => void = () => {}
  onCreateReminder: () => void = () => {}
  onImportChecklist: () => void = () => {}
  onEditTrip: (trip: TripItem) => void = () => {}
  onEditItinerary: (item: ItineraryItem) => void = () => {}
  onDeleteItinerary: (id: string) => void = () => {}

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    this.liveTrip = this.trip
    void this.loadTimeline()
    void this.reloadTrip()
  }

  onEpochChange(): void {
    void this.loadTimeline()
    void this.reloadTrip()
  }

  private async reloadTrip(): Promise<void> {
    const trips = await TravelService.trips()
    const checklist = await TravelService.checklistItems()
    const enriched = TravelService.attachProgress(trips, checklist)
    for (const row of enriched) {
      if (row.id === this.trip.id) {
        this.liveTrip = row
        return
      }
    }
    this.liveTrip = this.trip
  }

  private async loadTimeline(): Promise<void> {
    this.loading = true
    try {
      this.timeline = await TravelService.itinerary(this.trip.id)
    } catch {
      this.timeline = []
    }
    this.loading = false
  }

  private close(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onClose()
  }

  private phaseLine(): string {
    const phase = TravelService.tripPhase(this.liveTrip)
    const progress = this.liveTrip.progress >= 0 && this.liveTrip.progress <= 100 ?
      Math.floor(this.liveTrip.progress) : 0
    return `${phase} · 准备进度 ${progress}%`
  }

  private confirmDeleteItinerary(item: ItineraryItem): void {
    AlertDialog.show({
      title: '删除安排',
      message: `确定删除「${item.title}」？`,
      primaryButton: {
        value: '删除',
        action: (): void => { this.onDeleteItinerary(item.id) }
      },
      secondaryButton: { value: '取消', action: (): void => {} }
    })
  }

  private async openSummary(): Promise<void> {
    const checklist = await TravelService.checklistItems()
    const reminders = await TravelService.reminders()
    const notes = await TravelService.notes()
    this.summaryText = TravelService.buildSummaryText(this.liveTrip, this.timeline, checklist, reminders, notes)
    this.showSummary = true
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => this.close())
          Text('行程详情')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.travel_route'))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sheet)
              Column()
                .width('100%')
                .height(220)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(11,39,86,0.04)', 0], ['rgba(7,32,74,0.84)', 1]]
                })
                .borderRadius(Theme.radius.sheet)
              Column({ space: 6 }) {
                Text(this.liveTrip.title)
                  .fontSize(Theme.type.title1)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(`${this.liveTrip.destination} · ${this.liveTrip.startDate} 至 ${this.liveTrip.endDate}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor('#FFFFFF')
                Text(this.phaseLine())
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
            }

            AppButton({ label: '编辑行程信息', variant: 'secondary', onTap: (): void => { this.onEditTrip(this.liveTrip) } })

            Column({ space: Theme.space.s2 }) {
              Text('行程摘要')
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(this.liveTrip.summary.length > 0 ? this.liveTrip.summary : '按照每日时间轴整理交通、游览与休息安排。')
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(24)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)

            Text('每日时间轴')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.timeline.length === 0 && !this.loading) {
              AppEmpty({ title: '暂无时间轴', description: '该行程还没有每日安排',
                actionLabel: '重新加载', onAction: () => { void this.loadTimeline() } })
            } else {
              ForEach(this.timeline, (item: ItineraryItem) => {
                Column({ space: Theme.space.s2 }) {
                  Row({ space: Theme.space.s3 }) {
                    Column({ space: 2 }) {
                      Text(item.itemDate.length > 0 ? item.itemDate : '待定日期')
                        .fontSize(Theme.type.caption)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                      Text(item.startTime.length > 0 ? item.startTime : '全天')
                        .fontSize(Theme.type.captionM)
                        .fontColor('#FFFFFF')
                    }
                    .width(96)
                    .padding({ top: 10, bottom: 10 })
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.lg)
                    Column({ space: 4 }) {
                      Text(item.title)
                        .fontSize(Theme.type.bodyM)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      Text(item.location.length > 0 ? item.location : item.note)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  Row({ space: Theme.space.s4 }) {
                    Text('编辑')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                      .onClick(() => this.onEditItinerary(item))
                    Text('删除')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().danger)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                      .onClick(() => this.confirmDeleteItinerary(item))
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
              }, (item: ItineraryItem) => item.id)
            }
            AppButton({ label: '添加每日安排', onTap: () => this.onCreateItinerary() })
            AppButton({ label: '导入出行清单模板', variant: 'secondary', onTap: () => this.onImportChecklist() })
            AppButton({ label: '为此行程创建提醒', variant: 'secondary', onTap: () => this.onCreateReminder() })
            AppButton({ label: '生成出行概览', variant: 'secondary', onTap: (): void => { void this.openSummary() } })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSummary) {
        TripSummaryOverlay({
          summaryText: this.summaryText,
          onClose: () => { this.showSummary = false }
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
