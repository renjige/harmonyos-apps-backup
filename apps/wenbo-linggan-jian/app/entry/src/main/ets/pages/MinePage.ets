import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { ConfirmSheet } from '../components/slip/ConfirmSheet'
import { MineSettingsPane, MineExportPane } from '../components/mine/MineSheets'
import { MinePrefRow } from '../components/mine/MinePrefRow'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { SlipStore } from '../services/SlipStore'
import { SlipNav } from '../services/SlipNav'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '灵感笺'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('fontLevel') fontLevel: number = 1
  @State showSettings: boolean = false
  @State showExport: boolean = false
  @State showClear: boolean = false
  @State exportText: string = ''
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State noteCount: number = 0
  @State favCount: number = 0
  @State tagCount: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  @Prop @Watch('onRefresh') refreshToken: number = 0

  aboutToAppear(): void {
    this.refreshStats()
  }

  onRefresh(): void {
    this.refreshStats()
  }

  private refreshStats(): void {
    this.noteCount = SlipStore.all().length
    this.favCount = SlipStore.favorites().length
    this.tagCount = SlipStore.usedTagNames().length
  }

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
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      AppStorage.setOrCreate('tabBarHidden', false)
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async toggleDark(on: boolean): Promise<void> {
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    await SlipStore.setDark(on)
  }

  private async setFont(level: number): Promise<void> {
    Theme.applyFontLevel(level)
    await SlipStore.setFontLevel(level)
  }

  private async copyExport(): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.exportText)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('已复制到剪贴板')
    } catch {
      this.showToast('请长按文字自行复制')
    }
  }

  private async doClear(): Promise<void> {
    await SlipStore.clearAll()
    this.showClear = false
    this.refreshStats()
    this.showToast('本机灵感已清空')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          MineSettingsPane({
            onClose: (): void => {
              this.showSettings = false
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onOpenAgreement: (): void => {
              this.legalKind = 'agreement'
              this.showLegal = true
            },
            onOpenPrivacy: (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            },
            onDeleteAccount: (): void => { void this.handleDeleteAccount() },
            onRevoke: (): void => { void this.handleRevokePrivacy() }
          })
        } else {
          this.MainPanel()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showClear) {
        ConfirmSheet({
          title: '确定要清空本机灵感吗？',
          subtitle: '清空后无法从应用里找回。',
          keepLabel: '留下它们',
          leaveLabel: '清空',
          onKeep: (): void => { this.showClear = false },
          onLeave: (): void => { void this.doClear() }
        })
      }

      if (this.showExport) {
        MineExportPane({
          exportText: this.exportText,
          onCopy: (): void => { void this.copyExport() },
          onClose: (): void => { this.showExport = false }
        })
      }

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
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPanel() {
    Column() {
      Column({ space: 6 }) {
        Text('我的灵感')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.isLoggedIn() ? this.currentUsername : '这是只属于你的私人灵感手账')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            this.StatCell(`${this.noteCount}`, '灵感')
            this.StatCell(`${this.favCount}`, '收藏')
            this.StatCell(`${this.tagCount}`, '标签')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          MinePrefRow({ title: '我的收藏', caption: '值得再次遇见的灵感', onTap: (): void => {
            SlipNav.openFavLibrary()
          } })
          MinePrefRow({ title: '标签管理', caption: '记录时可以新增自定义标签', onTap: (): void => { SlipNav.openWrite('') } })
          MinePrefRow({ title: '智慧整理', caption: '按习惯给出可解释的整理建议', onTap: (): void => {
            SlipNav.openDiagnose()
          } })
          MinePrefRow({ title: '灵感卡片', caption: '四种笺面', onTap: (): void => {
            const recent = SlipStore.recent(1)
            if (recent.length > 0) {
              SlipNav.openCard(recent[0].id)
            } else {
              this.showToast('先记录一条灵感，再做成灵感卡')
            }
          } })
          MinePrefRow({ title: '深色模式', caption: this.darkModeOn ? '夜笺' : '素笺米白', onTap: (): void => {
            void this.toggleDark(!this.darkModeOn)
          } })
          Row({ space: 8 }) {
            Text('字体大小').fontSize(Theme.type.subhead).fontColor(Theme.colors().textPrimary).layoutWeight(1)
            Text('适中')
              .fontSize(Theme.type.caption)
              .fontColor(this.fontLevel === 1 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.fontLevel === 1 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.setFont(1) })
            Text('稍大')
              .fontSize(Theme.type.caption)
              .fontColor(this.fontLevel === 2 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.fontLevel === 2 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.setFont(2) })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          MinePrefRow({ title: '导出 TXT', caption: '复制本机灵感文字', onTap: (): void => {
            this.exportText = SlipStore.exportText()
            this.showExport = true
          } })
          MinePrefRow({ title: '导出 JSON', caption: '复制结构化数据', onTap: (): void => {
            this.exportText = SlipStore.exportJson()
            this.showExport = true
          } })
          MinePrefRow({ title: '清除本地数据', caption: '需二次确认', onTap: (): void => { this.showClear = true } })
          MinePrefRow({ title: '机构通知', caption: '轻轻一声', onTap: (): void => { SlipNav.openMessages() } })
          MinePrefRow({ title: '设置与隐私', caption: '协议 · 撤回 · 注销', onTap: (): void => {
            this.showSettings = true
            AppStorage.setOrCreate('tabBarHidden', true)
          } })
          MinePrefRow({ title: '关于灵感笺', caption: '1.0.0', onTap: (): void => {
            this.showToast('灵感笺 · 把想法变成值得收藏的灵感')
          } })

          if (this.isLoggedIn()) {
            AppButton({
              label: '退出登录',
              variant: 'secondary',
              onTap: (): void => {
                void AuthService.logout()
                this.onLogout()
              }
            })
          } else {
            AppButton({
              label: '登录 / 注册',
              onTap: (): void => { this.onOpenLogin() }
            })
          }

          Text('灵感笺  1.0.0')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8, bottom: 12 })
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
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatCell(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandAccent)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
  }
}
