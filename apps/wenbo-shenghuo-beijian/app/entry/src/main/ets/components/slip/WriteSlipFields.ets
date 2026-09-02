import { Theme } from '../design-system/Theme'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { CategoryCatalog } from '../../models/SlipModels'
import { SlipDateUtil } from '../../services/SlipDateUtil'

@Component
export struct WriteSlipFields {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Link category: string
  @Link date: string
  @Link remindOn: boolean
  @Link reminderTime: string
  @Link important: boolean

  build() {
    Column({ space: Theme.space.s5 }) {
      Text('分类')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(CategoryCatalog.all(), (c: string) => {
          Text(c)
            .fontSize(Theme.type.caption)
            .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { this.category = c })
        }, (c: string) => c)
      }
      .width('100%')

      Text('日期')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 8 }) {
        this.DateChip('今天', SlipDateUtil.todayIso())
        this.DateChip('明天', SlipDateUtil.tomorrowIso())
      }
      .width('100%')
      AppDatePickerField({
        label: '自定义日期',
        value: this.date,
        placeholder: '选择日期',
        minDaysFromToday: -7,
        maxDaysFromToday: 180,
        onChange: (v: string): void => { this.date = v }
      })

      Row() {
        Text('智能提醒')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.remindOn })
          .selectedColor(Theme.colors().brandPrimary)
          .onChange((on: boolean) => { this.remindOn = on })
      }
      .width('100%')
      if (this.remindOn) {
        AppTimePickerField({
          label: '提醒时间',
          value: this.reminderTime,
          placeholder: '不开启 / 自定义时间',
          onChange: (v: string): void => { this.reminderTime = v }
        })
      }

      Row() {
        Text('重要程度')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(this.important ? '重要' : '普通')
          .fontSize(Theme.type.body)
          .fontColor(this.important ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
          .onClick((): void => { this.important = !this.important })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  DateChip(label: string, iso: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.date === iso ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.date === iso ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick((): void => { this.date = iso })
  }
}
