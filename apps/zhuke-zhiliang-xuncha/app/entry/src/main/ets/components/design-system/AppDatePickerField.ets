import { Theme } from './Theme'
import { AppIcon } from './AppIcon'
import { DatePickerLauncher } from './DateFormatUtil'

/** 预约/表单日期字段 — 系统 CalendarPickerDialog，禁止手输 yyyy-MM-dd */
@Component
export struct AppDatePickerField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = '预约日期'
  @Link value: string
  @Prop placeholder: string = '请选择日期'
  @Prop minDaysFromToday: number = 0
  @Prop maxDaysFromToday: number = 90
  @State pressed: boolean = false

  private displayText(): string {
    return this.value.length > 0 ? this.value : this.placeholder
  }

  private openPicker(): void {
    DatePickerLauncher.openDate(this.value, this.minDaysFromToday, this.maxDaysFromToday, (picked: string) => {
      this.value = picked
    })
  }

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.displayText())
          .fontSize(Theme.type.body)
          .fontColor(this.value.length > 0 ? Theme.colors().textPrimary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .height(48)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(12)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .opacity(this.pressed ? 0.82 : 1)
    .scale({ x: this.pressed ? 0.98 : 1, y: this.pressed ? 0.98 : 1 })
    .animation({ duration: Theme.motion.instant, curve: Curve.EaseOut })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) {
        this.pressed = true
      }
      if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
        this.pressed = false
      }
    })
    .onClick(() => this.openPicker())
  }
}

/** 预约时段 — 系统 TimePickerDialog（24 小时制） */
@Component
export struct AppTimePickerField {
  @Prop label: string = '预约时段'
  @Prop value: string = ''
  @Prop placeholder: string = '请选择时段'
  onChange: (value: string) => void = () => {}

  private displayText(): string {
    return this.value.length > 0 ? this.value : this.placeholder
  }

  private openPicker(): void {
    DatePickerLauncher.openTime(this.value, (picked: string) => {
      this.onChange(picked)
    })
  }

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Text(this.displayText())
          .fontSize(Theme.type.body)
          .fontColor(this.value.length > 0 ? Theme.colors().textPrimary : Theme.colors().textTertiary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .height(48)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.sm)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.openPicker())
  }
}
