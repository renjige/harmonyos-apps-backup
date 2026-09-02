import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppConfirmDialog } from '../components/design-system/AppConfirmDialog'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { YdMetricTile } from '../components/yuedong/YdMetricTile'
import { YdReviewStats, YdUserProfile } from '../models/YdModels'
import { PrivacyService } from '../services/PrivacyService'
import { YdLocalStore } from '../services/YdLocalStore'
import { YdDetailNav } from '../services/YdDetailNav'
import { YdClipboard } from '../services/YdClipboard'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('ydDataRefresh') @Watch('onGlobalRefresh') globalRefresh: number = 0
  @Prop appName: string = '跃动新章'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State profile: YdUserProfile = new YdUserProfile()
  @State stats: YdReviewStats = new YdReviewStats()
  @State leapText: string = '0'
  @State chapterText: string = '0'
  @State rateText: string = '0%'
  @State goalCount: number = 0
  @State darkMode: boolean = false
  @State showSettings: boolean = false
  @State toastText: string = ''
  @State confirmClear: boolean = false
  @State editNickname: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  onGlobalRefresh(): void {
    void this.reload()
  }

  private openLegal(kind: string): void {
    YdDetailNav.openLegal(kind)
  }

  private syncStatTexts(): void {
    this.leapText = `${this.stats.leapIndex}`
    this.chapterText = `${this.stats.chapterClosed}`
    this.rateText = `${this.stats.completionRate}%`
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async reload(): Promise<void> {
    this.profile = await YdLocalStore.loadProfile()
    this.editNickname = this.profile.nickname
    this.stats = await YdLocalStore.computeReviewStats()
    this.syncStatTexts()
    const goals = await YdLocalStore.loadAllGoals()
    this.goalCount = goals.length
    this.darkMode = await YdLocalStore.isDarkMode()
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    this.showToast('已撤回隐私同意，再次进入须重新同意')
  }

  private async handleClearData(): Promise<void> {
    await YdLocalStore.clearAllData()
    this.confirmClear = false
    this.showSettings = false
    this.showToast('已清除本地日程与目标数据')
    void this.reload()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s4 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: 32, color: Theme.colors().brandPrimary })
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(32)
            Column({ space: 4 }) {
              Text(this.profile.nickname)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('本机篇章 · 无需账号')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s3 }) {
            YdMetricTile({ value: this.leapText, label: '跃动指数' })
            YdMetricTile({ value: this.chapterText, label: '已收官章' })
            YdMetricTile({ value: this.rateText, label: '完成率' })
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            Text('深色模式')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean): void => {
                this.darkMode = v
                ThemeAppearance.apply(v ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
                void YdLocalStore.setDarkMode(v)
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          this.MenuRow('我的收藏', 'message', (): void => { YdDetailNav.openFavorites() })
          this.MenuRow('标签管理', 'biz', (): void => { YdDetailNav.openTagsManage() })
          this.MenuRow('导出本周摘要', 'chart', (): void => {
            void YdLocalStore.buildWeeklyReportText().then(async (text: string): Promise<void> => {
              const ok = await YdClipboard.copyText(text)
              this.showToast(ok ? '本周摘要已复制' : '复制失败')
            })
          })
          this.MenuRow('导出全部篇章', 'biz', (): void => {
            void YdLocalStore.exportAllChaptersText().then(async (text: string): Promise<void> => {
              const ok = await YdClipboard.copyText(text)
              this.showToast(ok ? '篇章档案已复制' : '复制失败')
            })
          })
          this.MenuRow('使用指南', 'biz', (): void => { YdDetailNav.openHelp() })
          this.MenuRow('设置与隐私', 'user', (): void => { this.showSettings = true })
          this.MenuRow('关于跃动新章', 'biz', (): void => {
            this.showToast('跃动新章 v1.0.5 — 人生篇章 · 计划执行复盘')
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSettings) {
        this.SettingsPanel()
      }

      if (this.confirmClear) {
        AppConfirmDialog({
          title: '清除本地数据',
          message: '将删除全部篇章、任务与目标记录，此操作不可恢复。',
          confirmLabel: '确认清除',
          cancelLabel: '取消',
          danger: true,
          onConfirm: (): void => { void this.handleClearData() },
          onCancel: (): void => { this.confirmClear = false }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(label: string, icon: AppIconName, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontColor(Theme.colors().textPrimary)
          .fontWeight(FontWeight.Medium)
          .onClick(() => { this.showSettings = false })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ top: Theme.space.s6, bottom: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.editNickname, placeholder: '昵称' })
            .onChange((v: string) => { this.editNickname = v })
          AppButton({
            label: '保存昵称',
            variant: 'secondary',
            onTap: (): void => {
              this.profile.nickname = this.editNickname.trim().length > 0 ? this.editNickname.trim() : '跃动用户'
              void YdLocalStore.saveProfile(this.profile).then(() => this.showToast('昵称已保存'))
            }
          })
          Row() {
            AppButton({
              label: '查看《隐私政策》',
              variant: 'secondary',
              onTap: (): void => { this.openLegal('privacy') }
            })
          }
          .width('100%')
          .onClick((): void => { this.openLegal('privacy') })
          Row() {
            AppButton({
              label: '查看《用户协议》',
              variant: 'secondary',
              onTap: (): void => { this.openLegal('agreement') }
            })
          }
          .width('100%')
          .onClick((): void => { this.openLegal('agreement') })
          AppButton({ label: '清除本地数据', variant: 'secondary', onTap: (): void => { this.confirmClear = true } })
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
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(20)
  }
}
