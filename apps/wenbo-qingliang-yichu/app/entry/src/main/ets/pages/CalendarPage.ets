import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import {
  WardrobeLookLogModel,
  WardrobeSummaryModel
} from '../models/WardrobeModels'
import { WardrobeLocalStore } from '../services/WardrobeLocalStore'
import { MonthCalendarView } from '../components/calendar/MonthCalendarView'
import { CalendarLookDetail } from '../components/calendar/CalendarLookDetail'

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth?: () => void

  @State currentYear: number = 2026
  @State currentMonth: number = 8
  @State selectedDate: string = '2026-08-20'
  @State logs: WardrobeLookLogModel[] = []
  @State logDates: string[] = []
  @State selectedLog?: WardrobeLookLogModel = undefined
  @State summary: WardrobeSummaryModel = new WardrobeSummaryModel()
  @State toastText: string = ''

  aboutToAppear(): void {
    const today = new Date()
    this.currentYear = today.getFullYear()
    this.currentMonth = today.getMonth() + 1
    const todayStr = `${this.currentYear}-${String(this.currentMonth).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
    this.selectedDate = todayStr
    this.loadData()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2500)
  }

  private loadData(): void {
    this.logs = WardrobeLocalStore.getLookLogs()
    this.logDates = this.logs.map((x: WardrobeLookLogModel) => x.date)
    this.summary = WardrobeLocalStore.getSummary()
    this.updateSelectedLog(this.selectedDate)
  }

  private updateSelectedLog(dateStr: string): void {
    this.selectedDate = dateStr
    this.selectedLog = WardrobeLocalStore.getLookLogByDate(dateStr)
  }

  private handleRecordToday(dateStr: string): void {
    const defaultLog = new WardrobeLookLogModel(
      'log_' + Date.now().toString(36),
      dateStr,
      'outfit-01',
      '夏日清爽日常搭配',
      ['浅蓝亚麻衬衫', '米白直筒休闲阔腿裤', '经典小白休闲平底鞋'],
      '清爽',
      '日常',
      '舒适自在'
    )
    WardrobeLocalStore.addLookLog(defaultLog)
    this.loadData()
    this.showToast(`已成功记录 ${dateStr} 穿搭`)
  }

  private handleDeleteLog(dateStr: string): void {
    WardrobeLocalStore.deleteLookLog(dateStr)
    this.loadData()
    this.showToast(`已删除 ${dateStr} 穿搭记录`)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          // 1. Top Header
          Row() {
            Column({ space: 2 }) {
              Text('穿搭日历')
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Text('记录每一天的喜欢，看见自己的穿搭秩序')
                .fontSize(Theme.type.caption1)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Row({ space: 4 }) {
              AppIcon({ name: 'calendar', iconSize: 14, color: Theme.colors().brandPrimary })
              Text(`本月打卡 ${this.summary.monthlyLooks} 天`)
                .fontSize(Theme.type.caption1)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(Theme.isDark() ? '#1C332D' : '#DDF2EB')
            .borderRadius(Theme.radius.pill)
          }
          .width('100%')
          .padding({ top: Theme.space.s4 })

          // 2. Month Calendar View
          MonthCalendarView({
            year: this.currentYear,
            month: this.currentMonth,
            selectedDate: this.selectedDate,
            logDates: this.logDates,
            onSelectDate: (d: string) => this.updateSelectedLog(d),
            onChangeMonth: (delta: number) => {
              let m = this.currentMonth + delta
              let y = this.currentYear
              if (m < 1) {
                m = 12
                y--
              } else if (m > 12) {
                m = 1
                y++
              }
              this.currentMonth = m
              this.currentYear = y
            }
          })

          // 3. Selected Day Look Detail Card
          CalendarLookDetail({
            dateStr: this.selectedDate,
            hasLog: this.selectedLog !== undefined,
            log: this.selectedLog ?? new WardrobeLookLogModel(),
            onRecordToday: (d: string) => this.handleRecordToday(d),
            onDeleteLog: (d: string) => this.handleDeleteLog(d)
          })

          // 4. Lightweight Data Statistics Card (生活方式风格统计)
          Column({ space: Theme.space.s3 }) {
            Row() {
              Row({ space: 4 }) {
                AppIcon({ name: 'chart', iconSize: 16, color: Theme.colors().brandPrimary })
                Text('风格数据概览')
                  .fontSize(Theme.type.callout)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              Blank()
              Text('个人穿搭轨迹')
                .fontSize(Theme.type.caption2)
                .fontColor(Theme.colors().textTertiary)
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              this.StatCard('衣橱总单品', `${this.summary.totalItems} 件`, 'wardrobe')
              this.StatCard('本月穿搭', `${this.summary.monthlyLooks} 次`, 'calendar')
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              this.StatCard('最常穿颜色', this.summary.topColor, 'sparkle')
              this.StatCard('最常穿风格', this.summary.topStyle, 'hanger')
            }
            .width('100%')

            // Scene insight
            Row({ space: 8 }) {
              AppIcon({ name: 'sparkle', iconSize: 14, color: Theme.colors().brandSecondary })
              Text(`最常出现场景：${this.summary.topScene}，保持极简舒适的穿搭节奏。`)
                .fontSize(Theme.type.caption1)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .backgroundColor(Theme.isDark() ? '#1A2926' : '#F7FAF8')
            .borderRadius(Theme.radius.sm)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({
            radius: 12,
            color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(10,37,64,0.05)',
            offsetY: 2
          })
        }
        .padding({
          left: Theme.space.pagePadding,
          right: Theme.space.pagePadding,
          bottom: 40
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfaceBackground)

      // Top Toast
      if (this.toastText.length > 0) {
        Column() {
          Row({ space: 8 }) {
            AppIcon({ name: 'check', iconSize: 16, color: '#FFFFFF' })
            Text(this.toastText)
              .fontSize(Theme.type.subheadline)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(31,41,39,0.92)')
          .borderRadius(Theme.radius.pill)
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.25)', offsetY: 4 })
        }
        .width('100%')
        .padding({ top: 30 })
        .alignItems(HorizontalAlign.Center)
        .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private StatCard(title: string, value: string, iconName: AppIconName) {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        AppIcon({ name: iconName, iconSize: 12, color: Theme.colors().brandSecondary })
        Text(title)
          .fontSize(Theme.type.caption2)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      Text(value)
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.isDark() ? '#1A2926' : '#F7FAF8')
    .borderRadius(Theme.radius.sm)
  }
}
