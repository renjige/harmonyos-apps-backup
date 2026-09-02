import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { ConfirmSheet } from '../components/slip/ConfirmSheet'
import { MineSettingsPane, MineExportPane, MinePrefRow } from '../components/mine/MineSheets'
import { MineLifeCard, MineReviewCard } from '../components/mine/MineStatsCards'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { SlipStore } from '../services/SlipStore'
import { SlipStats } from '../services/SlipStats'
import { SlipNav } from '../services/SlipNav'
import { WeekBar } from '../models/SlipModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '生活备笺'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('dailyRemindOn') dailyRemindOn: boolean = false
  @StorageLink('slipRefresh') @Watch('onSlipRefresh') slipRefresh: number = 0
  @State showSettings: boolean = false
  @State showExport: boolean = false
  @State showClear: boolean = false
  @State showClearDone: boolean = false
  @State exportText: string = ''
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State totalDone: number = 0
  @State weekDone: number = 0
  @State streak: number = 0
  @State topCat: string = '生活'
  @State bars: WeekBar[] = []
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    this.refreshStats()
  }

  onSlipRefresh(): void {
    this.refreshStats()
  }

  private refreshStats(): void {
    const all = SlipStore.all()
    this.totalDone = SlipStats.totalDone(all)
    this.weekDone = SlipStats.weekDone(all)
    this.streak = SlipStats.streakDays(all)
    this.topCat = SlipStats.topCategory(all)
    this.bars = SlipStats.weekBars(all)
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
    AppStorage.setOrCreate('minePanelOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      AppStorage.setOrCreate('minePanelOpen', false)
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

  private async toggleRemind(on: boolean): Promise<void> {
    await SlipStore.setRemind(on)
    this.showToast(on ? '打开今日页时，会提示未完成的提醒。' : '已关闭首页提醒提示')
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
    this.showToast('全部备笺已清空')
  }

  private async doClearDone(): Promise<void> {
    await SlipStore.clearCompleted()
    this.showClearDone = false
    this.refreshStats()
    this.showToast('已完成的历史记录已删除')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          MineSettingsPane({
            onClose: (): void => {
              this.showSettings = false
              AppStorage.setOrCreate('minePanelOpen', false)
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onOpenAgreement: (): void => { this.legalKind = 'agreement'; this.showLegal = true },
            onOpenPrivacy: (): void => { this.legalKind = 'privacy'; this.showLegal = true },
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
          title: '所有备笺都会被删除，该操作无法恢复。',
          subtitle: '删除后无法恢复，是否继续？',
          keepLabel: '先留着',
          leaveLabel: '清空全部',
          onKeep: (): void => { this.showClear = false },
          onLeave: (): void => { void this.doClear() }
        })
      }
      if (this.showClearDone) {
        ConfirmSheet({
          title: '已完成的备笺会被删除，该操作无法恢复。',
          subtitle: '待办事项会保留。',
          keepLabel: '先留着',
          leaveLabel: '删除历史',
          onKeep: (): void => { this.showClearDone = false },
          onLeave: (): void => { void this.doClearDone() }
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
        LegalDocOverlay({ kind: this.legalKind, onClose: () => { this.showLegal = false } })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPanel() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Column({ space: 6 }) {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.isLoggedIn() ? this.currentUsername : '游客也可以把生活轻轻记下来')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')

        MineLifeCard({
          totalDone: this.totalDone,
          weekDone: this.weekDone,
          streak: this.streak,
          topCat: this.topCat,
          bars: this.bars
        })
        MineReviewCard({
          weekDone: this.weekDone,
          streak: this.streak,
          topCat: this.topCat
        })

        if (!this.isLoggedIn()) {
          AppButton({ label: '登录 / 注册', variant: 'secondary', onTap: (): void => { this.onOpenLogin() } })
        } else {
          AppButton({ label: '退出登录', variant: 'ghost', onTap: (): void => { void AuthService.logout(); this.onLogout() } })
        }

        MinePrefRow({ title: '外观设置', caption: this.darkModeOn ? '深色' : '暖米白', onTap: (): void => { void this.toggleDark(!this.darkModeOn) } })
        MinePrefRow({ title: '提醒设置', caption: this.dailyRemindOn ? '已打开' : '关闭', onTap: (): void => { void this.toggleRemind(!this.dailyRemindOn) } })
        MinePrefRow({ title: '我的分类', caption: '生活场景说明', onTap: (): void => { SlipNav.openCatalogList() } })
        MinePrefRow({ title: '机构通知', caption: '轻轻一声', onTap: (): void => { SlipNav.openMessages() } })
        MinePrefRow({
          title: '导出我的数据',
          caption: '复制本机备笺',
          onTap: (): void => { this.exportText = SlipStore.exportText(); this.showExport = true }
        })
        MinePrefRow({ title: '删除历史记录', caption: '只清除已完成', onTap: (): void => { this.showClearDone = true } })
        MinePrefRow({ title: '清空全部数据', caption: '删除后无法恢复', onTap: (): void => { this.showClear = true } })
        MinePrefRow({
          title: '设置与隐私',
          caption: '协议 · 撤回 · 注销',
          onTap: (): void => {
            this.showSettings = true
            AppStorage.setOrCreate('minePanelOpen', true)
            AppStorage.setOrCreate('tabBarHidden', true)
          }
        })
        Text(`关于${this.appName}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text('把生活琐事，轻轻记下来。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
