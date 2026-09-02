import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MoodItem } from '../../models/YouyuModels'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct MoodChipRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selected: string = 'calm'
  onSelect: (id: string) => void = (_id: string) => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      ForEach(MoodCatalog.all(), (m: MoodItem) => {
        this.MoodDot(m)
      }, (m: MoodItem) => m.id)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }

  @Builder
  MoodDot(m: MoodItem) {
    Column({ space: 4 }) {
      Column() {
        AppIcon({
          name: MoodCatalog.iconOf(m.id),
          iconSize: Theme.icon.md,
          color: this.selected === m.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.selected === m.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      Text(m.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.selected === m.id ? Theme.colors().brandDeep : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .onClick(() => this.onSelect(m.id))
  }
}
