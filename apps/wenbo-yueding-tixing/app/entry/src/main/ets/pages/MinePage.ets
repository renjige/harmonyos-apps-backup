import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { AppointmentLocalStore } from '../services/AppointmentLocalStore'
import { AppointmentService } from '../services/AppointmentService'
import { WeekDigest } from '../models/AppointmentModels'
import { ToolEntry } from '../components/appointment/WorkbenchCards'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '约定提醒'
  @Prop @Watch('onTick') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('notifyEnabled') notifyEnabled: boolean = true
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State digest: WeekDigest = new WeekDigest()
  @State confirmClear: boolean = false
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenRhythm: () => void = () => {}
  onOpenReview: () => void = () => {}
  onOpenInsights: () => void = () => {}
  onOpenBrief: () => void = () => {}
  onOpenSlots: () => void = () => {}
  onOpenOverdue: () => void = () => {}
  onOpenImport: () => void = () => {}
  onExportWeek: () => void = () => {}
  onOpenMessages: () => void = () => {}

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  aboutToAppear(): void {
    void this.loadDigest()
  }

  onTick(): void {
    void this.loadDigest()
  }

  private async loadDigest(): Promise<void> {
    this.digest = await AppointmentService.weekDigest()
  }

  private async handleClearCache(): Promise<void> {
    await AppointmentLocalStore.clearCache()
    this.confirmClear = false
    this.showToast('已清除本地临时缓存，约定记录未删除')
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
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

  private async handleNotifyToggle(enabled: boolean): Promise<void> {
    await AppointmentLocalStore.setNotifyEnabled(enabled)
    this.showToast(enabled ? '已开启本地提醒' : '已关闭本地提醒')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 8 }) {
                Text(this.isLoggedIn() ? this.currentUsername : '游客')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                  Text(this.isLoggedIn()
                  ? '账号已登录 · 业务数据将同步到云端'
                  : '游客可浏览模板并在本机记录约定')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Column({ space: 6 }) {
                Text(`本周完成 ${this.digest.doneCount}/${this.digest.totalCount} · 守约 ${this.digest.rateText}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.digest.suggestion)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)

              ToolEntry({
                title: '今日简报',
                subtitle: '复制今日出发时间与待办清单',
                onTap: (): void => { this.onOpenBrief() }
              })
              ToolEntry({
                title: '找空档',
                subtitle: '扫描未来 7 天可安排时段',
                onTap: (): void => { this.onOpenSlots() }
              })
              ToolEntry({
                title: '逾期台',
                subtitle: '过期约定改到明天或标记完成',
                onTap: (): void => { this.onOpenOverdue() }
              })
              ToolEntry({
                title: '粘贴导入',
                subtitle: '多行文本一次生成多件约定',
                onTap: (): void => { this.onOpenImport() }
              })
              ToolEntry({
                title: '守约洞察',
                subtitle: '30 天守约率、连续完成与场景分布',
                onTap: (): void => { this.onOpenInsights() }
              })
              ToolEntry({
                title: '智能整理',
                subtitle: '问卷生成节奏建议，一键创建约定',
                onTap: (): void => { this.onOpenRhythm() }
              })
              ToolEntry({
                title: '本周复盘',
                subtitle: '最忙一天、分类占比与过期处理',
                onTap: (): void => { this.onOpenReview() }
              })
              ToolEntry({
                title: '机构通知',
                subtitle: '查看系统提醒与守约提示',
                onTap: (): void => { this.onOpenMessages() }
              })
              ToolEntry({
                title: '复制本周安排',
                subtitle: '导出到剪贴板，方便贴到笔记或消息',
                onTap: (): void => { this.onExportWeek() }
              })

              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text('设置与隐私')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text('协议 · 撤回同意 · 注销')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick(() => { this.showSettings = true })

              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text('本地提醒')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text(this.notifyEnabled ? '已开启系统提醒' : '已关闭系统提醒')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Toggle({ type: ToggleType.Switch, isOn: this.notifyEnabled })
                  .onChange((v: boolean): void => { void this.handleNotifyToggle(v) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Column({ space: Theme.space.s3 }) {
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
              }
              .width('100%')
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
          .edgeEffect(EdgeEffect.Spring)
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
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => { this.showSettings = false })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'agreement'
              this.showLegal = true
            }
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            }
          })
          Text('个人信息收集清单 · 第三方共享清单见 store/ 上架资料')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          AppButton({
            label: this.confirmClear ? '确认清除缓存' : '清除缓存',
            variant: 'secondary',
            onTap: (): void => {
              if (this.confirmClear) {
                void this.handleClearCache()
              } else {
                this.confirmClear = true
              }
            }
          })
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
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }
}
