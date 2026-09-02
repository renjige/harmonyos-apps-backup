import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { InspirationItem, WeekReviewData } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { AuthService } from '../services/AuthService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct WeeklyReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State data: WeekReviewData = new WeekReviewData()
  @State reflection: string = ''
  @State loading: boolean = true
  @State saving: boolean = false
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.data = await InspirationBizService.loadWeekReview(this.currentUsername)
      this.reflection = this.data.reflection
    } else {
      this.data = new WeekReviewData()
      this.reflection = ''
    }
    this.loading = false
  }

  private summaryText(): string {
    return `【灵感手册 · 本周回顾 ${this.data.weekLabel}】\n` +
      `灵感 ${this.data.inspirationCount} 条 · 画板 ${this.data.boardCount} 本 · 打卡 ${this.data.checkInCount} 天 · 完成里程碑 ${this.data.completedMilestones} 项\n` +
      (this.reflection.length > 0 ? `反思：${this.reflection}` : '')
  }

  private async copySummary(): Promise<void> {
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.summaryText())
    await pasteboard.getSystemPasteboard().setData(data)
    this.showToast('本周回顾已复制')
  }

  private async saveReflection(): Promise<void> {
    if (!AuthService.requireAuth('sync_records')) {
      this.onRequireAuth()
      return
    }
    if (this.reflection.trim().length === 0) {
      this.showToast('请先写下本周反思')
      return
    }
    this.saving = true
    const ok = await InspirationBizService.saveWeeklyReflection(this.reflection.trim())
    this.saving = false
    if (ok) {
      this.data.reflection = this.reflection.trim()
      this.showToast('周回顾已保存')
    } else {
      this.showToast('保存失败，请稍后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('本周回顾')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.loading) {
          AppLoading({ label: '汇总本周创作…' }).layoutWeight(1)
        } else if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后查看本周回顾',
            description: '系统会汇总本周灵感、画板与打卡数据',
            actionLabel: '去登录',
            onAction: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text(`周期 ${this.data.weekLabel}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '本周灵感',
                  value: `${this.data.inspirationCount}`,
                  trend: '条',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '本周画板',
                  value: `${this.data.boardCount}`,
                  trend: '本',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')
              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '本周打卡',
                  value: `${this.data.checkInCount}`,
                  trend: '天',
                  positive: this.data.checkInCount > 0
                }).layoutWeight(1)
                AppStatCard({
                  label: '里程碑',
                  value: `${this.data.completedMilestones}`,
                  trend: '项',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              Text('本周灵感亮点')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .width('100%')
              if (this.data.inspirations.length === 0) {
                AppEmpty({
                  title: '本周还没有灵感记录',
                  description: '去工作台打卡或记录一条灵感吧'
                })
              } else {
                ForEach(this.data.inspirations.slice(0, 8), (item: InspirationItem) => {
                  Row({ space: Theme.space.s3 }) {
                    Text(item.recordDate.slice(5))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textTertiary)
                      .width(48)
                    Text(item.title)
                      .fontSize(Theme.type.callout)
                      .fontColor(Theme.colors().textPrimary)
                      .layoutWeight(1)
                      .maxLines(2)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => { InspirationDetailNav.openInspiration(item.id) })
                }, (item: InspirationItem) => item.id)
              }

              Text('本周反思')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .width('100%')
              TextArea({ text: this.reflection, placeholder: '写下本周创作收获、卡点与下周计划…' })
                .width('100%')
                .height(120)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onChange((v: string) => { this.reflection = v })

              AppButton({
                label: this.saving ? '保存中…' : '保存周回顾',
                disabled: this.saving,
                onTap: (): void => { void this.saveReflection() }
              })
              AppButton({
                label: '复制回顾摘要',
                variant: 'secondary',
                onTap: (): void => { void this.copySummary() }
              })
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
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
