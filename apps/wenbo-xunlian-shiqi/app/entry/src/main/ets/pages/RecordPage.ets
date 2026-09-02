import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { TrainingListCard } from '../components/training/TrainingListCard'
import { TrainingTimeline } from '../components/training/TrainingTimeline'
import { CalendarCell, TrainingRecord } from '../models/TrainingModels'
import { TrainingStore } from '../services/TrainingStore'
import { TrainingAnalytics } from '../services/TrainingAnalytics'
import { TrainingDetailNav } from '../services/TrainingDetailNav'
import { DateHelper } from '../services/DateHelper'
import { DataRefresh } from '../services/DataRefresh'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @State items: TrainingRecord[] = []
  @State viewMode: number = 0
  @State year: number = 2026
  @State month: number = 8
  @State cells: CalendarCell[] = []
  @State selectedKey: string = ''
  @State dayRecords: TrainingRecord[] = []
  @State monthSessions: number = 0
  @State toastText: string = ''
  @Prop refreshToken: number = 0
  @Prop asOverlay: boolean = false
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.initCalendar()
    this.reload()
  }

  onDataEpoch(): void {
    this.reload()
  }

  private initCalendar(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    this.selectedKey = DateHelper.todayKey()
    this.buildGrid()
  }

  private reload(): void {
    this.items = TrainingStore.list()
    this.buildGrid()
    this.loadDay()
  }

  private buildGrid(): void {
    this.cells = TrainingAnalytics.buildCalendarCells(this.year, this.month)
    this.monthSessions = TrainingAnalytics.countMonthSessions(this.year, this.month)
  }

  private loadDay(): void {
    this.dayRecords = this.selectedKey.length > 0 ? TrainingStore.byDate(this.selectedKey) : []
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y -= 1
    }
    if (m > 12) {
      m = 1
      y += 1
    }
    this.month = m
    this.year = y
    this.buildGrid()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async deleteItem(id: string): Promise<void> {
    await TrainingStore.remove(id)
    DataRefresh.bump()
    this.reload()
    this.showToast('已删除训练记录')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            if (this.asOverlay) {
              Row() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
              }
              .width(40)
              .height(40)
              .justifyContent(FlexAlign.Center)
              .rotate({ angle: 180 })
              .onClick((): void => { this.onClose() })
            }
            Text('训练日志')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Row({ space: Theme.space.s2 }) {
              this.ModeChip('列表', 0)
              this.ModeChip('日历', 1)
              this.ModeChip('时间轴', 2)
            }
          }
          .width('100%')
          .padding({ top: Theme.space.s6 })

          if (this.viewMode === 0) {
            this.ListSection()
          } else if (this.viewMode === 1) {
            this.CalendarSection()
          } else {
            TrainingTimeline()
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: this.asOverlay ? Theme.space.s10 : Theme.space.s10 + 88 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ModeChip(label: string, mode: number) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.viewMode === mode ? '#FFFFFF' : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.viewMode === mode ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.viewMode = mode })
  }

  @Builder
  ListSection() {
    if (this.items.length === 0) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ambient_empty_bg'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
          .opacity(0.35)
        AppEmpty({
          title: '还没有训练记录',
          description: '回到首页点「开始训练」，记录你的第一次进步',
          actionLabel: '去首页开始',
          onAction: (): void => { AppStorage.setOrCreate('mainTabIndex', 0) }
        })
      }
    } else {
      List({ space: Theme.space.s3 }) {
        ForEach(this.items, (item: TrainingRecord) => {
          ListItem() {
            TrainingListCard({
              record: item,
              onTap: (): void => { TrainingDetailNav.open(item.id) }
            })
          }
          .swipeAction({
            end: {
              builder: (): void => { this.DeleteAction(item.id) },
              actionAreaDistance: 64
            }
          })
        }, (item: TrainingRecord) => item.id)
      }
      .width('100%')
    }
  }

  @Builder
  DeleteAction(id: string) {
    Row() {
      Text('删除')
        .fontSize(Theme.type.body)
        .fontColor('#FFFFFF')
    }
    .width(72)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().danger)
    .onClick((): void => { void this.deleteItem(id) })
  }

  @Builder
  CalendarSection() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.shiftMonth(-1) })
        Text(DateHelper.monthLabel(this.year, this.month))
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.shiftMonth(1) })
      }
      .width('100%')

      Text(`本月 ${this.monthSessions} 次训练`)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .textAlign(TextAlign.Center)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('14.28%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 8 })
        }, (w: string) => w)

        ForEach(this.cells, (cell: CalendarCell, idx: number) => {
          if (!cell.inMonth) {
            Column()
              .width('14.28%')
              .height(44)
          } else {
            Column({ space: 4 }) {
              Text(`${cell.day}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.selectedKey === cell.dateKey ? '#FFFFFF' : Theme.colors().textPrimary)
              if (cell.hasRecord) {
                Row()
                  .width(6)
                  .height(6)
                  .borderRadius(3)
                  .backgroundColor(this.selectedKey === cell.dateKey ? '#FFFFFF' : '#FF6B35')
              } else {
                Blank().height(6)
              }
            }
            .width('14.28%')
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedKey === cell.dateKey ? Theme.primaryButtonFill() : Color.Transparent)
            .borderRadius(Theme.radius.sm)
            .onClick((): void => {
              this.selectedKey = cell.dateKey
              this.loadDay()
            })
          }
        }, (cell: CalendarCell, idx: number) => `${idx}_${cell.dateKey}`)
      }
      .width('100%')

      if (this.dayRecords.length === 0) {
        Text(this.selectedKey.length > 0 ? `${this.selectedKey} 暂无训练` : '选择日期查看记录')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(Theme.space.s6)
      } else {
        Column({ space: Theme.space.s3 }) {
          Text(`${this.selectedKey} 的训练`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.dayRecords, (item: TrainingRecord) => {
            TrainingListCard({
              record: item,
              onTap: (): void => { TrainingDetailNav.open(item.id) }
            })
          }, (item: TrainingRecord) => item.id)
        }
      }
    }
    .width('100%')
  }
}
