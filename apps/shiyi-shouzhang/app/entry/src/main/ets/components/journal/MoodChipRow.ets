import { Theme } from '../design-system/Theme'
import { MoodOption } from '../../models/ShiyiModels'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct MoodChipRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedId: string = ''
  onSelect: (id: string) => void = (id: string) => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      ForEach(MoodCatalog.all(), (item: MoodOption) => {
        Column({ space: 4 }) {
          Text(item.mark)
            .fontSize(18)
          Text(item.label)
            .fontSize(Theme.type.caption)
            .fontWeight(this.selectedId === item.id ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedId === item.id ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 10, bottom: 10 })
        .backgroundColor(this.selectedId === item.id ? item.tint : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.lg)
        .border({
          width: this.selectedId === item.id ? 1 : 0,
          color: Theme.colors().brandAccent
        })
        .onClick(() => {
          this.onSelect(item.id)
        })
      }, (item: MoodOption) => item.id)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
