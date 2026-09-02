import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AuthService } from '../services/AuthService'
import { NoteStore } from '../services/NoteStore'
import { PrivacyService } from '../services/PrivacyService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '森野小记'
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State showSettings: boolean = false
  @State showTagPanel: boolean = false
  @State newTag: string = ''
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State noteCount: number = 0
  @State streak: number = 0
  @State tagCount: number = 0
  @State customTags: string[] = []
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    this.refreshStats()
  }

  onRefresh(): void {
    this.refreshStats()
  }

  private refreshStats(): void {
    this.noteCount = NoteStore.all().length
    this.streak = NoteStore.streakDays()
    this.tagCount = NoteStore.usedTagNames().length
    this.customTags = NoteStore.customTags()
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
    AppStorage.setOrCreate('privacyConsentPending', true)
    this.showToast('已撤回隐私同意，再次进入须重新同意')
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
    await NoteStore.setDark(on)
  }

  private async exportData(): Promise<void> {
    const text = NoteStore.exportText()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('导出内容已复制到剪贴板')
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  private async addTag(): Promise<void> {
    await NoteStore.addCustomTag(this.newTag)
    this.newTag = ''
    this.refreshStats()
    this.showToast('标签已添加')
  }

  private async removeTag(tag: string): Promise<void> {
    await NoteStore.removeCustomTag(tag)
    this.refreshStats()
    this.showToast('标签已删除')
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => {
          this.showSettings = false
          AppStorage.setOrCreate('tabBarHidden', false)
        })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')

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

      Row() {
        AppButton({
          label: '撤回隐私同意',
          variant: 'secondary',
          onTap: (): void => { void this.handleRevokePrivacy() }
        })
      }
      .width('100%')
      .onClick((): void => { void this.handleRevokePrivacy() })

      AppButton({
        label: '注销账号',
        variant: 'secondary',
        onTap: (): void => { void this.handleDeleteAccount() }
      })
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showTagPanel) {
          Column({ space: Theme.space.s4 }) {
            Row({ space: Theme.space.s2 }) {
              Column() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .rotate({ angle: 180 })
              .onClick((): void => {
                this.showTagPanel = false
                AppStorage.setOrCreate('tabBarHidden', false)
              })
              Text('标签管理')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
            }
            .width('100%')

            Row({ space: Theme.space.s2 }) {
              TextInput({ text: this.newTag, placeholder: '新标签名称' })
                .layoutWeight(1)
                .height(44)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onChange((v: string) => { this.newTag = v })
              AppButton({ label: '添加', onTap: (): void => { void this.addTag() } })
            }
            .width('100%')

            ForEach(this.customTags, (tag: string) => {
              Row() {
                Text(tag)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('删除')
                  .fontColor(Theme.colors().danger)
                  .fontSize(Theme.type.caption)
                  .onClick((): void => { void this.removeTag(tag) })
              }
              .width('100%')
              .padding({ top: 10, bottom: 10 })
            }, (tag: string) => tag)
          }
          .width('100%')
          .height('100%')
          .padding(Theme.space.pageX)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text('个人中心')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')

              Row({ space: Theme.space.s4 }) {
                Column({ space: 4 }) {
                  Text(`${this.noteCount}`)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().brandPrimary)
                  Text('记录总数')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)

                Column({ space: 4 }) {
                  Text(`${this.streak}`)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().brandAccent)
                  Text('连续记录天')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
              }
              .width('100%')

              Row() {
                Text('深色模式')
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Toggle({ type: ToggleType.Switch, isOn: this.darkModeOn })
                  .selectedColor(Theme.colors().brandPrimary)
                  .onChange((on: boolean): void => { void this.toggleDark(on) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)

              this.MenuRow('标签管理', `${this.tagCount} 个`, (): void => {
                this.showTagPanel = true
                AppStorage.setOrCreate('tabBarHidden', true)
              })
              this.MenuRow('数据导出', '纯文本', (): void => { void this.exportData() })
              this.MenuRow('设置与隐私', '协议 · 撤回 · 注销', (): void => {
                this.showSettings = true
                AppStorage.setOrCreate('tabBarHidden', true)
              })

              if (!this.isLoggedIn()) {
                AppButton({ label: '登录 / 注册（可选）', onTap: (): void => { this.onOpenLogin() } })
              } else {
                Text(`已登录：${this.currentUsername}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                AppButton({
                  label: '退出登录',
                  variant: 'secondary',
                  onTap: (): void => {
                    void AuthService.logout()
                    this.onLogout()
                    this.showToast('已退出登录')
                  }
                })
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.pageY,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
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
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(title: string, subtitle: string, onTap: () => void) {
    Row() {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(onTap)
  }
}
