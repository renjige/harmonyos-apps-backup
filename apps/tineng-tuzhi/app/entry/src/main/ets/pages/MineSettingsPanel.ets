import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MineSettingsPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop themeMode: string = 'system'
  onClose: () => void = () => {}
  onTheme: (mode: string) => void = () => {}
  onClearCache: () => void = () => {}
  onClearRecords: () => void = () => {}
  onRevoke: () => void = () => {}
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.onTheme(mode) })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('设置与隐私')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick((): void => { this.onClose() })
        }
        .width('100%')

        Text('外观主题')
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.ThemeChip('浅色', 'light')
          this.ThemeChip('深色', 'dark')
          this.ThemeChip('跟随系统', 'system')
        }
        .width('100%')

        AppListRow({
          title: '《用户协议》',
          subtitle: '',
          onTap: (): void => { this.showAgreementDoc = true }
        })
        AppListRow({
          title: '《隐私政策》',
          subtitle: '',
          onTap: (): void => { this.showPrivacyDoc = true }
        })

        AppButton({
          label: '清除缓存',
          variant: 'secondary',
          onTap: (): void => this.onClearCache()
        })

        AppButton({
          label: '清除全部运动记录',
          variant: 'secondary',
          onTap: (): void => { this.confirmClear = true }
        })

        Row() {
          AppButton({
            label: '撤回隐私同意',
            variant: 'secondary',
            onTap: (): void => { this.confirmRevoke = true }
          })
        }
        .width('100%')
        .onClick((): void => { this.confirmRevoke = true })
      }
      .width('100%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }

      if (this.confirmClear) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Theme.colors().overlayScrim)
          Column({ space: Theme.space.s4 }) {
            Text('确认清除全部运动记录？')
              .fontSize(Theme.type.title3)
              .fontColor(Theme.colors().textPrimary)
            Text('此操作不可恢复，成就进度也将重置。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppButton({
                  label: '取消',
                  variant: 'secondary',
                  onTap: (): void => { this.confirmClear = false }
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: '确认清除',
                  variant: 'primary',
                  onTap: (): void => {
                    this.confirmClear = false
                    this.onClearRecords()
                  }
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
          }
          .width('84%')
          .padding(Theme.space.s6)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }
        .width('100%')
        .height('100%')
        .zIndex(30)
      }

      if (this.confirmRevoke) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Theme.colors().overlayScrim)
          Column({ space: Theme.space.s4 }) {
            Text('确认撤回隐私同意？')
              .fontSize(Theme.type.title3)
              .fontColor(Theme.colors().textPrimary)
            Text('撤回后仍可在本页再次查看协议全文。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppButton({
                  label: '取消',
                  variant: 'secondary',
                  onTap: (): void => { this.confirmRevoke = false }
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: '确认撤回',
                  variant: 'danger',
                  onTap: (): void => {
                    this.confirmRevoke = false
                    this.onRevoke()
                  }
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
          }
          .width('84%')
          .padding(Theme.space.s6)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }
        .width('100%')
        .height('100%')
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(20)
  }
}
