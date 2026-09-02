import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { CommonSenseStore } from '../services/CommonSenseStore'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseStats } from '../models/CommonSenseModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '常识集'
  @Prop overlayMode: boolean = false
  @Prop settingsOnly: boolean = false
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('fontScale') fontScale: number = 1.0
  @StorageLink('csRefresh') @Watch('onCsRefresh') csRefresh: number = 0
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State stats: CommonSenseStats = new CommonSenseStats()
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onCloseOverlay: () => void = () => {}

  aboutToAppear(): void {
    if (this.settingsOnly) {
      this.showSettings = true
    }
    this.refreshStats()
  }

  onCsRefresh(): void {
    this.refreshStats()
  }

  private refreshStats(): void {
    this.stats = CommonSenseStore.stats()
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
    void CommonSenseStore.clearCache()
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
    const nextDark = !Theme.isDark()
    ThemeAppearance.apply(nextDark ? 'dark' : 'light',
      this.getUIContext().getHostContext() as common.UIAbilityContext)
    await CommonSenseStore.setDark(nextDark)
    this.showToast(nextDark ? '已切换深色模式' : '已切换浅色模式')
  }

  private async onFontChange(value: number): Promise<void> {
    await CommonSenseStore.setFontScale(value)
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
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.isLoggedIn()
                  ? '账号已登录 · 收藏与笔记保存在本机'
                  : '游客可浏览全部常识；登录为可选')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Row({ space: 24 }) {
                  Column() {
                    Text(`${this.stats.favorites}`)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.colors().brandPrimary)
                    Text('收藏')
                      .fontSize(12)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  Column() {
                    Text(`${this.stats.readDays}`)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.colors().brandPrimary)
                    Text('打卡')
                      .fontSize(12)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  Column() {
                    Text(`${this.stats.checkInStreak}`)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.colors().brandPrimary)
                    Text('连续')
                      .fontSize(12)
                      .fontColor(Theme.colors().textSecondary)
                  }
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              this.MenuRow('成长看板', '计划 · 图表 · 分类分布', (): void => {
                CommonSenseDetailNav.openGrowth()
              })
              this.MenuRow('学习计划', '设定本周阅读目标', (): void => {
                CommonSenseDetailNav.openPlan()
              })
              this.MenuRow('学习动态', '阅读 · 打卡 · 小测时间轴', (): void => {
                CommonSenseDetailNav.openTimeline()
              })
              this.MenuRow('学习成就', '坚持阅读解锁徽章', (): void => {
                CommonSenseDetailNav.openAchievements()
              })
              this.MenuRow('本周回顾', '汇总本周学习数据', (): void => {
                CommonSenseDetailNav.openReview()
              })
              this.MenuRow('专题夹', '按主题整理常识', (): void => {
                CommonSenseDetailNav.openTopics()
              })
              this.MenuRow('学习笔记', '记录心得与延伸', (): void => {
                CommonSenseDetailNav.openUserNotes()
              })
              this.MenuRow('学习记录', '阅读历史 · 收藏 · 已掌握', (): void => {
                CommonSenseDetailNav.openHistory()
              })
              this.MenuRow('学习统计', '打卡天数 · 连续 · 清单数', (): void => {
                CommonSenseDetailNav.openStats()
              })
              this.MenuRow('每日打卡', '记录今日阅读打卡', (): void => {
                CommonSenseDetailNav.openCheckIn()
              })
              this.MenuRow('常识问答', '选择题测验与错题回顾', (): void => {
                CommonSenseDetailNav.openQuiz()
              })
              this.MenuRow('生活场景库', '清洁 · 保存 · 出行 · 应急', (): void => {
                CommonSenseDetailNav.openScenes()
              })
              this.MenuRow('常识清单', '自建清单 · 已学标记 · 备注', (): void => {
                CommonSenseDetailNav.openLists()
              })
              this.MenuRow('生活工具', '日期 · 换算 · 节气 · 年龄', (): void => {
                CommonSenseDetailNav.openTools()
              })
              this.MenuRow('学习提醒', '每天定时查看今日常识', (): void => {
                CommonSenseDetailNav.openRemind()
              })
              this.MenuRow('常识偏好', '问卷匹配推荐分类', (): void => {
                CommonSenseDetailNav.openDiagnose()
              })
              this.MenuRow('机构消息', '系统通知与栏目提醒', (): void => {
                CommonSenseDetailNav.openMessages()
              })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', (): void => {
                this.confirmDelete = false
                this.showSettings = true
              })

              Column({ space: Theme.space.s2 }) {
                Text('正文字号')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Slider({
                  value: this.fontScale,
                  min: 0.85,
                  max: 1.35,
                  step: 0.05
                })
                  .width('100%')
                  .onChange((v: number): void => { void this.onFontChange(v) })
                Text(`${Math.round(this.fontScale * 100)}%`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)

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
          .fontColor(Theme.colors().textPrimary)
        Text(sub)
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
