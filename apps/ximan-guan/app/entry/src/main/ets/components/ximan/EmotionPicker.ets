import { Theme } from '../design-system/Theme'
import { EmotionOption } from '../../models/ObservationModels'

@Component
export struct EmotionPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedKey: string = 'calm'
  onSelect: (key: string) => void = () => {}

  build() {
    Row() {
      ForEach(EmotionOption.all(), (em: EmotionOption) => {
        Column({ space: 4 }) {
          Column() {
            Text(em.tag)
              .fontSize(16)
          }
          .width(36)
          .height(36)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.selectedKey === em.key ? em.color : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .border({
            width: this.selectedKey === em.key ? 2 : 0,
            color: em.color
          })
          Text(em.label)
            .fontSize(10)
            .fontColor(this.selectedKey === em.key ?
              Theme.colors().textPrimary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .height(Theme.icon.minTouch)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => this.onSelect(em.key))
      }, (em: EmotionOption) => em.key)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
