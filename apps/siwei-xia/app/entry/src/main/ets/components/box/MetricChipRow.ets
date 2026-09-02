import { Theme } from '../design-system/Theme'

class MetricChip {
  label: string = ''
  value: string = ''
  active: boolean = false
  onTap: () => void = () => {}
}

@Component
export struct MetricChipRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop chipsCsv: string = ''

  private parseChips(): MetricChip[] {
    const out: MetricChip[] = []
    if (this.chipsCsv.length === 0) {
      return out
    }
    const parts = this.chipsCsv.split(';')
    for (const part of parts) {
      if (part.length === 0) {
        continue
      }
      const seg = part.split('|')
      if (seg.length < 3) {
        continue
      }
      const chip = new MetricChip()
      chip.label = seg[0]
      chip.value = seg[1]
      chip.active = seg[2] === '1'
      out.push(chip)
    }
    return out
  }

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.parseChips(), (c: MetricChip) => {
          Column({ space: 2 }) {
            Text(c.value)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(c.active ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
            Text(c.label)
              .fontSize(Theme.type.caption)
              .fontColor(c.active ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
          }
          .padding({ left: 14, right: 14, top: 10, bottom: 10 })
          .backgroundColor(c.active ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }, (c: MetricChip) => `${c.label}|${c.value}|${c.active}`)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }
}
