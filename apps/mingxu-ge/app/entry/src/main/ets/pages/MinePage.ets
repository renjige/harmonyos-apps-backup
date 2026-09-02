import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { XuLocalStore } from '../services/XuLocalStore'
import { XuAppStats } from '../models/XuModels'
import { XuMedia } from '../services/XuMedia'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '明序阁'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('xuLocalStoreReady') @Watch('onStoreReadyChange') storeReady: number = 0
  @StorageLink('xuDataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State stats: XuAppStats = new XuAppStats()
  @State remindOn: boolean = true
  @State themeMode: string = 'light'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  onStoreReadyChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await XuLocalStore.ensureReady()
    XuLocalStore.publishHomeStats()
    this.stats = await XuLocalStore.loadStats()
    this.remindOn = await XuLocalStore.remindEnabled()
    this.themeMode = await XuLocalStore.colorMode()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
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

  private handleClearCache(): void {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
    this.showToast('已清除本地缓存')
  }

  private async handleDeleteAccount(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认注销账号')
      return
    }
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

  private agendaStatText(): string {
    if (this.stats.agendaTotal <= 0) {
      return '0'
    }
    return `${this.stats.agendaDone}/${this.stats.agendaTotal}`
  }

  private habitStatText(): string {
    if (this.stats.habitCheckTotal > 0) {
      return `${this.stats.habitCheckTotal}`
    }
    if (this.stats.habitTodayCount > 0) {
      return `${this.stats.habitTodayCount}`
    }
    return '0'
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
                Image(XuMedia.emptyPaper())
                  .width(64)
                  .height(64)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.pill)
                Text(this.isLoggedIn() ? this.currentUsername : '游客')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.isLoggedIn()
                  ? `已使用 ${this.stats.usedDays} 天 · 登录后可同步到云端`
                  : `已使用 ${this.stats.usedDays} 天 · 本机记录，登录可同步`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Row({ space: Theme.space.s3 }) {
                this.StatBox('累计打卡', this.habitStatText(), this.stats.habitTodayCount > 0 ? '含今日打卡' : '打卡后累计')
                this.StatBox('完成事项', this.agendaStatText(), this.stats.agendaTotal > 0 ? '已完成/全部' : '勾选待办后累计')
                this.StatBox('笔记', `${this.stats.noteCount}`, '知识碎片条数')
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text('设置与隐私')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text('协议 · 撤回同意 · 注销')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
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
              .onClick(() => {
                this.confirmDelete = false
                this.showSettings = true
              })

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
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { this.handleClearCache() }
          })
          Row() {
            Text('首页智慧提醒')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.remindOn })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean) => {
                this.remindOn = v
                void XuLocalStore.setRemindEnabled(v)
              })
          }
          .width('100%')
          .padding(Theme.space.s3)
          Text('主题')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
            this.ThemeChip('跟随系统', 'system')
          }
          .width('100%')
          AppButton({
            label: this.confirmDelete ? '再点一次确认注销' : '注销账号',
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

  @Builder
  StatBox(label: string, value: string, hint: string = '') {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      if (hint.length > 0) {
        Text(hint)
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(1)
      }
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.themeMode = mode
        void XuLocalStore.setColorMode(mode)
      })
  }
}
