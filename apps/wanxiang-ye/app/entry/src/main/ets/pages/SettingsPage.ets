import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { PrivacyService } from '../services/PrivacyService'
import { UserDataStore } from '../services/UserDataStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onShowToast: (msg: string) => void = () => {}
  onThemeChanged: () => void = () => {}
  @State themeMode: string = 'system'
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  @State confirmRevoke: boolean = false

  aboutToAppear(): void {
    void this.loadTheme()
  }

  private async loadTheme(): Promise<void> {
    this.themeMode = await UserDataStore.getThemeMode()
  }

  private async setTheme(mode: string): Promise<void> {
    this.themeMode = mode
    await UserDataStore.saveThemeMode(mode)
    const ctx = AppContextService.getContext()
    ThemeAppearance.apply(mode, ctx !== null ? ctx : undefined)
    this.onThemeChanged()
    this.onShowToast('主题已切换')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.onClose()
    this.onShowToast('已撤回隐私同意，应用将恢复初始隐私状态')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('设置')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('返回')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => this.onClose())
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('主题模式')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')

            Row({ space: Theme.space.s2 }) {
              this.ThemeChip('浅色', 'light')
              this.ThemeChip('深色', 'dark')
              this.ThemeChip('跟随系统', 'system')
            }
            .width('100%')

            Column() {
              AppListRow({
                title: '用户协议',
                onTap: (): void => { this.showAgreement = true }
              })
              AppListRow({
                title: '隐私政策',
                onTap: (): void => { this.showPrivacy = true }
              })
            }
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            Column({ space: Theme.space.s2 }) {
              Text('关于万象页')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('版本 1.0.0 · 智慧信息聚合 · 专题合辑 · 阅读笔记')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
              Text('运营者：魏文波')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Start)

            if (!this.confirmRevoke) {
              AppButton({
                label: '撤回隐私同意',
                variant: 'secondary',
                onTap: (): void => { this.confirmRevoke = true }
              })
            } else {
              Column({ space: Theme.space.s2 }) {
                Text('确认撤回隐私同意？')
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                Row({ space: Theme.space.s2 }) {
                  AppButton({
                    label: '取消',
                    variant: 'secondary',
                    onTap: (): void => { this.confirmRevoke = false }
                  }).layoutWeight(1)
                  AppButton({
                    label: '确认撤回',
                    variant: 'primary',
                    onTap: (): void => { void this.handleRevokePrivacy() }
                  }).layoutWeight(1)
                }
                .width('100%')
              }
            }
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showPrivacy) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacy = false } })
      }
      if (this.showAgreement) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreement = false } })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(25)
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .border({
        width: this.themeMode === mode ? 0 : 1,
        color: Theme.colors().strokeStrong
      })
      .onClick((): void => { void this.setTheme(mode) })
  }
}
