import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { EmotionCount, MoodStats, ProfileData } from '../models/MoodModels'
import { ExportService } from '../services/ExportService'
import { MonthlyReportService } from '../services/MonthlyReportService'
import { MoodStore } from '../services/MoodStore'
import { PhotoPickService } from '../services/PhotoPickService'
import { PrivacyService } from '../services/PrivacyService'
import { ProfileService } from '../services/ProfileService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  @State profile: ProfileData = new ProfileData()
  @State stats: MoodStats = new MoodStats()
  @State toastText: string = ''
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  @State showSettings: boolean = false
  @State darkMode: boolean = false
  @State editingNick: boolean = false
  @State nickInput: string = ''
  @State refreshSeen: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    void this.load()
  }

  private onReload(): void {
    if (this.reloadToken !== this.refreshSeen) {
      this.refreshSeen = this.reloadToken
      void this.load()
    }
  }

  private async load(): Promise<void> {
    this.profile = await ProfileService.load()
    this.stats = await MonthlyReportService.overallStats()
    this.nickInput = this.profile.nickname
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async saveNickname(): Promise<void> {
    await ProfileService.saveNickname(this.nickInput)
    this.profile.nickname = this.nickInput
    this.editingNick = false
    this.showToast('昵称已更新')
  }

  private async pickAvatar(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    const uri = await PhotoPickService.pickOneImage(this.uiContext)
    if (uri.length > 0) {
      await ProfileService.saveAvatar(uri)
      this.profile.avatarPath = uri
    }
  }

  private async exportMonthly(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    const now = new Date()
    try {
      const path = await ExportService.exportMonthlyReport(this.uiContext, now.getFullYear(), now.getMonth() + 1)
      this.showToast(`月报已导出：${path}`)
    } catch {
      this.showToast('导出失败')
    }
  }

  private async exportAll(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    try {
      const path = await ExportService.exportAllToFile(this.uiContext)
      const text = await MoodStore.exportAllText()
      await ExportService.copyToClipboard(text)
      this.showToast(`已导出并复制摘要：${path}`)
    } catch {
      this.showToast('导出失败')
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回隐私同意，再次进入须重新同意')
  }

  private async clearAllData(): Promise<void> {
    await MoodStore.clearAll()
    void this.load()
    this.showSettings = false
    this.showToast('本地记录已清除')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s4 }) {
            Stack() {
              if (this.profile.avatarPath.length > 0) {
                Image(this.profile.avatarPath)
                  .width(64)
                  .height(64)
                  .borderRadius(32)
                  .objectFit(ImageFit.Cover)
              } else {
                Column() {
                  AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
                }
                .width(64)
                .height(64)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(32)
              }
            }
            .onClick((): void => { void this.pickAvatar() })

            Column({ space: 4 }) {
              if (this.editingNick) {
                TextInput({ text: this.nickInput, placeholder: '昵称' })
                  .onChange((v: string) => { this.nickInput = v })
                AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.saveNickname() } })
              } else {
                Text(this.profile.nickname)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                Text('点击头像更换 · 点击昵称编辑')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .onClick((): void => { this.editingNick = true })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s4 }) {
            Column({ space: 4 }) {
              Text(`${this.stats.totalDays}`)
                .fontSize(Theme.type.displayS)
                .fontColor(Theme.colors().brandPrimary)
                .fontWeight(FontWeight.Bold)
              Text('累计记录天')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Column({ space: Theme.space.s2 }) {
            Text('情绪分布')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
            if (this.stats.emotionCounts.length === 0) {
              Text('暂无统计数据')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
            } else {
              ForEach(this.stats.emotionCounts, (ec: EmotionCount) => {
                Row({ space: Theme.space.s2 }) {
                  Text(ec.label)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textPrimary)
                    .width(48)
                  Stack({ alignContent: Alignment.Start }) {
                    Column()
                      .width('100%')
                      .height(8)
                      .backgroundColor(Theme.colors().surfaceSubtle)
                      .borderRadius(4)
                    Column()
                      .width(`${Math.min(100, ec.count * 12)}%`)
                      .height(8)
                      .backgroundColor(ec.color)
                      .borderRadius(4)
                  }
                  .layoutWeight(1)
                  .height(8)
                  Text(`${ec.count}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .width('100%')
              }, (ec: EmotionCount) => ec.id)
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          this.MenuRow('导出本月月痕报告', (): void => { void this.exportMonthly() })
          this.MenuRow('导出全部记录', (): void => { void this.exportAll() })
          this.MenuRow('设置与隐私', (): void => {
            this.showSettings = true
            AppStorage.setOrCreate('tabBarHidden', true)
          })
          this.MenuRow('关于月痕集', (): void => {
            this.showToast('月痕集 v1.0 — 情绪记录与月度回顾')
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')

      if (this.showSettings) {
        Column() {
          Column()
            .width('100%')
            .layoutWeight(1)
            .backgroundColor(Theme.colors().overlayScrim)
            .onClick((): void => {
              this.showSettings = false
              AppStorage.setOrCreate('tabBarHidden', false)
            })
          Column({ space: Theme.space.s2 }) {
            Text('设置与隐私')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .margin({ bottom: Theme.space.s2 })
            this.MenuRow('隐私政策', (): void => { this.showPrivacy = true })
            this.MenuRow('用户协议', (): void => { this.showAgreement = true })
            Row({ space: Theme.space.s3 }) {
              Text('深色模式').fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
                .selectedColor(Theme.colors().brandPrimary)
                .onChange((v: boolean) => {
                  this.darkMode = v
                  ThemeAppearance.apply(v ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
                })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            AppButton({
              label: '清除全部本地记录',
              variant: 'secondary',
              onTap: (): void => { void this.clearAllData() }
            })
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { void this.handleRevokePrivacy() }
            })
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        }
        .width('100%')
        .height('100%')
        .zIndex(30)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(40)
      }

      if (this.showPrivacy) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacy = false } })
      }
      if (this.showAgreement) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreement = false } })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onAppear((): void => {
      this.onReload()
      this.darkMode = Theme.isDark()
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
  }

  @Builder
  MenuRow(label: string, onTap: () => void) {
    Row() {
      Text(label).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary)
      Blank()
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }
}
