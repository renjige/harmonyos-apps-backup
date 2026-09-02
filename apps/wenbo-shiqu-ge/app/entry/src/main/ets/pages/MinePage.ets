import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { PavilionStore } from '../services/PavilionStore'
import { PavilionDetailNav } from '../services/PavilionDetailNav'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { PavilionStats } from '../models/PavilionModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '识趣阁'
  @Prop overlayMode: boolean = false
  @Prop settingsOnly: boolean = false
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('pavilionRefresh') @Watch('onStatsChange') pavilionRefresh: number = 0
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State stats: PavilionStats = new PavilionStats()
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onCloseOverlay: () => void = () => {}

  aboutToAppear(): void {
    if (this.settingsOnly) {
      this.showSettings = true
    }
    this.stats = PavilionStore.stats()
  }

  onStatsChange(): void {
    this.stats = PavilionStore.stats()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2800)
  }

  private closeSettings(): void {
    this.showSettings = false
    if (this.overlayMode) {
      this.onCloseOverlay()
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.closeSettings()
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private handleClearCache(): void {
    void PavilionStore.clearCache()
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
      this.closeSettings()
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async toggleDark(): Promise<void> {
    const next = !this.darkModeOn
    ThemeAppearance.apply(next ? 'dark' : 'light', ThemeAppearance.host)
    await PavilionStore.setDark(next)
    this.showToast(next ? '已切换深色模式' : '已切换浅色模式')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings || this.settingsOnly) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 8 }) {
                  Text(this.isLoggedIn() ? this.currentUsername : '游客')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                  .width('100%')
                Text(this.isLoggedIn()
                  ? '账号已登录 · 收藏与笔记保存在本机'
                  : '游客可浏览全部趣知；登录为可选')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                  .width('100%')
                Row({ space: 16 }) {
                  Column() {
                    Text(`${this.stats.favorites}`)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    Text('收藏')
                      .fontSize(12)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                  }
                  Column() {
                    Text(`${this.stats.reads}`)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    Text('阅读')
                      .fontSize(12)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                  }
                  Column() {
                    Text(`${this.stats.notes}`)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    Text('笔记')
                      .fontSize(12)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                  }
                  Column() {
                    Text(`${this.stats.days}`)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    Text('天数')
                      .fontSize(12)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                  }
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(Theme.radius.card)

              this.MenuRow('兴趣档案', '收藏 · 探索 · 任务 · 成长地图', (): void => { PavilionDetailNav.openProfile() })
              this.MenuRow('兴趣探索记录', '喜欢的事物 · 新知识 · 话题', (): void => { PavilionDetailNav.openLogs() })
              this.MenuRow('每日发现', '每天记下一条新发现', (): void => { PavilionDetailNav.openFinds() })
              this.MenuRow('趣味挑战', '生活技巧 · 冷知识 · 趣味故事', (): void => { PavilionDetailNav.openTasks() })
              this.MenuRow('兴趣清单', '想了解 / 想学 / 想尝试', (): void => { PavilionDetailNav.openWish() })
              this.MenuRow('趣味笔记', '想法见解 · 标签整理', (): void => { PavilionDetailNav.openNotes() })
              this.MenuRow('趣味问答', '自测并保存历史成绩', (): void => { PavilionDetailNav.openQuiz('today') })
              this.MenuRow('知识卡片', '自制卡片进个人知识库', (): void => { PavilionDetailNav.openCards() })
              this.MenuRow('专题合集', '奇妙自然与文化趣闻', (): void => { PavilionDetailNav.openCollections() })
              this.MenuRow('阅读记录', '看过的趣知', (): void => { PavilionDetailNav.openHistory() })
              this.MenuRow('机构通知', '来自识趣阁的广播', (): void => { PavilionDetailNav.openMessages() })
              this.MenuRow('设置与隐私', '协议 · 外观 · 撤回 · 注销', (): void => {
                this.confirmDelete = false
                this.showSettings = true
              })

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
      .backgroundColor(Theme.pageBg(this.themeEpoch, this.darkModeOn))

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
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(title: string, sub: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
    .borderRadius(Theme.radius.xl)
    .onClick(onTap)
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
        .onClick((): void => { this.closeSettings() })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
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
          AppButton({
            label: this.darkModeOn ? '切换浅色模式' : '切换深色模式',
            variant: 'secondary',
            onTap: (): void => { void this.toggleDark() }
          })
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { this.handleClearCache() }
          })
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch, this.darkModeOn))
  }
}
