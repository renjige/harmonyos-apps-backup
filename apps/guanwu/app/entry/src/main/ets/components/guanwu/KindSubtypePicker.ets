import { Theme } from '../design-system/Theme'
import { KindOption, SubtypeOption } from '../../models/ObserveModels'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct KindSubtypePicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'thought'
  @Prop subtypeKey: string = ''
  onKindSelect: (key: string) => void = () => {}
  onSubtypeSelect: (key: string) => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('观察类型')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row() {
        ForEach(KindOption.all(), (k: KindOption) => {
          Text(CategoryEmojiUtil.chipLabel(k.key, k.label))
            .fontSize(Theme.type.bodyS)
            .fontColor(this.kind === k.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.kind === k.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => this.onKindSelect(k.key))
        }, (k: KindOption) => k.key)
      }
      .width('100%')

      Text('细分标签')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(SubtypeOption.forKind(this.kind), (s: SubtypeOption) => {
          Text(s.label)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.subtypeKey === s.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.subtypeKey === s.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => this.onSubtypeSelect(s.key))
        }, (s: SubtypeOption) => s.key)
      }
      .width('100%')
    }
    .width('100%')
  }
}
