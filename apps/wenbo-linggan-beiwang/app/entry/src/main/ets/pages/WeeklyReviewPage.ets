import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationItem } from '../models/InspirationModels'
import { WeeklyReviewReport } from '../models/WorkbenchModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { WeeklyReviewService } from '../services/WeeklyReviewService'
import { InspirationMedia } from '../services/InspirationMedia'
import { AuthService } from '../services/AuthService'
import { DailyPromptService } from '../services/DailyPromptService'

@Component
export struct WeeklyReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onUsePrompt: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State period: string = 'week'
  @State report: WeeklyReviewReport = new WeeklyReviewReport()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.report = WeeklyReviewService.build([], [], [])
      this.loading = false
      return
    }
    const ins = await InspirationBizService.loadInspirations(this.currentUsername)
    const fav = await InspirationBizService.loadFavorites(this.currentUsername)
    const boards = await InspirationBizService.loadMoodBoards(this.currentUsername)
    this.report = WeeklyReviewService.build(ins, fav, boards, this.period)
    this.loading = false
  }

  private pickPeriod(p: string): void {
    this.period = p
    void this.reload()
  }

  private handleUsePrompt(): void {
    DailyPromptService.applyToCapture()
    this.onUsePrompt()
  }

  build() {
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
        Text('捕捉回顾')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Row({ space: Theme.space.s2 }) {
        Text('今日')
          .fontSize(Theme.type.caption)
          .fontColor(this.period === 'today' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.period === 'today' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.pickPeriod('today') })
        Text('本周')
          .fontSize(Theme.type.caption)
          .fontColor(this.period === 'week' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.period === 'week' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.pickPeriod('week') })
        Text('本月')
          .fontSize(Theme.type.caption)
          .fontColor(this.period === 'month' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.period === 'month' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.pickPeriod('month') })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '汇总本周记录…' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(InspirationMedia.coverMedia('hero_latest_inspiration'))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column()
                .width('100%')
                .height(160)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(51,65,85,0.12)', 0], ['rgba(51,65,85,0.82)', 1]]
                })
                .borderRadius(Theme.radius.xl)
              Column({ space: 4 }) {
                Text(this.report.weekLabel)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandAccent)
                Text('按你的记录生成的周报')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textOnInverse)
              }
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              this.StatCell('本周捕捉', `${this.report.captureCount}`)
              this.StatCell('收藏', `${this.report.favoriteCount}`)
              this.StatCell('画板', `${this.report.boardCount}`)
            }
            .width('100%')

            Text(this.report.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)

            this.NoteBlock('捕捉', this.report.captureNote)
            this.NoteBlock('整理', this.report.organizeNote)
            this.NoteBlock('收藏', this.report.collectNote)

            Text('下一步')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`1. ${this.report.nextAction1}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text(`2. ${this.report.nextAction2}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text(`3. ${this.report.nextAction3}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')

            if (!AuthService.isLoggedIn()) {
              AppEmpty({
                title: '登录后生成你的周报',
                description: '复盘只统计你账号下的灵感、收藏与画板',
                actionLabel: '去登录',
                onAction: (): void => { this.onRequireAuth() }
              })
            }

            AppButton({
              label: '用今日提示去记录',
              onTap: (): void => { this.handleUsePrompt() }
            })
            AppButton({
              label: '打开整理',
              variant: 'secondary',
              onTap: (): void => { this.onOpenOrganize() }
            })
            Text(`生成时间 ${this.report.generatedAt}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
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
  }

  @Builder
  StatCell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  NoteBlock(title: string, body: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(body)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .lineHeight(22)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
  }
}
