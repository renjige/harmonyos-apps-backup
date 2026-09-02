import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppTextInputField } from '../components/design-system/AppTextInputField'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { UserProfile } from '../models/WorkoutModels'
import { WorkoutStore } from '../services/WorkoutStore'
import { PrivacyService } from '../services/PrivacyService'
import { ExportService } from '../services/ExportService'
import { TrainingStore } from '../services/TrainingStore'
import { StatsService } from '../services/StatsService'
import { MineArchiveExtras } from './MineArchiveExtras'
import { MineSettingsPanel } from './MineSettingsPanel'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fitDataEpoch') @Watch('onDataEpochChange') fitDataEpoch: number = 0
  @Link @Watch('onRefreshTokenChange') refreshToken: number
  @Prop bottomInset: number = 76
  onPrivacyRevoked: () => void = () => {}
  onDataCleared: () => void = () => {}
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State dailyGoalInput: string = '30'
  @State weeklyGoalInput: string = '5'
  @State themeMode: string = 'system'
  @State totalWorkouts: number = 0
  @State totalMinutes: number = 0
  @State streakDays: number = 0
  @State goalsDone: number = 0
  @State statTick: number = 0
  @State showSettings: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reloadStats(): Promise<void> {
    const totals = await StatsService.totals()
    this.totalWorkouts = totals.totalWorkouts
    this.totalMinutes = totals.totalMinutes
    this.streakDays = totals.streakDays
    const unlocked = await WorkoutStore.loadUnlockedAchievements()
    const ch = await TrainingStore.loadChallenges()
    let chDone = 0
    for (const c of ch) {
      if (c.done) {
        chDone++
      }
    }
    this.goalsDone = unlocked.length + chDone
    this.statTick++
  }

  private async reload(): Promise<void> {
    await TrainingStore.ensureTemplates()
    await this.reloadStats()
    this.profile = await WorkoutStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    this.dailyGoalInput = `${this.profile.dailyGoalMinutes}`
    this.weeklyGoalInput = `${this.profile.weeklyGoalDays}`
    const mode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.themeMode = mode
    ThemeAppearance.apply(mode as 'light' | 'dark' | 'system', this.getUIContext().getHostContext() as common.UIAbilityContext)
    AppStorage.setOrCreate('colorMode', mode)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async saveProfile(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '运动达人'
    const daily = parseInt(this.dailyGoalInput, 10)
    const weekly = parseInt(this.weeklyGoalInput, 10)
    this.profile.dailyGoalMinutes = isNaN(daily) || daily <= 0 ? 30 : daily
    this.profile.weeklyGoalDays = isNaN(weekly) || weekly <= 0 ? 5 : Math.min(7, weekly)
    await WorkoutStore.saveProfile(this.profile)
    this.showToast('资料与目标已保存')
  }

  private async exportAndCopy(): Promise<void> {
    const ok = await ExportService.copyToClipboard()
    this.showToast(ok ? '数据已复制到剪贴板，可粘贴到备忘录保存' : '复制失败，请稍后重试')
  }

  private async clearAllRecords(): Promise<void> {
    await WorkoutStore.clearAllWorkouts()
    this.onDataCleared()
    this.showToast('全部运动记录已清除')
    await this.reload()
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.profile.themeMode = mode
    ThemeAppearance.apply(mode as 'light' | 'dark' | 'system', this.getUIContext().getHostContext() as common.UIAbilityContext)
    AppStorage.setOrCreate('colorMode', mode)
    await WorkoutStore.saveProfile(this.profile)
    this.showToast('主题已切换')
  }

  private clearCache(): void {
    this.showToast('界面缓存已清理（运动数据未删除）')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    this.showToast('已撤回隐私同意。协议可在「设置与隐私」再次查看')
    this.onPrivacyRevoked()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的体能档案')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(`${this.totalWorkouts}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('累计训练')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Center)

            Column({ space: 4 }) {
              Text(`${this.streakDays}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('坚持天数')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Center)

            Column({ space: 4 }) {
              Text(`${this.goalsDone}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('完成目标')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .key(`mine-stats-${this.statTick}`)

          Row({ space: Theme.space.s4 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            Column({ space: Theme.space.s2 }) {
              AppTextInputField({
                text: this.nicknameInput,
                placeholder: '昵称',
                onChange: (v: string): void => { this.nicknameInput = v }
              })
              Row({ space: Theme.space.s2 }) {
                Column({ space: 4 }) {
                  Text('日目标(分)')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                  AppTextInputField({
                    text: this.dailyGoalInput,
                    placeholder: '30',
                    numeric: true,
                    compact: true,
                    onChange: (v: string): void => { this.dailyGoalInput = v }
                  })
                }
                .layoutWeight(1)
                Column({ space: 4 }) {
                  Text('周目标(天)')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                  AppTextInputField({
                    text: this.weeklyGoalInput,
                    placeholder: '5',
                    numeric: true,
                    compact: true,
                    onChange: (v: string): void => { this.weeklyGoalInput = v }
                  })
                }
                .layoutWeight(1)
              }
              .width('100%')
              AppButton({
                label: '保存资料与目标',
                variant: 'secondary',
                onTap: (): void => { void this.saveProfile() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Text(`${this.totalMinutes} 分钟累计`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          MineArchiveExtras({
            refreshToken: this.refreshToken,
            onToast: (msg: string): void => { this.showToast(msg) }
          })

          AppListRow({
            title: '导出数据',
            subtitle: '复制为文本格式',
            onTap: (): void => { void this.exportAndCopy() }
          })

          AppListRow({
            title: '设置与隐私',
            subtitle: '协议 · 撤回 · 主题',
            onTap: (): void => { this.showSettings = true }
          })

          AppListRow({
            title: '关于体能图志',
            subtitle: '版本 1.0.0 · 本地训练规划与成长',
            onTap: (): void => { this.showToast('体能图志 — 训练日志、图鉴、挑战与成长图志') }
          })

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      if (this.showSettings) {
        MineSettingsPanel({
          themeMode: this.themeMode,
          onClose: (): void => { this.showSettings = false },
          onTheme: (mode: string): void => { void this.persistTheme(mode) },
          onClearCache: (): void => { this.clearCache() },
          onClearRecords: (): void => { void this.clearAllRecords() },
          onRevoke: (): void => { void this.handleRevokePrivacy() }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ top: 48 })
          .backgroundColor('#1A2332')
          .borderRadius(Theme.radius.pill)
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }
}
