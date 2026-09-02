import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppTimePickerField } from '../components/design-system/AppDatePickerField'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { WarmCompanionBizService } from '../services/WarmCompanionBizService'
import { WarmCompanionLocalStore } from '../services/WarmCompanionLocalStore'
import { WarmMediaCover } from '../components/warm/WarmMediaHero'
import { BadgeItem, MoodItem, WarmCompanionStats } from '../models/WarmCompanionModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

class CalendarCell {
  day: number = 0
  dateKey: string = ''
  inMonth: boolean = false
  hasRecord: boolean = false
  mood: string = ''
}

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '暖光陪伴'
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkMode') darkMode: boolean = false
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State stats: WarmCompanionStats = new WarmCompanionStats()
  @State badges: BadgeItem[] = []
  @State nickname: string = ''
  @State remindTime: string = '21:00'
  @State notifyEnabled: boolean = true
  @State cells: CalendarCell[] = []
  @State moods: MoodItem[] = []
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await WarmCompanionBizService.loadStats()
    this.badges = await WarmCompanionBizService.loadBadges()
    this.moods = await WarmCompanionBizService.loadMoods()
    this.nickname = await WarmCompanionLocalStore.getNickname()
    this.remindTime = await WarmCompanionLocalStore.getRemindTime()
    this.notifyEnabled = await WarmCompanionLocalStore.getNotifyEnabled()
    this.buildCalendar()
  }

  private buildCalendar(): void {
    const list: CalendarCell[] = []
    let i = 29
    while (i >= 0) {
      const key = WarmCompanionLocalStore.dateKeyOffset(i)
      const c = new CalendarCell()
      c.dateKey = key
      c.inMonth = true
      const parts = key.split('-')
      c.day = parts.length === 3 ? Number.parseInt(parts[2], 10) : 0
      for (const m of this.moods) {
        if (m.noteDate === key) {
          c.hasRecord = true
          c.mood = m.mood
        }
      }
      list.push(c)
      i -= 1
    }
    this.cells = list
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private displayName(): string {
    if (this.nickname.length > 0) {
      return this.nickname
    }
    if (this.isLoggedIn()) {
      return this.currentUsername
    }
    return '暖光旅人'
  }

  private isBadgeUnlocked(b: BadgeItem): boolean {
    return this.stats.companionDays >= b.unlockDays
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

  private async saveRemindTime(): Promise<void> {
    await WarmCompanionLocalStore.setRemindTime(this.remindTime)
    this.showToast(`已设置提醒 ${this.remindTime}`)
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的空间', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: Theme.space.s3 }) {
                Row({ space: Theme.space.s3 }) {
                  Stack({ alignContent: Alignment.Center }) {
                    Column()
                      .width(56)
                      .height(56)
                      .linearGradient({
                        angle: 135,
                        colors: [[Theme.colors().brandPrimary, 0], [Theme.colors().brandAccent, 1]]
                      })
                      .borderRadius(28)
                    AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
                  }
                  Column({ space: 4 }) {
                    Text(this.displayName())
                      .fontSize(Theme.type.title3)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.colors().textPrimary)
                      .width('100%')
                    Text(this.isLoggedIn()
                      ? '账号已登录 · 记录可同步云端'
                      : '🌿 游客模式 · 记录保存在本机')
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.colors().textSecondary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '陪伴天数',
                  value: `${this.stats.companionDays}`,
                  trend: '连续',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '心情记录',
                  value: `${this.stats.moodCount}`,
                  trend: '次',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              Column({ space: Theme.space.s3 }) {
                Text('📅 陪伴日历（近 30 天）')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                  ForEach(this.cells, (c: CalendarCell, idx: number) => {
                    Column({ space: 2 }) {
                      Text(`${c.day}`)
                        .fontSize(Theme.type.overline)
                        .fontColor(Theme.colors().textPrimary)
                      Circle()
                        .width(c.hasRecord ? 6 : 4)
                        .height(c.hasRecord ? 6 : 4)
                        .fill(c.hasRecord ? Theme.colors().brandPrimary : Theme.colors().strokeStrong)
                    }
                    .width('16.66%')
                    .height(40)
                    .justifyContent(FlexAlign.Center)
                  }, (c: CalendarCell, idx: number) => `${idx}_${c.dateKey}`)
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Column({ space: Theme.space.s3 }) {
                Text('🏅 徽章墙')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                  ForEach(this.badges, (b: BadgeItem) => {
                    Column({ space: Theme.space.s2 }) {
                      WarmMediaCover({
                        coverKey: b.coverKey.length > 0 ? b.coverKey : 'cover_badge_glow',
                        tileSize: 64,
                        cornerRadius: Theme.radius.md
                      })
                      .opacity(this.isBadgeUnlocked(b) ? 1 : 0.35)
                      Text(b.title)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.isBadgeUnlocked(b) ?
                          Theme.colors().brandPrimary : Theme.colors().textSecondary)
                        .width('100%')
                        .textAlign(TextAlign.Center)
                      Text(b.summary)
                        .fontSize(Theme.type.overline)
                        .fontColor(Theme.colors().textSecondary)
                        .width('100%')
                        .textAlign(TextAlign.Center)
                    }
                    .width('48%')
                    .padding(Theme.space.s3)
                    .margin({ bottom: Theme.space.s2 })
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.lg)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                  }, (b: BadgeItem) => b.id)
                }
                .width('100%')
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({ name: 'gear', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                }
                .width(36)
                .height(36)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.md)
                Column({ space: 2 }) {
                  Text('设置与隐私')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text('通知 · 深色模式 · 协议')
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
          Row() {
            Text('陪伴提醒')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.notifyEnabled })
              .onChange((v: boolean) => {
                this.notifyEnabled = v
                void WarmCompanionLocalStore.setNotifyEnabled(v)
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          AppTimePickerField({
            label: '提醒时间',
            value: this.remindTime,
            placeholder: '请选择时间',
            onChange: (v: string): void => { this.remindTime = v }
          })
          AppButton({
            label: '保存提醒时间',
            variant: 'secondary',
            onTap: (): void => { void this.saveRemindTime() }
          })

          Row() {
            Text('深色模式')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .onChange((v: boolean) => {
                this.darkMode = v
                AppStorage.setOrCreate('darkMode', v)
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Text('关于暖光陪伴\n面向都市青年的轻度情绪陪伴应用。不提供生成式对话，完全免费无广告。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

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
            label: '个人信息收集清单',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'personal'
              this.showLegal = true
            }
          })
          AppButton({
            label: '第三方共享清单',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'thirdParty'
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
}
