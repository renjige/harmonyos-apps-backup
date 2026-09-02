import { Theme } from '../design-system/Theme'

@Component
export struct ChoicePair {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop leftLabel: string = '正常'
  @Prop rightLabel: string = '异常'
  @Prop leftValue: string = 'ok'
  @Prop rightValue: string = 'abnormal'
  @Prop current: string = ''
  onChange: (value: string) => void = () => {}

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 10 }) {
        this.choice(this.leftLabel, this.leftValue)
        this.choice(this.rightLabel, this.rightValue)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  choice(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.body)
      .fontWeight(this.current === value ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.current === value ? Theme.chipFg(true) : Theme.chipFg(false))
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding({ top: 14, bottom: 14 })
      .backgroundColor(this.current === value ? Theme.chipBg(true) : Theme.chipBg(false))
      .borderRadius(14)
      .border({
        width: 1,
        color: this.current === value ? Theme.chipBg(true) : Theme.colors().strokeStrong
      })
      .onClick(() => this.onChange(value))
  }
}
