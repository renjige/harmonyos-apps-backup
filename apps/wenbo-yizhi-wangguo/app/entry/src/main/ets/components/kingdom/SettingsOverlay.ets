import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { KingdomLocalStore } from '../../services/KingdomLocalStore'
import { LocalBundle } from '../../models/KingdomModels'

@Component
export struct SettingsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @State sound: boolean = true
  @State fontScale: number = 1

  aboutToAppear(): void {
    const s = KingdomLocalStore.settings()
    this.sound = s.sound
    this.fontScale = s.fontScale
  }

  private async persist(): Promise<void> {
    const b: LocalBundle = KingdomLocalStore.snapshot()
    b.settings.sound = this.sound
    b.settings.fontScale = this.fontScale
    await KingdomLocalStore.saveBundle(b)
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.onClose())
        Text('练习设置')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')

      Row() {
        Text('音效提示')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.sound })
          .selectedColor(Theme.colors().brandPrimary)
          .onChange((v: boolean) => {
            this.sound = v
            void this.persist()
          })
      }
      .width('100%')
      .height(52)

      Column({ space: Theme.space.s2 }) {
        Text('题目字号')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Slider({ value: this.fontScale, min: 0.9, max: 1.3, step: 0.1 })
          .selectedColor(Theme.colors().brandPrimary)
          .onChange((v: number) => {
            this.fontScale = v
            void this.persist()
          })
      }
      .width('100%')

      Text('反馈：可通过应用市场留言联系运营者魏文波。本应用无支付、无广告。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')

      AppButton({ label: '关闭', variant: 'secondary', onTap: () => this.onClose() })
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.s6)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
