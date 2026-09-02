import { Theme, ColorMode } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { ReadingBizService } from '../services/ReadingBizService'
import { SessionStore } from '../services/SessionStore'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '明阅坊'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('colorModePref') colorModePref: string = 'system'
  @StorageLink('displayNickname') displayNickname: string = ''
  @State showSettings: boolean = false
  @State showAbout: boolean = false
  @State showNicknameEdit: boolean = false
  @State nicknameInput: string = ''
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State bookCount: number = 0
  @State noteCount: number = 0
  @State readMinutes: number = 0
  @State darkModeOn: boolean = false
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  onOpenQuotes: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onOpenReport: () => void = () => {}
  onOpenMessages: () => void = () => {}

  aboutToAppear(): void {
    this.darkModeOn = this.colorModePref === 'dark'
    ThemeAppearance.apply(this.colorModePref as ColorMode, this.getUIContext().getHostContext() as common.UIAbilityContext)
    void this.loadStats()
  }

  private async loadStats(): Promise<void> {
    if (AuthService.isLoggedIn()) {
      const books = await ReadingBizService.loadBooks(this.currentUsername)
      this.bookCount = books.length
      const notes = await ReadingBizService.loadNotes(this.currentUsername, '', '')
      this.noteCount = notes.length
      const report = await ReadingBizService.loadReadingReport(this.currentUsername, new Date().getFullYear())
      this.readMinutes = report.totalReadingMinutes
    } else {
      this.bookCount = 0
      this.noteCount = 0
      this.readMinutes = 0
    }
  }

  private toggleDarkMode(on: boolean): void {
    this.darkModeOn = on
    const mode: ColorMode = on ? 'dark' : 'light'
    this.colorModePref = mode
    ThemeAppearance.apply(mode, this.getUIContext().getHostContext() as common.UIAbilityContext)
  }

  private displayName(): string {
    if (this.displayNickname.length > 0) {
      return this.displayNickname
    }
    if (this.isLoggedIn()) {
      return this.currentUsername
    }
    return '阅友'
  }

  private openNicknameEdit(): void {
    this.nicknameInput = this.displayNickname.length > 0 ? this.displayNickname : ''
    this.showNicknameEdit = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeNicknameEdit(): void {
    this.showNicknameEdit = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async saveNickname(): Promise<void> {
    await SessionStore.saveDisplayNickname(this.nicknameInput)
    this.closeNicknameEdit()
    this.showToast('昵称已保存')
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

  private async handleClearCache(): Promise<void> {
    await SessionStore.clearLocalCache()
    this.showSettings = false
    this.showToast('已清除本地缓存')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的', subtitle: '阅读统计与设置' })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Row({ space: 12 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Column()
                    .width(56)
                    .height(56)
                    .linearGradient({
                      angle: 135,
                      colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
                    })
                    .borderRadius(18)
                  AppIcon({
                    name: this.isLoggedIn() ? 'user' : 'empty',
                    iconSize: Theme.icon.lg,
                    color: Theme.colors().brandAccent
                  })
                }
                Column({ space: 8 }) {
                  Text(this.displayName())
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text('点击编辑昵称 · 明心见性，阅享智慧')
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(VerticalAlign.Center)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { this.openNicknameEdit() })

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '收藏',
                  value: `${this.bookCount}`,
                  trend: '本',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '笔记',
                  value: `${this.noteCount}`,
                  trend: '篇',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '时长',
                  value: `${this.readMinutes}`,
                  trend: '分钟',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
                Text('深色模式')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Toggle({ type: ToggleType.Switch, isOn: this.darkModeOn })
                  .selectedColor(Theme.colors().brandAccent)
                  .onChange((on: boolean) => { this.toggleDarkMode(on) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              this.MenuRow('智慧书架', '查看全部书籍', 'book', (): void => { this.onSwitchTab(0) })
              this.MenuRow('明悟收藏', '阅读中的精彩片段', 'bookmark', (): void => { this.onOpenQuotes() })
              this.MenuRow('消息中心', '机构通知与阅读提醒', 'bell', (): void => { this.onOpenMessages() })
              this.MenuRow('阅读报告', '年度统计与常用标签', 'chart', (): void => { this.onOpenReport() })
              this.MenuRow('关于明阅坊', '品牌理念与版本信息', 'sparkle', (): void => { this.showAbout = true })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', 'gear', (): void => { this.showSettings = true })

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
          onClose: (): void => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showAbout) {
        this.AboutPanel()
      }

      if (this.showNicknameEdit) {
        this.NicknamePanel()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(title: string, subtitle: string, iconName: AppIconName, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: iconName, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(10)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { onTap() })
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
        .onClick((): void => { this.showSettings = false })
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
          Text(`应用名称：${this.appName}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text('版本：1.0.0 · 明心见性，阅享智慧')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text('运营者：魏文波')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text('个人信息收集清单与第三方共享清单可在协议全文中查阅。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { void this.handleClearCache() }
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

  @Builder
  AboutPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.showAbout = false })
        Text('关于明阅坊')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Image($r('app.media.app_icon'))
            .width(88)
            .height(88)
            .borderRadius(20)
            .objectFit(ImageFit.Cover)
          Text(this.appName)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('智慧阅读 · 知识管理 · 心灵栖息')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .textAlign(TextAlign.Center)
          Text('明心见性，阅享智慧。明阅坊为都市知识工作者提供专注、优雅的数字阅读与知识整理空间，帮助你在碎片化时代回归深度思考。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(24)
          Text('版本 1.0.0 · 运营者：魏文波')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(18)
  }

  @Builder
  NicknamePanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeNicknameEdit() })
        Text('编辑昵称')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.nicknameInput, placeholder: '输入昵称（本地保存）' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.nicknameInput = v })
        AppButton({
          label: '保存',
          onTap: (): void => { void this.saveNickname() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(18)
  }
}
