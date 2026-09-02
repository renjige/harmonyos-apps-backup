import { Theme } from '../design-system/Theme'
import { YunNoteTemplate } from '../../models/YunModels'

@Component
export struct YunMoodRow {
  @Prop current: string = ''
  onPick: (mood: string) => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('今日心情')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(YunNoteTemplate.moods(), (mood: string) => {
          Text(mood)
            .fontSize(Theme.type.caption)
            .fontColor(this.current === mood ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
            .backgroundColor(this.current === mood ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .constraintSize({ minHeight: 36 })
            .onClick((): void => { this.onPick(mood) })
        }, (mood: string) => mood)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
