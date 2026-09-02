import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { HazardLocalStore } from '../services/HazardLocalStore'
import { HazardBizService } from '../services/HazardBizService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '筑科隐患排查'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State showGuide: boolean = false
  @State showData: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State hazardCount: number = 0
  @State todayInspectCount: number = 0
  @State syncPaused: boolean = false
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onDataCleared: () => void = () => {}

  aboutToAppear(): void {
    this.refreshDataStats()
  }

  private refreshDataStats(): void {
    this.hazardCount = HazardLocalStore.all().length
    this.todayInspectCount = HazardLocalStore.todayInspect()
    this.syncPaused = HazardLocalStore.isRemoteSyncPaused()
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

  private async handleClearLocal(): Promise<void> {
    await HazardLocalStore.clearAll()
    this.refreshDataStats()
    this.onDataCleared()
    this.showToast('本机数据已清理，首页与列表已清空')
  }

  private async handleSyncRemote(): Promise<void> {
    await HazardBizService.syncFromRemote()
    this.refreshDataStats()
    this.onDataCleared()
    this.showToast('已从云端同步最新数据')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showGuide) {
          this.GuidePanel()
        } else if (this.showData) {
          this.DataPanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 8 }) {
                Text(this.isLoggedIn() ? this.currentUsername : '游客')
                  .fontSize(Theme.type.title3).fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary).width('100%')
                Text(this.isLoggedIn()
                  ? '账号已登录 · 隐患与检查记录可同步到云端'
                  : '游客可直接记录隐患；登录后可同步到云端')
                  .fontSize(Theme.type.footnote).fontColor(Theme.colors().textSecondary).width('100%')
                Text('版本 1.0.0')
                  .fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
              }
              .width('100%').padding(Theme.space.s5).alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.card)

              this.MenuRow('使用说明', '发现、记录、整改、复查四步闭环', (): void => { this.showGuide = true })
              this.MenuRow('数据管理', '查看本机记录、清理缓存', (): void => {
                this.refreshDataStats()
                this.showData = true
              })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', (): void => { this.showSettings = true })

              if (this.isLoggedIn()) {
                AppButton({
                  label: '退出登录', variant: 'secondary',
                  onTap: (): void => { void AuthService.logout(); this.onLogout() }
                })
              } else {
                AppButton({ label: '登录 / 注册', onTap: (): void => { this.onOpenLogin() } })
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            .width('100%')
          }
          .layoutWeight(1).scrollBar(BarState.Off)
        }
      }
      .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote).fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary).borderRadius(Theme.radius.pill)
            .maxLines(3).textAlign(TextAlign.Center)
        }
        .width('100%').padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center).zIndex(20)
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        }).width('100%').height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(title: string, hint: string, tap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(title).fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(hint).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%').padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.xl)
    .onClick(() => tap())
  }

  @Builder
  GuidePanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('使用说明', (): void => { this.showGuide = false })
      Scroll() {
        Column({ space: 12 }) {
          Text('1. 发现隐患后点「新增隐患」，填写名称、位置、类别和风险等级。')
            .fontSize(15).fontColor(Theme.colors().textPrimary).width('100%')
          Text('2. 保存后进入详情，可跟踪状态时间线。')
            .fontSize(15).fontColor(Theme.colors().textPrimary).width('100%')
          Text('3. 整改完成后点「记录整改」，状态变为待复查。')
            .fontSize(15).fontColor(Theme.colors().textPrimary).width('100%')
          Text('4. 复查通过即闭环；未通过将退回待整改。')
            .fontSize(15).fontColor(Theme.colors().textPrimary).width('100%')
          Text('5. 「检查」按清单勾选正常/异常，异常项会生成隐患记录。')
            .fontSize(15).fontColor(Theme.colors().textPrimary).width('100%')
          Text('本工具用于现场记录与跟踪，不替代法定安全检查或应急处置。')
            .fontSize(13).fontColor(Theme.colors().textSecondary).width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
  }

  @Builder
  DataPanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('数据管理', (): void => { this.showData = false })
      Scroll() {
        Column({ space: 12 }) {
          Text(`本机已保存隐患 ${this.hazardCount} 条。今日检查 ${this.todayInspectCount} 次。`)
            .fontSize(15).fontColor(Theme.colors().textPrimary).width('100%')
          if (this.syncPaused) {
            Text('当前已暂停云端自动同步，界面仅展示本机空数据。登录用户可点下方「从云端同步」恢复。')
              .fontSize(13).fontColor(Theme.colors().brandAccent).width('100%')
          }
          Text('「清理本地数据」会清空本机隐患与检查计数，并暂停自动从服务器拉回，便于审核验证空态。')
            .fontSize(13).fontColor(Theme.colors().textSecondary).width('100%')
          Text('导出提示：可在隐患列表逐条查看记录。本版本不向相册或文件管理器写入导出文件，以减少敏感权限。')
            .fontSize(13).fontColor(Theme.colors().textSecondary).width('100%')
          Text('数据备份提示：登录后记录会同步到业务平台；游客数据仅保存在本机，卸载应用后可能丢失。')
            .fontSize(13).fontColor(Theme.colors().textSecondary).width('100%')
          Column({ space: 10 }) {
            Row() {
              Text('清理本地数据')
                .fontSize(15)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: 14, bottom: 14 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { void this.handleClearLocal() })
            if (this.isLoggedIn()) {
              Row() {
                Text('从云端同步')
                  .fontSize(15)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding({ top: 14, bottom: 14 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { void this.handleSyncRemote() })
            }
          }
          .width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
  }

  @Builder
  BackRow(title: string, tap: () => void) {
    Row({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
      }
      .width(44).height(44).justifyContent(FlexAlign.Center).rotate({ angle: 180 })
      .onClick(() => tap())
      Text(title).fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('设置与隐私', (): void => { this.showSettings = false })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '查看《用户协议》', variant: 'secondary',
            onTap: (): void => { this.legalKind = 'agreement'; this.showLegal = true }
          })
          AppButton({
            label: '查看《隐私政策》', variant: 'secondary',
            onTap: (): void => { this.legalKind = 'privacy'; this.showLegal = true }
          })
          Text('个人信息收集清单与第三方共享清单见应用内协议及上架资料。')
            .fontSize(Theme.type.footnote).fontColor(Theme.colors().textSecondary).width('100%')
          AppButton({
            label: '注销账号', variant: 'danger',
            onTap: (): void => { void this.handleDeleteAccount() }
          })
          Row() {
            AppButton({
              label: '撤回隐私同意', variant: 'secondary',
              onTap: (): void => { void this.handleRevokePrivacy() }
            })
          }
          .width('100%')
          .onClick((): void => { void this.handleRevokePrivacy() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
  }
}
