import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct MineSettingsPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appearance: string = 'system'
  @Prop notifyEnabled: boolean = true
  @Prop confirmDelete: boolean = false
  onBack: () => void = () => {}
  onAppearance: (mode: string) => void = (_m: string) => {}
  onNotify: (on: boolean) => void = (_on: boolean) => {}
  onOpenAgreement: () => void = () => {}
  onOpenPrivacy: () => void = () => {}
  onClearCache: () => void = () => {}
  onDeleteAccount: () => void = () => {}
  onRevokePrivacy: () => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.onBack())
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('显示')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 8 }) {
            this.ModeChip('跟随系统', 'system')
            this.ModeChip('浅色', 'light')
            this.ModeChip('深色', 'dark')
          }
          .width('100%')
          Row() {
            Text(this.notifyEnabled ? '机构通知：开' : '机构通知：关')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.notifyEnabled })
              .onChange((on: boolean) => this.onNotify(on))
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => this.onOpenAgreement()
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => this.onOpenPrivacy()
          })
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => this.onClearCache()
          })
          AppButton({
            label: this.confirmDelete ? '再点一次确认注销' : '注销账号',
            variant: 'danger',
            onTap: (): void => this.onDeleteAccount()
          })
          Row() {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => this.onRevokePrivacy()
            })
          }
          .width('100%')
          .onClick((): void => this.onRevokePrivacy())
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ModeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.appearance === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.appearance === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.onAppearance(mode))
  }
}
