import { Theme } from '../design-system/Theme'

class ResultOption {
  key: string = ''
  label: string = ''
}

@Component
export struct ResultPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop current: string = ''
  onChange: (value: string) => void = () => {}

  private options(): ResultOption[] {
    const out: ResultOption[] = []
    const add = (key: string, label: string) => {
      const o = new ResultOption()
      o.key = key
      o.label = label
      out.push(o)
    }
    add('pass', '验收通过')
    add('pending', '待处理')
    add('fail', '验收不通过')
    return out
  }

  private tone(key: string): string {
    if (key === 'pass') {
      return '#2F6B3E'
    }
    if (key === 'fail') {
      return '#8B3030'
    }
    return '#8A5A18'
  }

  build() {
    Column({ space: 8 }) {
      Text('验收结论')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Column({ space: 8 }) {
        ForEach(this.options(), (opt: ResultOption) => {
          Text(opt.label)
            .fontSize(Theme.type.body)
            .fontWeight(this.current === opt.key ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.current === opt.key ? Color.White : Theme.colors().textPrimary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 16, bottom: 16 })
            .backgroundColor(this.current === opt.key ? this.tone(opt.key) : Theme.colors().surfaceSubtle)
            .borderRadius(14)
            .border({
              width: 1,
              color: this.current === opt.key ? this.tone(opt.key) : Theme.colors().strokeStrong
            })
            .onClick(() => this.onChange(opt.key))
        }, (opt: ResultOption) => opt.key)
      }
    }
    .width('100%')
  }
}
