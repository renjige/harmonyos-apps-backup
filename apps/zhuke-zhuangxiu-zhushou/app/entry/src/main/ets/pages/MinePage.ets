import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { RenoLocalStore } from '../services/RenoLocalStore'
import { RenoService } from '../services/RenoService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { ConfirmSheet } from '../components/reno/ConfirmSheet'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '筑科装修助手'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('notifyEnabled') notifyEnabled: boolean = true
  @State showSettings: boolean = false
  @State showAbout: boolean = false
  @State showClear: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenProjects: () => void = () => {}
  onOpenNotes: () => void = () => {}
  onCleared: () => void = () => {}

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.showSettings = false
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async clearData(): Promise<void> {
    await RenoService.clearAll()
    this.showClear = false
    this.onCleared()
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showAbout) {
          this.AboutPanel()
        } else {
          AppHeader({ title: '我的', subtitle: '我的装修' })
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              Column({ space: 8 }) {
                Text(this.isLoggedIn() ? this.currentUsername : '游客')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.isLoggedIn() ? '登录后可将记录同步到云端' : '游客数据保存在本机，关闭应用不会丢失')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)

              this.MenuRow('我的项目', '查看和管理装修项目', () => this.onOpenProjects())
              this.MenuRow('我的记录', '现场记录与事项清单', () => this.onOpenNotes())
              Row() {
                Column({ space: 2 }) {
                  Text('提醒设置')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text(this.notifyEnabled ? '应用内事项提醒已开启' : '应用内事项提醒已关闭')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Toggle({ type: ToggleType.Switch, isOn: this.notifyEnabled })
                  .onChange((v: boolean) => { void RenoLocalStore.setNotifyEnabled(v) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)

              this.MenuRow('数据管理', '查看本地摘要或清空本机数据', () => { this.showClear = true })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', () => { this.showSettings = true })
              this.MenuRow('关于筑科装修助手', '版本与产品说明', () => { this.showAbout = true })

              if (this.isLoggedIn()) {
                AppButton({
                  label: '退出登录',
                  variant: 'secondary',
                  onTap: (): void => { void AuthService.logout(); this.onLogout() }
                })
              } else {
                AppButton({ label: '登录 / 注册', onTap: (): void => { this.onOpenLogin() } })
              }
              Text('版本 1.0.0')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 8 })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .maxLines(3)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }

      if (this.showLegal) {
        LegalDocOverlay({ kind: this.legalKind, onClose: () => { this.showLegal = false } })
          .width('100%').height('100%')
      }
      if (this.showClear) {
        ConfirmSheet({
          title: '清空本机装修数据？',
          message: '将删除本机项目、事项、材料与记录，且无法恢复。',
          confirmLabel: '清空',
          onCancel: () => { this.showClear = false },
          onConfirm: () => { void this.clearData() }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(title: string, sub: string, tap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(title).fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
        Text(sub).fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(tap)
  }

  @Builder
  AboutPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() { AppIcon({ name: 'chevron', iconSize: Theme.icon.md }) }
          .width(44).height(44).rotate({ angle: 180 }).justifyContent(FlexAlign.Center)
          .onClick(() => { this.showAbout = false })
        Text('关于筑科装修助手').fontSize(Theme.type.title3).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })
      Text('轻量装修过程记录工具。帮助业主记录项目、阶段、事项、材料、现场与验收。验收结果仅供个人对照，不构成专业鉴定。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Text('版本 1.0.0 · 运营者 齐齐哈尔筑科建筑工程有限责任公司')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textTertiary)
        .padding({ left: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() { AppIcon({ name: 'chevron', iconSize: Theme.icon.md }) }
          .width(44).height(44).justifyContent(FlexAlign.Center).rotate({ angle: 180 })
          .onClick(() => { this.showSettings = false })
        Text('设置与隐私').fontSize(Theme.type.title3).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => { this.legalKind = 'agreement'; this.showLegal = true }
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => { this.legalKind = 'privacy'; this.showLegal = true }
          })
          Text('个人信息收集清单与第三方共享清单见应用内协议及上架资料。本应用不申请定位、通讯录、电话或麦克风权限。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          AppButton({
            label: '注销账号',
            variant: 'danger',
            onTap: (): void => { void this.handleDeleteAccount() }
          })
          Row() {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { void this.handleRevokePrivacy() }
            })
          }
          .width('100%')
          .onClick((): void => { void this.handleRevokePrivacy() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
