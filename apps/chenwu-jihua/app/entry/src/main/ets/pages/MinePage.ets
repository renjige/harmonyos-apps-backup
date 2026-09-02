import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { CwStats } from '../models/ChenwuModels'
import { ChenwuStore } from '../services/ChenwuStore'
import { ChenwuDetailNav } from '../services/ChenwuDetailNav'
import { PrivacyService } from '../services/PrivacyService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppContextService } from '../services/AppContextService'
import { CwConfirmDialog } from '../components/chenwu/CwConfirmDialog'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('cwDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  onPrivacyRevoked: () => void = () => {}
  @Prop bottomInset: number = 76
  @State stats: CwStats = new CwStats()
  @State nickname: string = '晨雾人'
  @State showSettings: boolean = false
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  @State confirmRevoke: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await ChenwuStore.computeStats()
    const p = await ChenwuStore.loadProfile()
    this.nickname = p.nickname
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async saveNick(v: string): Promise<void> {
    this.nickname = v
    const p = await ChenwuStore.loadProfile()
    p.nickname = v
    await ChenwuStore.saveProfile(p)
  }

  private async exportJson(): Promise<void> {
    const json = await ChenwuStore.exportJson()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, json)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('成长档案 JSON 已复制到剪贴板')
    } catch {
      this.showToast('复制失败')
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    this.confirmRevoke = false
    this.showToast('已撤回隐私同意，再次进入须重新勾选协议')
    this.onPrivacyRevoked()
  }

  private setMode(mode: string): void {
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      ThemeAppearance.apply(mode, ctx)
    } else {
      ThemeAppearance.apply(mode)
    }
    void this.persistMode(mode)
  }

  private async persistMode(mode: string): Promise<void> {
    const p = await ChenwuStore.loadProfile()
    p.themeMode = mode
    await ChenwuStore.saveProfile(p)
  }

  build() {
    Stack() {
      if (this.showSettings) {
        this.SettingsPanel()
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: 12 }) {
              Column() {
                AppIcon({ name: 'user', iconSize: 28, color: Theme.colors().brandOnPrimary })
              }
              .width(56)
              .height(56)
              .borderRadius(28)
              .backgroundColor(Theme.colors().brandPrimary)
              .justifyContent(FlexAlign.Center)
              Column({ space: 4 }) {
                TextInput({ text: this.nickname, placeholder: '昵称' })
                  .onChange((v: string): void => { void this.saveNick(v) })
                  .fontSize(Theme.type.title3)
                  .backgroundColor(Color.Transparent)
                Text(`计划 ${this.stats.planCount} · 目标 ${this.stats.goalCount} · 习惯 ${this.stats.habitCount}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
            }
            .width('100%')

            this.menuRow('成就墙', 'sparkle', (): void => { ChenwuDetailNav.openAchievements() })
            this.menuRow('智慧整理', 'list', (): void => { ChenwuDetailNav.openOrganize() })
            this.menuRow('搜索', 'search', (): void => { ChenwuDetailNav.openSearch() })
            this.menuRow('设置与隐私', 'gear', (): void => { this.showSettings = true })

            Column().height(this.bottomInset)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        }
        .width('100%')
        .height('100%')
      }

      if (this.showPrivacy) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacy = false } })
      }
      if (this.showAgreement) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreement = false } })
      }
      if (this.confirmRevoke) {
        CwConfirmDialog({
          title: '撤回隐私同意？',
          message: '撤回后需重新勾选协议才能继续使用。',
          confirmLabel: '撤回',
          onConfirm: (): void => { void this.handleRevokePrivacy() },
          onCancel: (): void => { this.confirmRevoke = false }
        })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .margin({ top: 24 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  menuRow(label: string, icon: 'sparkle' | 'list' | 'search' | 'gear', action: () => void) {
    Row() {
      AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { action() })
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.showSettings = false })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontColor(Theme.colors().textPrimary)
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(Theme.space.s4)
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('外观')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 8 }) {
            Text('浅色').onClick((): void => { this.setMode('light') }).fontColor(Theme.colors().textPrimary)
            Text('深色').onClick((): void => { this.setMode('dark') }).fontColor(Theme.colors().textPrimary)
            Text('跟随系统').onClick((): void => { this.setMode('system') }).fontColor(Theme.colors().textPrimary)
          }
          AppButton({ label: '查看《用户协议》', variant: 'secondary', onTap: (): void => { this.showAgreement = true } })
          AppButton({ label: '查看《隐私政策》', variant: 'secondary', onTap: (): void => { this.showPrivacy = true } })
          AppButton({ label: '导出档案 JSON', variant: 'secondary', onTap: (): void => { void this.exportJson() } })
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => {
              ChenwuStore.bump()
              this.showToast('已清除本地缓存')
            }
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
          Text('晨雾计划 1.0.0 · 运营者薛茂新 · 数据仅本机')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Column().height(this.bottomInset)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
