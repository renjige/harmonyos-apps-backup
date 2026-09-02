import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct RitualCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop joy: string = ''
  @Prop thanks: string = ''
  @Prop keep: string = ''
  onJoy: (v: string) => void = (v: string) => {}
  onThanks: (v: string) => void = (v: string) => {}
  onKeep: (v: string) => void = (v: string) => {}
  onSkip: () => void = () => {}
  onSave: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日三问')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('想写就写，不想写也可以轻轻跳过。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.joy, placeholder: '一件开心的事' })
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => {
          this.onJoy(v)
        })
      TextInput({ text: this.thanks, placeholder: '一个值得感谢的人' })
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => {
          this.onThanks(v)
        })
      TextInput({ text: this.keep, placeholder: '一句想留下的话' })
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => {
          this.onKeep(v)
        })
      Row({ space: Theme.space.s3 }) {
        AppButton({
          label: '跳过',
          variant: 'ghost',
          onTap: (): void => {
            this.onSkip()
          }
        }).layoutWeight(1)
        AppButton({
          label: '留下',
          variant: 'secondary',
          onTap: (): void => {
            this.onSave()
          }
        }).layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }
}
