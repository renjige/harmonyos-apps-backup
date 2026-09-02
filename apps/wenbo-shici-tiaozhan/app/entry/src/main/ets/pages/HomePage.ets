import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppError } from '../components/design-system/AppError'
import { AppIcon } from '../components/design-system/AppIcon'
import { CoverHero, EntryCard } from '../components/poetry/PoetryCards'
import { KpiItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryNav } from '../services/PoetryNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State loading: boolean = true
  @State failed: boolean = false
  @State errorHint: string = ''
  @State greeting: string = ''
  @State dateLabel: string = ''
  @State kpis: KpiItem[] = []
  @StorageLink('poetryTick') tick: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('dailyDoneFlag') dailyDoneFlag: number = 0
  @StorageLink('dailyScore') dailyScore: number = 0
  @StorageLink('windowIsWide') isWide: boolean = false
  onOpenMine: () => void = () => {}
  onOpenLibrary: () => void = () => {}

  aboutToAppear(): void {
    this.greeting = ProgressStore.greeting()
    this.dateLabel = ProgressStore.dateLabel()
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    const qs = await PoetryBizService.loadDailyQuestions()
    this.kpis = await PoetryBizService.loadKpis()
    this.failed = qs.length === 0
    this.errorHint = PoetryBizService.lastHint()
    this.loading = false
  }

  private async startDaily(): Promise<void> {
    const list = await PoetryBizService.loadDailyQuestions()
    const ids = PoetryBizService.idsOf(list, 5)
    if (ids.length === 0) {
      return
    }
    PoetryNav.openQuiz(ids)
  }

  private openFeihuaPicker(): void {
    PoetryNav.openFeihuaPicker()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Column({ space: 2 }) {
            Text('诗词挑战')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.greeting)
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          if (this.streakDays > 0) {
            Text(`连击 ${this.streakDays} 日`)
              .fontSize(12)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .margin({ right: 8 })
          }
          Column() {
            AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.onOpenMine())
        }
        .width('100%')

        CoverHero({
          coverKey: 'hero_ink',
          title: '墨韵米白 · 朱砂点睛',
          subtitle: `${this.dateLabel}  ·  连续打卡 ${this.streakDays} 日`,
          heroHeight: this.isWide ? 260 : 220
        })

        if (this.failed && !this.loading) {
          AppError({
            title: '题库暂时无法打开',
            message: this.errorHint,
            retryLabel: '重试',
            onRetry: (): void => { void this.reload() }
          })
        } else {
          Column({ space: 12 }) {
            Text('今日挑战 · 5 题')
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.dailyDoneFlag === 1 ? '今日已完成' : '选择 / 填空 / 配对 / 排序')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.dailyDoneFlag === 1 ?
              `本局得分 ${this.dailyScore}，明日再来续上诗痕。` :
              '每题 15 秒 · 连击加分 · 不登录也可作答')
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.dailyDoneFlag === 1 ? '再练一轮' : '开始今日挑战',
              onTap: (): void => { void this.startDaily() }
            })
          }
          .width('100%')
          .padding(20)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(Theme.colors().surfaceGlass)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }

        EntryCard({
          title: '飞花令接龙',
          summary: '十二关键字 · 入门或进阶 · 对照参考句接龙',
          coverKey: 'cover_moon',
          badge: '接龙',
          onTap: (): void => this.openFeihuaPicker()
        })

        EntryCard({
          title: '诗词图鉴',
          summary: '按朝代作者题材浏览 · 注释译文赏析 · 收藏到诗库',
          coverKey: 'cover_scroll',
          badge: `${ProgressStore.favoriteCount()} 收藏`,
          onTap: (): void => this.onOpenLibrary()
        })

        if (this.kpis.length > 0) {
          Text('诗卷概览')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: 10 }) {
            ForEach(this.kpis.slice(0, 3), (k: KpiItem) => {
              Column({ space: 4 }) {
                Text(k.label)
                  .fontSize(12)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                Text(`${k.value}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .layoutWeight(1)
              .padding(14)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .alignItems(HorizontalAlign.Start)
            }, (k: KpiItem) => k.key.length > 0 ? k.key : k.label)
          }
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
