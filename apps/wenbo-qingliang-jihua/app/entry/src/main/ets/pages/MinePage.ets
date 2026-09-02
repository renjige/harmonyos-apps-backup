import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppTimePickerField } from '../components/design-system/AppDatePickerField'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { CoolPlanBizService } from '../services/CoolPlanBizService'
import { CoolPlanLocalStore } from '../services/CoolPlanLocalStore'
import { CoolPlanStats } from '../models/CoolPlanModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '清凉计划'
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State stats: CoolPlanStats = new CoolPlanStats()
  @State remindTime: string = '21:00'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await CoolPlanBizService.loadStats()
    this.remindTime = await CoolPlanLocalStore.getRemindTime()
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
    await CoolPlanLocalStore.setRemindTime(this.remindTime)
    this.showToast(`已设置提醒 ${this.remindTime}`)
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
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
                        colors: [[Theme.colors().brandPrimary, 0], ['#4A9E9E', 1]]
                      })
                      .borderRadius(28)
                    AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
                  }
                  Column({ space: 4 }) {
                    Text(this.isLoggedIn() ? this.currentUsername : '游客')
                      .fontSize(Theme.type.title3)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.colors().textPrimary)
                      .width('100%')
                    Text(this.isLoggedIn()
                      ? '账号已登录 · 心情/呼吸/心语将同步云端'
                      : '🌿 游客可浏览语录与呼吸；记录保存在本机')
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
                  label: '连续打卡',
                  value: `${this.stats.streakDays}`,
                  trend: '天',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '清凉指数',
                  value: `${this.stats.todayCoolIndex}`,
                  trend: '今日',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '呼吸累计',
                  value: `${this.stats.breathMinutes}`,
                  trend: '分钟',
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

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '心语',
                  value: `${this.stats.journalCount}`,
                  trend: '篇',
                  positive: true
                }).layoutWeight(1)
                Column().layoutWeight(1)
              }
              .width('100%')

              Column({ space: Theme.space.s3 }) {
                Row({ space: Theme.space.s2 }) {
                  Column() {
                    AppIcon({ name: 'bell', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                  }
                  .width(36)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.md)
                  Text('🔔 呼吸提醒')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                }
                .width('100%')
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
                Text('提醒时间保存在本机，用于你自行安排练习习惯。')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

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
                  Text('协议 · 撤回同意 · 注销')
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
