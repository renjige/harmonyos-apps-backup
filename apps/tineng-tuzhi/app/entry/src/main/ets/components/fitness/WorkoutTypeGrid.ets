import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { WorkoutTypeOption } from '../../models/WorkoutModels'

@Component
export struct WorkoutTypeGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedKey: string = ''
  onSelect: (key: string) => void = () => {}

  private iconFor(name: string): AppIconName {
    if (name === 'chart') {
      return 'chart'
    }
    if (name === 'biz') {
      return 'biz'
    }
    if (name === 'check') {
      return 'check'
    }
    return 'empty'
  }

  build() {
    GridRow({ columns: 4, gutter: Theme.space.s2 }) {
      ForEach(WorkoutTypeOption.all(), (opt: WorkoutTypeOption) => {
        GridCol() {
          Column({ space: Theme.space.s1 }) {
            Column() {
              AppIcon({
                name: this.iconFor(opt.iconName),
                iconSize: Theme.icon.md,
                color: this.selectedKey === opt.key ?
                  Theme.colors().brandPrimary : Theme.colors().textSecondary
              })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedKey === opt.key ?
              Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            Text(opt.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.selectedKey === opt.key ?
                Theme.colors().brandPrimary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.s2)
          .onClick((): void => { this.onSelect(opt.key) })
        }
      }, (opt: WorkoutTypeOption) => opt.key)
    }
    .width('100%')
  }
}
