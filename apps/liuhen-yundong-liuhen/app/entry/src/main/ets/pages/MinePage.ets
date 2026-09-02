import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AchievementDef, MonthStats, UserSettings } from '../models/WorkoutModels'
import { WorkoutStore } from '../services/WorkoutStore'
import { PrivacyService } from '../services/PrivacyService'
import { StatsService, AchievementService } from '../services/StatsService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 88
  onPrivacyRevoked: () => void = () => {}
  onDataCleared: () => void = () => {}
  @State settings: UserSettings = new UserSettings()
  @State total: MonthStats = new MonthStats()
  @State unlocked: string[] = []
  @State showSettings: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false
  @State goalInput: string = '3'
  @State monthInput: string = '20'
  @State toastText: string = ''
  @State themeMode: string = 'system'

  aboutToAppear(): void {
    void this.reload()
  }

  onPageShow(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.settings = await WorkoutStore.loadSettings()
    this.total = await StatsService.totalStats()
    this.unlocked = await WorkoutStore.loadUnlockedAchievements()
    this.goalInput = `${this.settings.weeklyGoal}`
    this.monthInput = `${this.settings.monthTarget}`
    this.themeMode = this.settings.themeMode.length > 0 ? this.settings.themeMode : 'system'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private isUnlocked(id: string): boolean {
    for (const u of this.unlocked) {
      if (u === id) {
        return true
      }
    }
    return false
  }

  private async saveGoal(): Promise<void> {
    const g = parseInt(this.goalInput, 10)
    if (g < 1 || g > 14) {
      this.showToast('每周目标请设 1～14 次')
      return
    }
    this.settings.weeklyGoal = g
    await WorkoutStore.saveSettings(this.settings)
    this.showToast('每周目标已保存')
  }

  private async saveMonthTarget(): Promise<void> {
    const t = parseInt(this.monthInput, 10)
    if (t < 1 || t > 60) {
      this.showToast('每月目标请设 1～60 次')
      return
    }
    this.settings.monthTarget = t
    await WorkoutStore.saveSettings(this.settings)
    this.showToast('本月目标已保存')
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.settings.themeMode = mode
    ThemeAppearance.apply(mode as 'light' | 'dark' | 'system',
      this.getUIContext().getHostContext() as common.UIAbilityContext)
    AppStorage.setOrCreate('colorMode', mode)
    await WorkoutStore.saveSettings(this.settings)
    this.showToast('主题已切换')
  }

  private async exportCopy(): Promise<void> {
    const text = await WorkoutStore.exportText()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('运动记录已复制到剪贴板')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async clearAll(): Promise<void> {
    await WorkoutStore.clearAllData()
    this.confirmClear = false
    this.showSettings = false
    this.onDataCleared()
    await this.reload()
    this.showToast('全部运动记录已清除')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showSettings = false
    this.showToast('已撤回本机隐私同意记录。首次安装声明由华为应用市场托管，本应用不再弹出隐私弹窗。')
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.persistTheme(mode) })
  }

  @Builder
  BadgeItem(def: AchievementDef) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({
          name: this.isUnlocked(def.id) ? 'check' : 'empty',
          iconSize: Theme.icon.md,
          color: this.isUnlocked(def.id) ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.isUnlocked(def.id) ?
        Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.lg)
      Text(def.title)
        .fontSize(11)
        .fontColor(this.isUnlocked(def.id) ?
          Theme.colors().textPrimary : Theme.colors().textSecondary)
        .maxLines(1)
    }
    .width('23%')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s4 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            Column({ space: 4 }) {
              Text(this.settings.nickname)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`累计 ${this.total.count} 次 · ${this.total.totalMinutes} 分钟`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Text('成就徽章')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(AchievementService.defs(), (def: AchievementDef) => {
              this.BadgeItem(def)
            }, (def: AchievementDef) => def.id)
          }
          .width('100%')

          AppListRow({
            title: '设置与隐私',
            subtitle: '运动目标 · 主题 · 协议 · 清除数据',
            onTap: (): void => { this.showSettings = true }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: this.bottomInset
        })
      }

      if (this.showSettings) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)
          .onClick((): void => { this.showSettings = false })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('设置与隐私')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)

            Text('每周运动目标（次）')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            TextInput({ text: this.goalInput, placeholder: '3' })
              .onChange((v: string): void => { this.goalInput = v })
            AppButton({ label: '保存每周目标', variant: 'secondary', onTap: (): void => { void this.saveGoal() } })

            Text('本月运动目标（次）')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            TextInput({ text: this.monthInput, placeholder: '20' })
              .onChange((v: string): void => { this.monthInput = v })
            AppButton({ label: '保存本月目标', variant: 'secondary', onTap: (): void => { void this.saveMonthTarget() } })

            Text('外观主题')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            Row({ space: Theme.space.s2 }) {
              this.ThemeChip('跟随系统', 'system')
              this.ThemeChip('浅色', 'light')
              this.ThemeChip('深色', 'dark')
            }

            AppButton({ label: '导出记录到剪贴板', variant: 'secondary', onTap: (): void => { void this.exportCopy() } })
            AppButton({ label: '清除全部运动数据', variant: 'secondary', onTap: (): void => { this.confirmClear = true } })

            AppListRow({ title: '用户协议', onTap: (): void => { this.showAgreementDoc = true } })
            AppListRow({ title: '隐私政策', onTap: (): void => { this.showPrivacyDoc = true } })

            Row() {
              AppButton({ label: '撤回隐私同意', variant: 'secondary', onTap: (): void => { this.confirmRevoke = true } })
            }
            .width('100%')
            .onClick((): void => { this.confirmRevoke = true })

            AppButton({ label: '关闭', variant: 'primary', onTap: (): void => { this.showSettings = false } })
          }
          .padding(Theme.space.s6)
        }
        .width('92%')
        .height('78%')
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }

      if (this.confirmClear) {
        Column().width('100%').height('100%').backgroundColor(Theme.colors().overlayScrim)
        Column({ space: Theme.space.s4 }) {
          Text('确定清除全部运动记录？此操作不可恢复。')
            .fontColor(Theme.colors().textPrimary)
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmClear = false } })
              .layoutWeight(1)
            AppButton({ label: '清除', variant: 'primary', onTap: (): void => { void this.clearAll() } })
              .layoutWeight(1)
          }
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }

      if (this.confirmRevoke) {
        Column().width('100%').height('100%').backgroundColor(Theme.colors().overlayScrim)
        Column({ space: Theme.space.s4 }) {
          Text('撤回后仅清除本机同意记录，不会再弹出应用内隐私窗。您仍可在本页查看协议全文。')
            .fontColor(Theme.colors().textPrimary)
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmRevoke = false } })
              .layoutWeight(1)
            AppButton({ label: '撤回', variant: 'primary', onTap: (): void => { void this.handleRevokePrivacy() } })
              .layoutWeight(1)
          }
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ top: 48 })
          .zIndex(80)
      }
    }
    .width('100%')
    .height('100%')
  }
}
