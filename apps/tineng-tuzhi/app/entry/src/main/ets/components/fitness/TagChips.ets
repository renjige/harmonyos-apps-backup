import { Theme } from '../design-system/Theme'
import { WorkoutTagOption } from '../../models/WorkoutModels'

@Component
export struct TagChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedKey: string = ''
  onSelect: (key: string) => void = () => {}

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(WorkoutTagOption.all(), (o: WorkoutTagOption) => {
        Text(o.label)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.selectedKey === o.key ?
            Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .margin({ right: 8, bottom: 8 })
          .backgroundColor(this.selectedKey === o.key ?
            Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.onSelect(o.key) })
      }, (o: WorkoutTagOption) => o.key)
    }
    .width('100%')
  }
}
