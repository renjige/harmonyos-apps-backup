import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { DatePickerLauncher } from '../design-system/DateFormatUtil'
import { TripDateHelp } from '../../models/TripModels'
import { TripNav } from '../../services/TripNav'
import { TripStore } from '../../services/TripStore'

@Component
export struct CalendarPane {
  @State selected: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false

  aboutToAppear(): void {
    const cur = AppStorage.get<string>('homeDateIso') ?? ''
    this.selected = cur.length > 0 ? cur : TripDateHelp.todayIso()
  }

  private openPicker(): void {
    DatePickerLauncher.openDate(this.selected, -365, 365, (picked: string) => {
      this.selected = picked
    })
  }

  private countLine(): string {
    const n = TripStore.itemsOnDate(this.selected).length
    if (n === 0) {
      return '这一天还没有事项'
    }
    return `这一天有 ${n} 项事项`
  }

  private confirm(): void {
    TripNav.setHomeDate(this.selected)
    AppStorage.setOrCreate('mainTabIndex', 0)
    TripNav.closeCalendar()
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      AppNavBar({
        title: '日历',
        onBack: (): void => { TripNav.closeCalendar() }
      })
      Column({ space: 8 }) {
        Text('查看某一天的安排')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.palette(this.darkModeOn).textSecondary)
          .width('100%')
        Text(this.selected)
          .fontSize(Theme.type.displayS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.palette(this.darkModeOn).textPrimary)
          .width('100%')
        Text(this.countLine())
          .fontSize(Theme.type.body)
          .fontColor(Theme.palette(this.darkModeOn).textTertiary)
          .width('100%')
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .onClick((): void => { this.openPicker() })

      Text('点日期选择，再看当天时间线')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.palette(this.darkModeOn).textTertiary)
        .width('100%')
        .padding({ left: Theme.space.pageX })

      Blank()
      Text('查看这一天')
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.palette(this.darkModeOn).brandOnPrimary)
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ top: 14, bottom: 14 })
        .backgroundColor(Theme.palette(this.darkModeOn).brandPrimary)
        .borderRadius(Theme.radius.lg)
        .margin({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s6
        })
        .onClick((): void => { this.confirm() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}
