import { Theme } from '../design-system/Theme'
import { StyleChip } from '../../models/LanguageCraftModels'

/** 2×2 可点选项卡：不用 @Builder 回调，点击走组件 onPick */
@Component
export struct OptionPickGrid {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop title: string = ''
  @Prop selectedKey: string = ''
  @Prop chips: StyleChip[] = []
  onPick: (key: string) => void = (key: string): void => {
    if (key.length === 0) {
      return
    }
  }

  private handlePick(key: string): void {
    this.onPick(key)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.of(this.darkModeOn).textSecondary)
          .width('100%')
      }
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.chips, (chip: StyleChip) => {
          Column({ space: 4 }) {
            Text(chip.label)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.selectedKey === chip.key ?
                Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
              .width('100%')
            if (chip.hint.length > 0) {
              Text(chip.hint)
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedKey === chip.key ?
                  Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textSecondary)
                .maxLines(2)
                .width('100%')
            }
          }
          .width('48%')
          .constraintSize({ minHeight: 64 })
          .padding(Theme.space.s3)
          .margin({ bottom: 8 })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.selectedKey === chip.key ?
            Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({
            width: 1,
            color: this.selectedKey === chip.key ?
              Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).strokeHairline
          })
          .onClick((): void => { this.handlePick(chip.key) })
          .gesture(
            TapGesture({ count: 1 }).onAction((): void => { this.handlePick(chip.key) })
          )
        }, (chip: StyleChip) => chip.key)
      }
      .width('100%')
    }
    .width('100%')
  }
}
