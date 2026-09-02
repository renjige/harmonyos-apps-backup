import { Theme } from '../design-system/Theme'
import { MoodKeyUtil } from '../../models/WarmCompanionModels'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct MoodSelectorRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedMood: string = ''
  onPick: (mood: string) => void = () => {}

  private moodColor(key: string): string {
    if (key === 'great') {
      return Theme.colors().successContainer
    }
    if (key === 'good') {
      return Theme.colors().brandPrimaryContainer
    }
    if (key === 'ok') {
      return Theme.colors().surfaceSubtle
    }
    if (key === 'low') {
      return Theme.colors().warningContainer
    }
    if (key === 'bad') {
      return Theme.colors().dangerContainer
    }
    return Theme.colors().surfaceSubtle
  }

  build() {
    Row({ space: Theme.space.s2 }) {
      ForEach(MoodKeyUtil.all(), (key: string) => {
        Column({ space: 4 }) {
          Text(CategoryEmojiUtil.moodMark(key))
            .fontSize(22)
          Text(MoodKeyUtil.label(key))
            .fontSize(Theme.type.caption)
            .fontColor(this.selectedMood === key ?
              Theme.colors().brandPrimary : Theme.colors().textSecondary)
            .fontWeight(this.selectedMood === key ? FontWeight.Medium : FontWeight.Normal)
        }
        .width(56)
        .padding({ top: 10, bottom: 10 })
        .backgroundColor(this.selectedMood === key ?
          Theme.colors().brandPrimaryContainer : this.moodColor(key))
        .borderRadius(Theme.radius.lg)
        .border({
          width: this.selectedMood === key ? 2 : 0,
          color: Theme.colors().brandPrimary
        })
        .shadow(this.selectedMood === key ?
          { radius: 12, color: 'rgba(245,166,35,0.45)', offsetY: 2 } :
          { radius: 0, color: 'transparent', offsetY: 0 })
        .onClick(() => this.onPick(key))
      }, (key: string) => key)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
