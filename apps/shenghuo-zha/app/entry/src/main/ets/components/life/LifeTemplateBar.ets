import { Theme } from '../design-system/Theme'
import { LifeNoteTemplate } from '../../models/LifeModels'

@Component
export struct LifeTemplateBar {
  onPick: (tpl: LifeNoteTemplate) => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('快捷记录')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(LifeNoteTemplate.all(), (tpl: LifeNoteTemplate) => {
          Text(tpl.title)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .constraintSize({ minHeight: 36 })
            .onClick((): void => { this.onPick(tpl) })
        }, (tpl: LifeNoteTemplate) => tpl.key)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
