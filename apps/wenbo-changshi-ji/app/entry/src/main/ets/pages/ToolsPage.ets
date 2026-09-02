import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseTime } from '../models/CommonSenseModels'
import { LifeToolService } from '../services/LifeToolService'

@Component
export struct ToolsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State fromDate: string = CommonSenseTime.todayKey()
  @State toDate: string = CommonSenseTime.todayKey()
  @State birth: string = '1998-01-01'
  @State termDate: string = CommonSenseTime.todayKey()
  @State cmText: string = '170'
  @State result: string = ''

  private numOf(text: string): number {
    const n = Number.parseFloat(text)
    return Number.isNaN(n) ? 0 : n
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('生活工具')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('日期计算')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          AppDatePickerField({
            label: '起始日期',
            value: this.fromDate,
            minDaysFromToday: -800,
            maxDaysFromToday: 800,
            onChange: (v: string): void => { this.fromDate = v }
          })
          AppDatePickerField({
            label: '结束日期',
            value: this.toDate,
            minDaysFromToday: -800,
            maxDaysFromToday: 800,
            onChange: (v: string): void => { this.toDate = v }
          })
          AppButton({
            label: '计算间隔天数',
            onTap: (): void => {
              const n = LifeToolService.daysBetween(this.fromDate, this.toDate)
              this.result = `${this.fromDate} 到 ${this.toDate} 共 ${n} 天`
            }
          })

          Text('年龄计算')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          AppDatePickerField({
            label: '出生日期',
            value: this.birth,
            minDaysFromToday: -30000,
            maxDaysFromToday: 0,
            onChange: (v: string): void => { this.birth = v }
          })
          AppButton({
            label: '计算周岁',
            variant: 'secondary',
            onTap: (): void => {
              this.result = `周岁约 ${LifeToolService.ageYears(this.birth)} 岁`
            }
          })

          Text('节气查询')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          AppDatePickerField({
            label: '查询日期',
            value: this.termDate,
            minDaysFromToday: -400,
            maxDaysFromToday: 400,
            onChange: (v: string): void => { this.termDate = v }
          })
          AppButton({
            label: '查询邻近节气',
            variant: 'secondary',
            onTap: (): void => {
              this.result = LifeToolService.solarTermNear(this.termDate)
            }
          })

          Text('单位换算')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          TextInput({ text: this.cmText, placeholder: '输入数字' })
            .width('100%')
            .onChange((v: string): void => { this.cmText = v })
          Row({ space: 8 }) {
            Text('厘米→英寸')
              .fontSize(12)
              .fontColor(Theme.colors().brandOnPrimary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .padding(10)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.md)
              .onClick((): void => {
                this.result = `${this.cmText} cm = ${LifeToolService.cmToInch(this.numOf(this.cmText))} in`
              })
            Text('千克→斤')
              .fontSize(12)
              .fontColor(Theme.colors().brandOnPrimary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .padding(10)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.md)
              .onClick((): void => {
                this.result = `${this.cmText} kg = ${LifeToolService.kgToJin(this.numOf(this.cmText))} 斤`
              })
          }
          .width('100%')
          Row({ space: 8 }) {
            Text('摄氏→华氏')
              .fontSize(12)
              .fontColor(Theme.colors().brandPrimary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .padding(10)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.md)
              .onClick((): void => {
                this.result = `${this.cmText} ℃ = ${LifeToolService.cToF(this.numOf(this.cmText))} ℉`
              })
            Text('斤→千克')
              .fontSize(12)
              .fontColor(Theme.colors().brandPrimary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .padding(10)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.md)
              .onClick((): void => {
                this.result = `${this.cmText} 斤 = ${LifeToolService.jinToKg(this.numOf(this.cmText))} kg`
              })
          }
          .width('100%')

          if (this.result.length > 0) {
            Text(this.result)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.card)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
