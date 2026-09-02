import { Theme } from '../design-system/Theme'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct MoodTagRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedMood: string = ''
  onPick: (mood: string) => void = () => {}

  private moods(): string[] {
    const list: string[] = []
    list.push('平静')
    list.push('愉悦')
    list.push('疲惫')
    list.push('焦虑')
    list.push('专注')
    return list
  }

  private moodColor(mood: string): string {
    if (mood === '愉悦') {
      return Theme.colors().successContainer
    }
    if (mood === '平静') {
      return Theme.colors().brandPrimaryContainer
    }
    if (mood === '专注') {
      return Theme.colors().surfaceSubtle
    }
    if (mood === '疲惫') {
      return Theme.colors().warningContainer
    }
    if (mood === '焦虑') {
      return Theme.colors().dangerContainer
    }
    return Theme.colors().surfaceSubtle
  }

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.moods(), (mood: string) => {
          Text(CategoryEmojiUtil.moodChip(mood))
            .fontSize(Theme.type.subhead)
            .fontColor(this.selectedMood === mood ?
              Theme.colors().brandPrimary : Theme.colors().textPrimary)
            .fontWeight(this.selectedMood === mood ? FontWeight.Medium : FontWeight.Normal)
            .padding({ left: 12, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.selectedMood === mood ?
              Theme.colors().brandPrimaryContainer : this.moodColor(mood))
            .borderRadius(Theme.radius.pill)
            .border({
              width: this.selectedMood === mood ? 1 : 0,
              color: Theme.colors().brandPrimary
            })
            .onClick(() => this.onPick(mood))
        }, (mood: string) => mood)
      }
      .padding({ right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
