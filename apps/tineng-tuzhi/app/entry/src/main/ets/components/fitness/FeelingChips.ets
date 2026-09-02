import { Theme } from '../design-system/Theme'
import { FeelingOption } from '../../models/WorkoutModels'

@Component
export struct FeelingChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedKey: string = ''
  onSelect: (key: string) => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      ForEach(FeelingOption.all(), (o: FeelingOption) => {
        Text(o.label)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.selectedKey === o.key ?
            Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedKey === o.key ?
            Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.onSelect(o.key) })
      }, (o: FeelingOption) => o.key)
    }
    .width('100%')
  }
}
