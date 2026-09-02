import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct SearchInputBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop placeholder: string = '搜索关键词'
  @Prop value: string = ''
  onChange: (v: string) => void = () => {}
  onSubmit: () => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      TextInput({ text: this.value, placeholder: this.placeholder })
        .layoutWeight(1)
        .height(42)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textSecondary)
        .backgroundColor(Color.Transparent)
        .onChange((v: string): void => this.onChange(v))
        .onSubmit((): void => this.onSubmit())
      if (this.value.length > 0) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .width(32)
        .height(32)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => this.onChange(''))
      }
    }
    .width('100%')
    .padding({ left: Theme.space.s4, right: Theme.space.s3 })
    .height(48)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.pill)
    .border({ width: 1.5, color: Theme.colors().brandPrimaryContainer })
    .shadow({ radius: 12, color: 'rgba(0,122,255,0.08)', offsetY: 2 })
  }
}
