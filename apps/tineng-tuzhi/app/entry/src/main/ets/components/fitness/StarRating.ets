import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct StarRating {
  @Prop value: number = 0
  onChange: (n: number) => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      ForEach([1, 2, 3, 4, 5], (n: number) => {
        Column() {
          AppIcon({
            name: 'ai',
            iconSize: Theme.icon.md,
            color: n <= this.value ? Theme.colors().brandPrimary : Theme.colors().textTertiary
          })
        }
        .constraintSize({ minWidth: 44, minHeight: 44 })
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onChange(n) })
      }, (n: number) => `star-${n}`)
    }
    .width('100%')
  }
}
