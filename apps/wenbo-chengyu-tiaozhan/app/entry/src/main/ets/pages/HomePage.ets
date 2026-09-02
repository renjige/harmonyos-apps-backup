import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppError } from '../components/design-system/AppError'
import { CoverHero } from '../components/idiom/IdiomCards'
import { ChapterItem } from '../models/IdiomModels'
import { IdiomBizService } from '../services/IdiomBizService'
import { IdiomNav } from '../services/IdiomNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State chapters: ChapterItem[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @State errorHint: string = '请检查网络后重试。答题进度仍保存在本机。'
  @State greeting: string = ''
  @State dateLabel: string = ''
  @StorageLink('quizTick') tick: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('dailyDoneFlag') dailyDoneFlag: number = 0
  @StorageLink('dailyScore') dailyScore: number = 0
  @StorageLink('windowIsWide') isWide: boolean = false

  aboutToAppear(): void {
    this.greeting = ProgressStore.greeting()
    this.dateLabel = ProgressStore.dateLabel()
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    try {
      const qs = await IdiomBizService.loadDaily()
      this.chapters = await IdiomBizService.loadChapters()
      this.failed = qs.length === 0
      this.errorHint = IdiomBizService.lastHint()
      AppStorage.setOrCreate('homeQuestionReady', qs.length)
    } catch {
      this.failed = true
      this.errorHint = IdiomBizService.lastHint()
    }
    this.loading = false
  }

  private startDaily(): void {
    void this.launchDaily()
  }

  private async launchDaily(): Promise<void> {
    const list = await IdiomBizService.loadDaily()
    const ids = IdiomBizService.idsOf(list)
    if (ids.length === 0) {
      return
    }
    IdiomNav.openQuiz(ids, 'daily')
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        CoverHero({
          coverKey: 'hero_ink',
          title: '成语挑战',
          subtitle: `${this.dateLabel}  ·  连续打卡 ${this.streakDays} 日`,
          heroHeight: this.isWide ? 260 : 220
        })

        Text(this.greeting)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.failed && !this.loading) {
          AppError({
            title: '题库暂时无法打开',
            message: this.errorHint,
            retryLabel: '重试',
            onRetry: () => { void this.reload() }
          })
        } else {
          Column({ space: 12 }) {
            Text('今日挑战 · 5 题')
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.dailyDoneFlag === 1 ? '今日已完成' : '每题 15 秒 · 连击加成')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.dailyDoneFlag === 1 ?
              `本局得分 ${this.dailyScore}，明日再来续上墨痕。` :
              '答对得 10 分，连续答对分数递增。不登录也可作答。')
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.dailyDoneFlag === 1 ? '再练一轮' : '开始今日挑战',
              onTap: () => this.startDaily()
            })
          }
          .width('100%')
          .padding(20)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(Theme.colors().surfaceGlass)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }

        Text('章节缎带')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.chapters, (ch: ChapterItem) => {
              Column({ space: 6 }) {
                Text(ch.title)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ProgressStore.chapterCleared(ch.chapterIndex) ?
                    Theme.colors().brandAccent : Theme.colors().textPrimary)
                Text(ch.difficulty)
                  .fontSize(11)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width(92)
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({
                width: ProgressStore.chapterCleared(ch.chapterIndex) ? 1.5 : 1,
                color: ProgressStore.chapterCleared(ch.chapterIndex) ?
                  Theme.colors().brandAccent : Theme.colors().strokeHairline
              })
              .onClick(() => IdiomNav.openChapter(ch.id))
            }, (ch: ChapterItem) => ch.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
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
