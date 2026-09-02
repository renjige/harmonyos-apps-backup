import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecyclePane } from '../components/box/RecyclePane'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { ThoughtStore } from '../services/ThoughtStore'
import { ThinkStore } from '../services/ThinkStore'
import { ThoughtCard } from '../models/ThoughtModels'
import { GrowthStat } from '../models/ThinkModels'
import { TimelineInsightService } from '../services/TimelineInsightService'
import { TimelinePane } from '../components/box/TimelinePane'
import { MetricChipRow } from '../components/box/MetricChipRow'
import { SectionHeader } from '../components/design-system/SectionHeader'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '思维匣'
  @StorageLink('tbReload') @Watch('onReloadChange') tbReload: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State showTrash: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State cardCount: number = 0
  @State tagCount: number = 0
  @State noteCount: number = 0
  @State streak: number = 0
  @State trash: ThoughtCard[] = []
  @State weekSummary: string = ''
  @State weekTopTag: string = ''
  @State linkedPipeline: number = 0
  @State showTimeline: boolean = false
  @State statCsv: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenCard: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onReloadChange(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    const cards = await ThoughtStore.loadActive()
    const stats = await ThoughtStore.tagStats()
    const g: GrowthStat = await ThinkStore.growth()
    this.cardCount = cards.length
    this.tagCount = stats.length
    this.noteCount = g.notes + g.breakdowns + g.opinions + g.goals + g.reviews
    this.streak = g.streak
    this.trash = await ThoughtStore.loadTrash()
    const insight = await TimelineInsightService.weekInsight()
    this.weekSummary = insight.summary
    this.weekTopTag = insight.topTag
    this.linkedPipeline = insight.linked
    this.statCsv = `卡片|${this.cardCount}|0;标签|${this.tagCount}|0;思考|${this.noteCount}|0;连续天|${this.streak}|1`
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
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

  private async exportNow(md: boolean): Promise<void> {
    const spark = await ThoughtStore.exportText(md)
    const think = await ThinkStore.exportText()
    const text = `${spark}\n\n${think}`
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast(md ? 'Markdown 已复制' : 'TXT 已复制')
    } catch {
      this.showToast('复制失败')
    }
  }

  private async openTrash(): Promise<void> {
    this.trash = await ThoughtStore.loadTrash()
    this.showTrash = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openTimeline(): void {
    this.showTimeline = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showTrash) {
          RecyclePane({
            items: this.trash,
            onBack: (): void => {
              this.showTrash = false
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onOpenCard: (id: string): void => { this.onOpenCard(id) },
            onChanged: (): void => { void this.reload() }
          })
        } else if (this.showTimeline) {
          TimelinePane({
            reloadToken: this.reloadToken + this.tbReload,
            onClose: (): void => {
              this.showTimeline = false
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onOpenCard: (id: string): void => {
              this.showTimeline = false
              AppStorage.setOrCreate('tabBarHidden', false)
              this.onOpenCard(id)
            }
          })
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.section }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image($r('app.media.texture_paper'))
                  .width('100%')
                  .height(120)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(120)
                  .linearGradient({
                    angle: 180,
                    colors: [
                      ['rgba(15,23,42,0.04)', 0.0],
                      ['rgba(26,35,50,0.72)', 1.0]
                    ]
                  })
                Column({ space: 6 }) {
                  Text(this.isLoggedIn() ? this.currentUsername : '游客')
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textOnInverse)
                    .width('100%')
                  Text(this.isLoggedIn()
                    ? '账号已登录 · 卡片仍只保存在本机'
                    : '游客可速记；登录仅用于账号，正文不上传')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textOnInverse)
                    .width('100%')
                }
                .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
              }
              .width('100%')
              .height(120)
              .borderRadius(Theme.radius.xl)
              .clip(true)

              Column({ space: Theme.space.s3 }) {
                SectionHeader({
                  title: '本机概览',
                  subtitle: '横向滑动查看各项统计'
                })
                MetricChipRow({ chipsCsv: this.statCsv })
              }

              Column({ space: Theme.space.s3 }) {
                SectionHeader({
                  title: '本周思考洞察',
                  subtitle: '看见灵感与加工的推进节奏'
                })
                Column({ space: Theme.space.s2 }) {
                  Text(this.weekSummary.length > 0 ? this.weekSummary : '开始记录后，这里会汇总本周灵感与加工进度')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  Text(`匣格链路 ${this.linkedPipeline} 条 · 高频标签 ${this.weekTopTag}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  AppButton({
                    label: '打开思考时间线',
                    variant: 'secondary',
                    onTap: (): void => { this.openTimeline() }
                  })
                }
                .width('100%')
                .padding(Theme.space.s5)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }

              Column({ space: Theme.space.s3 }) {
                SectionHeader({
                  title: '数据与设置',
                  subtitle: '导出、回收站与隐私合规'
                })
                AppButton({ label: '导出为 TXT', variant: 'secondary', onTap: (): void => { void this.exportNow(false) } })
                AppButton({ label: '导出为 Markdown', variant: 'secondary', onTap: (): void => { void this.exportNow(true) } })
                AppButton({ label: '回收站', variant: 'secondary', onTap: (): void => { void this.openTrash() } })
              }

              Row({ space: Theme.space.s3 }) {
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
              .onClick(() => {
                this.confirmDelete = false
                this.showSettings = true
                AppStorage.setOrCreate('tabBarHidden', true)
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
              Text('思维匣 1.0.0 · 运营者 承德锐泓科技信息有限公司')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 88 })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
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
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
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
        Text('返回')
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => {
            this.showSettings = false
            AppStorage.setOrCreate('tabBarHidden', false)
          })
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
            onTap: (): void => { this.legalKind = 'agreement'; this.showLegal = true }
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => { this.legalKind = 'privacy'; this.showLegal = true }
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
        .padding({ bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
  }
}
