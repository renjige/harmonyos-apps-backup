import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AppSettings } from '../models/PuzzleModels'
import { PrivacyService } from '../services/PrivacyService'
import { PuzzleStore } from '../services/PuzzleStore'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '旅行拼图'
  onToast: (text: string) => void = (text: string) => {}
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State showSettings: boolean = false
  @State showProfile: boolean = false
  @State showLegal: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State displayName: string = ''
  @State colorMode: string = 'system'
  @State tripCount: number = 0
  @State cityCount: number = 0
  @State photoCount: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    const s = PuzzleStore.settings()
    this.displayName = s.displayName
    this.colorMode = s.colorMode
    const stats = PuzzleStore.stats()
    this.tripCount = stats.tripCount
    this.cityCount = stats.cityCount
    this.photoCount = stats.photoCount
  }

  private nameText(): string {
    if (this.displayName.trim().length > 0) {
      return this.displayName.trim()
    }
    return '旅行者'
  }

  private openSettings(): void {
    this.showSettings = true
    AppStorage.setOrCreate('puzzleMinePanel', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeSettings(): void {
    this.showSettings = false
    this.showProfile = false
    AppStorage.setOrCreate('puzzleMinePanel', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async persistSettings(): Promise<void> {
    const s = new AppSettings()
    s.displayName = this.displayName.trim()
    s.colorMode = this.colorMode
    s.darkFollowSystem = this.colorMode === 'system'
    const ok = await PuzzleStore.saveSettings(s)
    if (this.colorMode === 'dark') {
      ThemeAppearance.apply('dark', this.getUIContext().getHostContext() as common.UIAbilityContext)
    } else if (this.colorMode === 'light') {
      ThemeAppearance.apply('light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    } else {
      ThemeAppearance.apply('system', this.getUIContext().getHostContext() as common.UIAbilityContext)
    }
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试')
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.closeSettings()
    this.onToast('已撤回隐私同意，再次进入须重新勾选协议')
  }

  private async handleClearCache(): Promise<void> {
    const ok = await PuzzleStore.clearAll()
    if (!ok) {
      this.onToast('清除失败，请稍后再试')
      return
    }
    this.reload()
    this.onToast('本机拼图数据已清空')
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.closeSettings() })
      }
      .width('100%')
      .padding({ bottom: Theme.space.s4 })

      Scroll() {
        Column() {
          Text('外观模式')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            ForEach(['system', 'light', 'dark'], (mode: string) => {
              Text(mode === 'system' ? '跟随系统' : (mode === 'light' ? '浅色' : '深色'))
                .fontSize(Theme.type.caption)
                .fontColor(this.colorMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.colorMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.colorMode = mode
                  void this.persistSettings()
                })
            }, (mode: string) => mode)
          }
          .width('100%')
          .margin({ top: Theme.space.s2, bottom: Theme.space.s5 })

          AppButton({ label: '查看《用户协议》', variant: 'secondary', onTap: (): void => {
            this.legalKind = 'agreement'
            this.showLegal = true
          } })
          AppButton({ label: '查看《隐私政策》', variant: 'secondary', onTap: (): void => {
            this.legalKind = 'privacy'
            this.showLegal = true
          } })
            .margin({ top: Theme.space.s3 })

          Row() {
            AppButton({ label: '撤回隐私同意', variant: 'secondary', onTap: (): void => { void this.handleRevokePrivacy() } })
          }
          .width('100%')
          .margin({ top: Theme.space.s3 })
          .onClick((): void => { void this.handleRevokePrivacy() })

          AppButton({ label: '清除本机拼图数据', variant: 'danger', onTap: (): void => { void this.handleClearCache() } })
            .margin({ top: Theme.space.s5 })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  build() {
    Stack() {
      if (this.showSettings) {
        this.SettingsPanel()
      } else {
        Scroll() {
          Column() {
            Row() {
              Column() {
                Text(this.nameText())
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                Text('本机旅行记忆管理者')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textSecondary)
                  .margin({ top: Theme.space.s1 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding({ top: Theme.space.pageY })

            Row({ space: Theme.space.s3 }) {
              AppStatCard({ label: '旅行次数', value: `${this.tripCount}` }).layoutWeight(1)
              AppStatCard({ label: '城市数', value: `${this.cityCount}` }).layoutWeight(1)
              AppStatCard({ label: '照片数', value: `${this.photoCount}` }).layoutWeight(1)
            }
            .width('100%')
            .margin({ top: Theme.space.s5 })

            Column() {
              TextInput({ text: this.displayName, placeholder: '设置昵称（仅本机）' })
                .width('100%')
                .onChange((v: string) => { this.displayName = v })
                .onSubmit((): void => { void this.persistSettings() })
              AppListRow({
                title: '设置与隐私',
                subtitle: '深色模式 · 协议 · 撤回同意',
                onTap: (): void => { this.openSettings() }
              })
            }
            .width('100%')
            .margin({ top: Theme.space.s6 })

            Text(`${this.appName} v1.0.0 · 数据仅存本机`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: Theme.space.s8, bottom: Theme.space.s10 })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollBar(BarState.Off)
      }

      if (this.showLegal) {
        Column() {
          LegalDocOverlay({
            kind: this.legalKind,
            onClose: (): void => { this.showLegal = false }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
