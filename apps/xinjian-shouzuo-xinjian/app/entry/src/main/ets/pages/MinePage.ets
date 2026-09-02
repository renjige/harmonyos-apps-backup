import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { WorkListCard } from '../components/handcraft/WorkListCard'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { HandcraftWork, HandcraftInspiration } from '../models/HandcraftModels'
import { HandcraftBizService, WorkListFilter } from '../services/HandcraftBizService'
import { CraftDetailNav } from '../services/CraftDetailNav'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '手作心笺'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('accessToken') @Watch('onAuthChange') accessToken: string = ''
  @StorageLink('currentUsername') @Watch('onAuthChange') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State myWorks: HandcraftWork[] = []
  @State favorites: HandcraftWork[] = []
  @State inspirations: HandcraftInspiration[] = []
  @State loading: boolean = false
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.loadMineData()
  }

  onRefreshChange(): void {
    void this.loadMineData()
  }

  onAuthChange(): void {
    void this.loadMineData()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private achievementLevel(): AchievementInfo {
    const count = this.myWorks.length
    const info = new AchievementInfo()
    if (count >= 6) {
      info.level = '心笺匠人'
      info.desc = '创作已成习惯，继续分享温度'
    } else if (count >= 3) {
      info.level = '创作达人'
      info.desc = '已有稳定输出，继续记录你的创作'
    } else if (count >= 1) {
      info.level = '灵感记录者'
      info.desc = '迈出第一步，值得庆祝'
    } else {
      info.level = '初心手作人'
      info.desc = '去创作页记录第一件作品吧'
    }
    return info
  }

  private async loadMineData(): Promise<void> {
    if (!this.isLoggedIn()) {
      this.myWorks = []
      this.favorites = []
      this.inspirations = []
      return
    }
    this.loading = true
    const filter = new WorkListFilter()
    filter.userId = this.currentUsername
    this.myWorks = await HandcraftBizService.loadWorks(filter)
    this.favorites = await HandcraftBizService.loadFavorites()
    this.inspirations = await HandcraftBizService.loadInspirations(true)
    this.loading = false
  }

  private calendarEntries(): CalendarEntry[] {
    const out: CalendarEntry[] = []
    for (const w of this.myWorks) {
      if (w.createdAt.length === 0) {
        continue
      }
      const item = new CalendarEntry()
      item.dateLabel = w.createdAt.slice(0, 10)
      item.title = w.title
      item.kind = '作品'
      out.push(item)
    }
    for (const ins of this.inspirations) {
      if (ins.createdAt.length === 0) {
        continue
      }
      const item = new CalendarEntry()
      item.dateLabel = ins.createdAt.slice(0, 10)
      item.title = ins.title
      item.kind = '灵感'
      out.push(item)
    }
    out.sort((a, b) => (a.dateLabel < b.dateLabel ? 1 : -1))
    const limited: CalendarEntry[] = []
    const max = out.length < 8 ? out.length : 8
    for (let i = 0; i < max; i++) {
      limited.push(out[i])
    }
    return limited
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

  private async handleDeleteAccount(): Promise<void> {
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

  private buildExportText(): string {
    const lines: string[] = []
    lines.push(`# ${this.appName} 创作摘要`)
    lines.push(`账号：${this.currentUsername}`)
    lines.push(`作品 ${this.myWorks.length} 件 · 收藏 ${this.favorites.length} 件 · 灵感 ${this.inspirations.length} 条`)
    lines.push('')
    if (this.myWorks.length > 0) {
      lines.push('## 我的作品')
      for (const w of this.myWorks) {
        lines.push(`- ${w.title}（${w.category}）${w.summary}`)
      }
      lines.push('')
    }
    if (this.inspirations.length > 0) {
      lines.push('## 灵感笔记')
      for (const ins of this.inspirations) {
        lines.push(`- ${ins.title}：${ins.content}`)
      }
    }
    return lines.join('\n')
  }

  private async exportJournal(): Promise<void> {
    if (!this.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.buildExportText())
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('创作摘要已复制，可粘贴到备忘录保存')
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
                  ? '账号已登录 · 作品与收藏同步云端'
                  : '游客可浏览官方课堂；记录与收藏需登录')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              AppCard({ title: '成就等级', variant: 'glass' }) {
                Column({ space: 6 }) {
                  Text(this.achievementLevel().level)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().brandDeep)
                  Text(this.achievementLevel().desc)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textSecondary)
                  Text(`已记录 ${this.myWorks.length} 件 · 收藏 ${this.favorites.length} 件`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }.width('100%').alignItems(HorizontalAlign.Start)
              }

              if (this.isLoggedIn()) {
                Column({ space: Theme.space.s3 }) {
                  Text('创作日历')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  if (this.calendarEntries().length === 0) {
                    AppEmpty({ title: '暂无记录', description: '记录作品或灵感后会出现在这里' })
                  } else {
                    ForEach(this.calendarEntries(), (entry: CalendarEntry) => {
                      Row({ space: Theme.space.s3 }) {
                        Text(entry.dateLabel)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().textSecondary)
                          .width(96)
                        Column({ space: 2 }) {
                          Text(entry.title)
                            .fontSize(Theme.type.subhead)
                            .fontColor(Theme.colors().textPrimary)
                          Text(entry.kind)
                            .fontSize(Theme.type.caption)
                            .fontColor(Theme.colors().textSecondary)
                        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                      }
                      .width('100%')
                      .padding(Theme.space.s3)
                      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                      .borderRadius(Theme.radius.lg)
                      .border({ width: 1, color: Theme.colors().strokeHairline })
                    }, (entry: CalendarEntry) => `${entry.dateLabel}_${entry.title}`)
                  }
                }.width('100%')

                Column({ space: Theme.space.s3 }) {
                  Text('我的作品')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  if (this.myWorks.length === 0) {
                    AppEmpty({ title: '暂无作品', description: '去创作页记录第一件吧' })
                  } else {
                    ForEach(this.myWorks.slice(0, 3), (w: HandcraftWork) => {
                      WorkListCard({
                        work: w,
                        compact: true,
                        onTap: (): void => CraftDetailNav.openWork(w.id)
                      })
                    }, (w: HandcraftWork) => w.id)
                  }
                }.width('100%')

                Column({ space: Theme.space.s3 }) {
                  Text('我的收藏')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  if (this.favorites.length === 0) {
                    AppEmpty({ title: '暂无收藏', description: '在首页发现喜欢的作品并收藏' })
                  } else {
                    ForEach(this.favorites.slice(0, 3), (w: HandcraftWork) => {
                      WorkListCard({
                        work: w,
                        compact: true,
                        onTap: (): void => CraftDetailNav.openWork(w.id)
                      })
                    }, (w: HandcraftWork) => w.id)
                  }
                }.width('100%')
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
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick(() => { this.showSettings = true })

              if (this.isLoggedIn()) {
                AppButton({
                  label: '导出创作摘要',
                  variant: 'secondary',
                  onTap: (): void => { void this.exportJournal() }
                })
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
        Column() {
          LegalDocOverlay({
            kind: this.legalKind,
            onClose: (): void => { this.showLegal = false }
          })
        }
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
          Text('个人信息收集清单 · 第三方共享清单见 store/ 上架资料')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '注销账号',
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

class CalendarEntry {
  dateLabel: string = ''
  title: string = ''
  kind: string = ''
}

class AchievementInfo {
  level: string = ''
  desc: string = ''
}
