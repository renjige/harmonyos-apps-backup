import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AuthService } from '../services/AuthService'
import { ExportService } from '../services/ExportService'
import { MemoryOverview } from '../models/MemoryModels'
import { MemoryStatsService } from '../services/MemoryStatsService'
import { MemoryStore } from '../services/MemoryStore'
import { PrivacyService } from '../services/PrivacyService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '慧忆册'
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State ov: MemoryOverview = new MemoryOverview()
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State darkMode: boolean = false
  @State showAbout: boolean = false
  private uiContext: common.UIAbilityContext | null = null
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async load(): Promise<void> {
    this.ov = await MemoryStatsService.overview()
    this.darkMode = Theme.isDark()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2800)
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

  private async toggleDark(on: boolean): Promise<void> {
    this.darkMode = on
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    await MemoryStore.saveDark(on)
  }

  private async exportFav(): Promise<void> {
    if (this.uiContext === null) {
      this.showToast('导出环境未就绪')
      return
    }
    try {
      const path = await ExportService.exportFavorites(this.uiContext)
      this.showToast(`已导出：${path}`)
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  private async exportData(): Promise<void> {
    if (this.uiContext === null) {
      this.showToast('导出环境未就绪')
      return
    }
    try {
      const path = await ExportService.exportToFile(this.uiContext)
      this.showToast(`已导出：${path}`)
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          this.MainBody()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
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
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
  }

  @Builder
  MainBody() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.mine_study'))
            .width('100%')
            .height(148)
            .objectFit(ImageFit.Cover)
          Column() {
            Blank()
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppIcon({ name: 'user', iconSize: 28, color: '#FFFFFF' })
              }
              .width(52)
              .height(52)
              .justifyContent(FlexAlign.Center)
              .borderRadius(Theme.radius.pill)
              .backgroundColor('rgba(26,109,245,0.85)')
              Column({ space: 4 }) {
                Text(this.isLoggedIn() ? this.currentUsername : '我的')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                Text(this.isLoggedIn() ? '账号已登录' : '游客 · 记忆保存在本机')
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(11,42,92,0.82)', 1]]
            })
          }
          .width('100%')
          .height(148)
        }
        .width('100%')
        .height(148)
        .borderRadius(Theme.radius.md)
        .clip(true)

        Row({ space: Theme.space.s3 }) {
          this.StatTile(`${this.ov.total}`, '总记录')
          this.StatTile(`${this.ov.monthNew}`, '本月新增')
          this.StatTile(`${this.ov.streakDays}`, '连续天数')
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          this.StatTile(`${this.ov.favoriteCount}`, '收藏')
          this.StatTile(`${this.ov.bookletCount}`, '记忆册')
          this.StatTile(`${this.ov.dueCount}`, '待温习')
        }
        .width('100%')

        if (this.ov.top2.length > 0 || this.ov.top3.length > 0) {
          Text(`TOP3  ${this.ov.top1}  ${this.ov.top2}  ${this.ov.top3}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }

        this.MenuRow('导出全部记录', '导出为纯文本 .txt', 'biz', (): void => { void this.exportData() })
        this.MenuRow('导出收藏', '只导出已收藏的记忆', 'heart', (): void => { void this.exportFav() })
        this.MenuRow('深色模式', this.darkMode ? '当前：深色' : '当前：浅色', 'sparkle', (): void => {
          void this.toggleDark(!this.darkMode)
        })
        this.MenuRow('关于我们', '慧忆册 · 智慧记忆管家', 'book', (): void => { this.showAbout = !this.showAbout })
        if (this.showAbout) {
          Text('慧忆册帮助你记录、收册、按日回顾与温习。支持收藏、置顶、归档、模板速记与标签归类。数据默认保存在本机，无广告、无内购。运营者：薛茂新。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        this.MenuRow('设置与隐私', '协议 · 撤回 · 注销', 'gear', (): void => {
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
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  StatTile(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
        .maxLines(2)
        .textAlign(TextAlign.Center)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  MenuRow(title: string, sub: string, icon: AppIconName, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.sm)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .constraintSize({ minHeight: 52 })
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
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
        .width('100%')
        .padding({ bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
  }
}
