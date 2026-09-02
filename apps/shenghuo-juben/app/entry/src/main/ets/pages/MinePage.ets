import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { ConfirmSheet } from '../components/script/ConfirmSheet'
import { AppConfig } from '../config/AppConfig'
import { ProfileStore } from '../services/ProfileStore'
import { ScriptStore } from '../services/ScriptStore'
import { PrivacyService } from '../services/PrivacyService'
import { PhotoPickService } from '../services/PhotoPickService'
import { ExportService } from '../services/ExportService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State nickname: string = '生活主角'
  @State avatarPath: string = ''
  @State scriptCount: number = 0
  @State toastText: string = ''
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  @State showRevokeConfirm: boolean = false
  @State editingName: boolean = false
  @State draftName: string = ''
  @StorageLink('darkModeEnabled') darkMode: boolean = false
  @Prop reloadToken: number = 0
  @State lastToken: number = -1

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.nickname = await ProfileStore.getNickname()
    this.avatarPath = await ProfileStore.getAvatarPath()
    this.scriptCount = await ScriptStore.countAll()
    this.darkMode = await ProfileStore.isDarkMode()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async saveNickname(): Promise<void> {
    const name = this.draftName.trim()
    if (name.length === 0) {
      this.showToast('昵称不能为空')
      return
    }
    await ProfileStore.setNickname(name)
    this.nickname = name
    this.editingName = false
    this.showToast('昵称已更新')
  }

  private async pickAvatar(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    const path = await PhotoPickService.pickOneImage(ctx)
    if (path.length === 0) {
      this.showToast('未选择头像或读取失败')
      return
    }
    await ProfileStore.setAvatarPath(path)
    this.avatarPath = path
    this.showToast('头像已更新')
  }

  private async toggleDarkMode(enabled: boolean): Promise<void> {
    await ProfileStore.setDarkMode(enabled)
    this.darkMode = enabled
  }

  private async handleRevoke(): Promise<void> {
    this.showRevokeConfirm = false
    await PrivacyService.revoke()
    this.showToast('已撤回隐私同意，请重新同意后再使用')
  }

  private async exportFile(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    try {
      const path = await ExportService.exportToFile(ctx)
      this.showToast(path.length > 0 ? '已导出到应用目录' : '导出失败')
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  private async copyExport(): Promise<void> {
    const ok = await ExportService.copyAllToClipboard()
    this.showToast(ok ? '已复制全部剧本到剪贴板' : '复制失败')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s3 }) {
            Row() {
              if (this.avatarPath.length > 0) {
                Image(this.avatarPath)
                  .width(64)
                  .height(64)
                  .borderRadius(Theme.radius.pill)
                  .objectFit(ImageFit.Cover)
                  .onClick((): void => { void this.pickAvatar() })
              } else {
                Column() {
                  AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
                }
                .width(64)
                .height(64)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.pickAvatar() })
              }

              Column({ space: 4 }) {
                if (this.editingName) {
                  TextInput({ text: this.draftName, placeholder: '输入昵称' })
                    .onChange((v: string) => { this.draftName = v })
                  AppButton({
                    label: '保存昵称',
                    variant: 'primary',
                    onTap: (): void => { void this.saveNickname() }
                  })
                } else {
                  Text(this.nickname)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`已创作 ${this.scriptCount} 部生活剧本`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textSecondary)
                  Text('点击头像可更换')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: Theme.space.s3 })

              if (!this.editingName) {
                AppIcon({ name: 'edit', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
                  .onClick((): void => {
                    this.draftName = this.nickname
                    this.editingName = true
                  })
              }
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)
          .shadow({ radius: 12, color: 'rgba(45,45,45,0.06)', offsetY: 4 })

          Image($r('app.media.banner_script_01'))
            .width('100%')
            .height(100)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)

          Text('本地备份')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          this.SettingRow('导出剧本到文件', (): void => { void this.exportFile() })
          this.SettingRow('复制全部剧本', (): void => { void this.copyExport() })

          Text('设置与隐私')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          this.SettingRow('隐私政策', (): void => { this.showPrivacy = true })
          this.SettingRow('用户协议', (): void => { this.showAgreement = true })
          this.SettingRow('撤回隐私同意', (): void => { this.showRevokeConfirm = true })

          Row({ space: Theme.space.s3 }) {
            Text('深色模式')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean) => { void this.toggleDarkMode(v) })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)

          Row() {
            Text('应用版本')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text(`v${AppConfig.APP_VERSION}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ top: Theme.space.s4, bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(44,62,80,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(50)
      }

      if (this.showPrivacy) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacy = false } })
      }
      if (this.showAgreement) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreement = false } })
      }
      if (this.showRevokeConfirm) {
        ConfirmSheet({
          title: '撤回隐私同意',
          message: '撤回后将返回协议页，再次使用须重新勾选同意。剧本数据仍保存在本机。',
          confirmLabel: '确认撤回',
          onCancel: (): void => { this.showRevokeConfirm = false },
          onConfirm: (): void => { void this.handleRevoke() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }

  @Builder
  SettingRow(label: string, onTap: () => void) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
      Blank()
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(12)
    .onClick(onTap)
  }
}
