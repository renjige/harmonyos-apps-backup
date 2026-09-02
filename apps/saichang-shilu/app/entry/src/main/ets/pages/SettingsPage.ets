import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { SportTypeOption, UserProfile } from '../models/SportRecord'
import { AchieveItem, AvatarPalette, DashStats } from '../models/CollectModels'
import { ExportService } from '../services/ExportService'
import { PrivacyService } from '../services/PrivacyService'
import { ProfileStore } from '../services/ProfileStore'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AchieveBadge } from '../components/sport/SportCards'
import { SeasonReportPage } from './SeasonReportPage'
import { DataInsightsPage } from './DataInsightsPage'
import { PredictionLabPage } from './PredictionLabPage'
import { WeeklyDigestPage } from './WeeklyDigestPage'
import { MvpLeaderboardPage } from './MvpLeaderboardPage'
import { VenueJournalPage } from './VenueJournalPage'
import { MemoryStats } from '../services/MemoryStats'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State toastText: string = ''
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  @State darkMode: boolean = false
  @State profile: UserProfile = new UserProfile()
  @State editingName: boolean = false
  @State nameInput: string = ''
  @State dash: DashStats = new DashStats()
  @State achieves: AchieveItem[] = []
  @State showSeasonReport: boolean = false
  @State showInsights: boolean = false
  @State showPrediction: boolean = false
  @State showWeeklyDigest: boolean = false
  @State showMvpBoard: boolean = false
  @State showVenue: boolean = false
  @Prop reloadToken: number = 0
  @State lastToken: number = -1
  private uiContext: common.UIAbilityContext | null = null
  private sportOptions: SportTypeOption[] = SportTypeOption.all()
  private palette: string[] = AvatarPalette.colors()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await ProfileStore.load()
    this.nameInput = this.profile.nickname
    this.dash = await MemoryStats.dash()
    this.achieves = MemoryStats.achievements(this.dash)
    this.darkMode = Theme.isDark()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private initial(): string {
    if (this.profile.nickname.length > 0) {
      return this.profile.nickname.substring(0, 1)
    }
    return '赛'
  }

  private avatarColor(): string {
    if (this.profile.avatarPath.indexOf('#') === 0) {
      return this.profile.avatarPath
    }
    return '#007AFF'
  }

  private async pickColor(hex: string): Promise<void> {
    this.profile.avatarPath = hex
    await ProfileStore.save(this.profile)
    this.showToast('头像色已更新')
  }

  private async saveProfile(): Promise<void> {
    await ProfileStore.save(this.profile)
  }

  private async exportText(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    try {
      const path = await ExportService.exportTextFile(this.uiContext)
      this.showToast(`文本已导出：${path}`)
    } catch {
      this.showToast('导出失败')
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showToast('已撤回本地隐私标记。本应用使用华为隐私声明托管，不再弹出自建同意窗。')
  }

  private toggleSport(id: string): void {
    const next: string[] = []
    let found = false
    for (const s of this.profile.preferredSports) {
      if (s === id) {
        found = true
      } else {
        next.push(s)
      }
    }
    if (!found) {
      next.push(id)
    }
    this.profile.preferredSports = next
    void this.saveProfile()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

          Row({ space: Theme.space.s4 }) {
            Column() {
              Text(this.initial())
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width(64)
            .height(64)
            .borderRadius(32)
            .backgroundColor(this.avatarColor())
            .justifyContent(FlexAlign.Center)

            Column({ space: 4 }) {
              if (this.editingName) {
                TextInput({ text: this.nameInput, placeholder: '昵称' })
                  .onChange((v: string) => { this.nameInput = v })
                AppButton({
                  label: '保存昵称',
                  variant: 'secondary',
                  onTap: (): void => {
                    this.profile.nickname = this.nameInput.trim().length > 0 ? this.nameInput.trim() : '赛场拾录'
                    this.editingName = false
                    void this.saveProfile()
                  }
                })
              } else {
                Text(this.profile.nickname)
                  .fontSize(Theme.type.title3)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text('点昵称可改 · 下方色板换头像')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .onClick((): void => {
                    this.nameInput = this.profile.nickname
                    this.editingName = true
                  })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.palette, (hex: string) => {
              Column()
                .width(36)
                .height(36)
                .borderRadius(18)
                .backgroundColor(hex)
                .margin({ right: 10, bottom: 8 })
                .onClick((): void => { void this.pickColor(hex) })
            }, (hex: string) => hex)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Row() {
              Text(`${new Date().getFullYear()} 赛季报告`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text('查看完整报告 →')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
            }
            .width('100%')
            .onClick((): void => { this.showSeasonReport = true })
            Text(`记录赛事 ${this.dash.matches} 场 · 复盘 ${this.dash.recaps} 次`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(`瞬间 ${this.dash.moments} · 球队 ${this.dash.teams} · 球员 ${this.dash.players}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s2 }) {
            Text('分析工具')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            this.SettingRow('预测实验室', (): void => { this.showPrediction = true })
            this.SettingRow('观赛周报', (): void => { this.showWeeklyDigest = true })
            this.SettingRow('MVP 排行榜', (): void => { this.showMvpBoard = true })
            this.SettingRow('场馆志', (): void => { this.showVenue = true })
            this.SettingRow('数据洞察', (): void => { this.showInsights = true })
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('观赛成就')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.achieves, (a: AchieveItem) => {
                AchieveBadge({ title: a.title, emoji: a.emoji, done: a.done })
              }, (a: AchieveItem) => a.id)
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s2 }) {
            Text('运动偏好')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.sportOptions, (opt: SportTypeOption) => {
                Text(`${opt.emoji} ${opt.label}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.profile.preferredSports.indexOf(opt.id) >= 0 ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.profile.preferredSports.indexOf(opt.id) >= 0 ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 6, bottom: 6 })
                  .onClick((): void => { this.toggleSport(opt.id) })
              }, (opt: SportTypeOption) => opt.id)
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          this.SettingRow('数据洞察', (): void => { this.showInsights = true })
          this.SettingRow('导出文本', (): void => { void this.exportText() })
          this.SettingRow('隐私政策', (): void => { this.showPrivacy = true })
          this.SettingRow('用户协议', (): void => { this.showAgreement = true })
          this.SettingRow('关于赛场拾录', (): void => {
            this.showToast('赛场拾录 — 个人赛事记录、比赛复盘与体育记忆')
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

          Row({ space: Theme.space.s3 }) {
            Text('深色模式')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean) => {
                this.darkMode = v
                if (this.uiContext !== null) {
                  ThemeAppearance.apply(v ? 'dark' : 'light', this.uiContext)
                } else {
                  ThemeAppearance.apply(v ? 'dark' : 'light')
                }
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }

      if (this.showPrivacy) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacy = false } })
      }
      if (this.showAgreement) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreement = false } })
      }
      if (this.showSeasonReport) {
        SeasonReportPage({ onClose: (): void => { this.showSeasonReport = false } })
      }
      if (this.showInsights) {
        DataInsightsPage({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showInsights = false; void this.reload() }
        })
      }
      if (this.showPrediction) {
        PredictionLabPage({ onClose: (): void => { this.showPrediction = false } })
      }
      if (this.showWeeklyDigest) {
        WeeklyDigestPage({ onClose: (): void => { this.showWeeklyDigest = false } })
      }
      if (this.showMvpBoard) {
        MvpLeaderboardPage({ onClose: (): void => { this.showMvpBoard = false } })
      }
      if (this.showVenue) {
        VenueJournalPage({ onClose: (): void => { this.showVenue = false } })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }

  @Builder
  SettingRow(label: string, onTap: () => void) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Blank()
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }
}
