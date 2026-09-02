import { common } from '@kit.AbilityKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { PrivacyService } from '../services/PrivacyService'
import { SettingsService, ThemePreference } from '../services/SettingsService'
import { ExportImportService } from '../services/ExportImportService'
import { CacheService } from '../services/CacheService'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  onDataChanged: () => void = () => {}
  @State toastText: string = ''
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  @State showImport: boolean = false
  @State importText: string = ''
  @State darkMode: boolean = false
  @State themeMode: ThemePreference = 'system'
  private uiContext: common.UIAbilityContext | null = null

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async exportJson(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    try {
      const path = await ExportImportService.exportToFile(this.uiContext)
      const json = await ExportImportService.buildJson()
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, json)
      pasteboard.getSystemPasteboard().setData(pasteData)
      this.showToast(`已导出并复制 JSON；文件：${path}`)
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  private async confirmImport(): Promise<void> {
    const msg = await ExportImportService.importFromJson(this.importText)
    this.closeImport()
    this.importText = ''
    this.showToast(msg)
    this.onDataChanged()
  }

  private openImport(): void {
    this.showImport = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeImport(): void {
    this.showImport = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async handleRevoke(): Promise<void> {
    await PrivacyService.revoke()
    this.showToast('已撤回隐私同意，再次进入须重新同意')
  }

  private clearCache(): void {
    if (this.uiContext === null) {
      return
    }
    const n = CacheService.clearExportCache(this.uiContext)
    this.showToast(n > 0 ? `已清除 ${n} 个导出缓存文件` : '暂无缓存可清除')
  }

  private async applyTheme(mode: ThemePreference): Promise<void> {
    this.themeMode = mode
    await SettingsService.setThemeMode(mode)
    if (mode === 'dark') {
      Theme.setColorMode('dark')
      this.darkMode = true
    } else if (mode === 'light') {
      Theme.setColorMode('light')
      this.darkMode = false
    } else {
      Theme.setColorMode('system')
      this.darkMode = false
    }
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('设置')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .margin({ top: Theme.space.s4, bottom: Theme.space.s2 })

          this.SettingRow('导出作品 JSON', (): void => { void this.exportJson() })
          this.SettingRow('导入作品 JSON', (): void => { this.openImport() })
          this.SettingRow('清除缓存', (): void => { this.clearCache() })
          this.SettingRow('隐私政策', (): void => { this.showPrivacy = true })
          this.SettingRow('用户协议', (): void => { this.showAgreement = true })
          this.SettingRow('撤回隐私同意', (): void => { void this.handleRevoke() })

          Column({ space: Theme.space.s2 }) {
            Text('外观模式')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              this.ThemeChip('浅色', 'light')
              this.ThemeChip('深色', 'dark')
              this.ThemeChip('跟随系统', 'system')
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text('提示：卸载应用将清除本机数据，请定期导出 JSON 备份。')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(18)
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }

      if (this.showImport) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Row() {
              Text('粘贴 JSON 数据')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Row() {
                AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
              }
              .width(40)
              .height(40)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.closeImport() })
            }
            .width('100%')

            TextArea({ text: this.importText, placeholder: '粘贴导出的 JSON 内容…' })
              .height(280)
              .fontSize(Theme.type.bodyS)
              .onChange((v: string) => { this.importText = v })

            AppButton({
              label: '确认导入',
              variant: 'primary',
              onTap: (): void => { void this.confirmImport() }
            })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(30)
      }

      if (this.showPrivacy) {
        LegalDocOverlay({
          kind: 'privacy',
          onClose: (): void => { this.showPrivacy = false }
        })
      }
      if (this.showAgreement) {
        LegalDocOverlay({
          kind: 'agreement',
          onClose: (): void => { this.showAgreement = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
      void SettingsService.getThemeMode().then((m: ThemePreference) => {
        this.themeMode = m
        this.darkMode = m === 'dark'
        if (m === 'dark') {
          Theme.setColorMode('dark')
        } else if (m === 'light') {
          Theme.setColorMode('light')
        } else {
          Theme.setColorMode('system')
        }
      })
    })
  }

  @Builder
  ThemeChip(label: string, mode: ThemePreference) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.applyTheme(mode) })
  }

  @Builder
  SettingRow(label: string, onTap: () => void) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }
}
