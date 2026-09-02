import { Theme } from '../design-system/Theme'

class ChipItem {
  key: string = ''
  label: string = ''
}

@Component
export struct FilterChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop current: string = 'all'
  @Prop inspectMode: boolean = false
  onChange: (key: string) => void = () => {}

  private chips(): ChipItem[] {
    const out: ChipItem[] = []
    const add = (key: string, label: string) => {
      const c = new ChipItem()
      c.key = key
      c.label = label
      out.push(c)
    }
    add('all', '全部')
    if (this.inspectMode) {
      add('todo', '待验收')
      add('done', '已完成')
      add('abnormal', '异常')
    } else {
      add('pass', '通过')
      add('pending', '待处理')
      add('fail', '不通过')
    }
    return out
  }

  build() {
    Row({ space: 8 }) {
      ForEach(this.chips(), (chip: ChipItem) => {
        Text(chip.label)
          .fontSize(Theme.type.subhead)
          .fontWeight(this.current === chip.key ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.current === chip.key ? Theme.chipFg(true) : Theme.chipFg(false))
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .backgroundColor(this.current === chip.key ? Theme.chipBg(true) : Theme.chipBg(false))
          .borderRadius(Theme.radius.pill)
          .border({
            width: 1,
            color: this.current === chip.key ? Theme.chipBg(true) : Theme.colors().strokeStrong
          })
          .onClick(() => this.onChange(chip.key))
      }, (chip: ChipItem) => chip.key)
    }
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
