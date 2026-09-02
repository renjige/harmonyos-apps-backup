import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { CardListCard } from '../components/treasure/TreasureCards'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { TreasureCard, TreasureKpi, TreasureQuestion } from '../models/TreasureModels'
import { TreasureBizService } from '../services/TreasureBizService'
import { TreasureMedia } from '../services/TreasureMedia'
import { TreasureNav } from '../services/TreasureNav'
import { VaultStore } from '../services/VaultStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '知识探宝'
  @State cards: TreasureCard[] = []
  @State questions: TreasureQuestion[] = []
  @State kpis: TreasureKpi[] = []
  @State todayCard: TreasureCard = new TreasureCard()
  @State loading: boolean = true
  @State failed: boolean = false
  @State greeting: string = ''
  @StorageLink('treasureTick') tick: number = 0
  @StorageLink('vaultTotalPoints') totalPoints: number = 0
  @StorageLink('vaultStreak') streakDays: number = 0
  @StorageLink('vaultTodayCount') todayCount: number = 0
  @StorageLink('vaultWeekPoints') weekPoints: number = 0

  aboutToAppear(): void {
    this.greeting = VaultStore.greeting()
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    const cardList = await TreasureBizService.loadCards()
    const questionList = await TreasureBizService.loadQuestions('', true)
    const kpiData = await TreasureBizService.loadKpis()
    this.cards = cardList
    this.questions = questionList.length > 0 ? questionList : await TreasureBizService.loadQuestions()
    this.kpis = kpiData.list
    this.todayCard = TreasureBizService.pickTodayCard(cardList)
    this.loading = false
    this.failed = cardList.length === 0 && this.questions.length === 0
  }

  private startDailyQuiz(): void {
    const ids = TreasureBizService.dailyQuestionIds(this.questions, 5)
    if (ids.length === 0) {
      return
    }
    TreasureNav.openQuiz(ids, 0)
  }

  private dateLabel(): string {
    const d = new Date()
    const wdays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${d.getMonth() + 1}月${d.getDate()}日 · 周${wdays[d.getDay()]}`
  }

  private weekProgress(): number {
    const n = this.streakDays
    if (n >= 7) {
      return 7
    }
    if (n <= 0 && this.todayCount > 0) {
      return 1
    }
    return n
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Row({ space: Theme.space.s3 }) {
            Image($r('app.media.app_logo'))
              .width(44)
              .height(44)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
            Column({ space: 4 }) {
              Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.dateLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
              .fontWeight(FontWeight.Medium)
            Text(this.greeting)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .layoutWeight(1)
          Column() {
            AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { TreasureNav.openMessages() })
        }
        .width('100%')

        if (this.failed && !this.loading) {
          AppError({
            title: '暂时无法加载内容',
            message: '请检查网络后重试。',
            retryLabel: '重试',
            onRetry: (): void => { void this.reload() }
          })
        } else if (this.loading) {
          Text('正在加载今日智慧…')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else {
          this.WeekProgressBar()
          this.TodayCardBlock()
          this.StatsRow()
          this.QuizBlock()
          this.CardSwiper()
          this.FeaturedCards()
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  WeekProgressBar() {
    Column({ space: 8 }) {
      Row() {
        Text('本周探宝进度')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .layoutWeight(1)
        Text(`${this.weekProgress()}/7 天`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      Row({ space: 6 }) {
        ForEach([0, 1, 2, 3, 4, 5, 6], (i: number) => {
          Column()
            .layoutWeight(1)
            .height(6)
            .borderRadius(Theme.radius.pill)
            .backgroundColor(i < this.weekProgress() ?
              Theme.colors().brandAccent : Theme.colors().surfaceSubtle)
        }, (i: number) => `${i}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  TodayCardBlock() {
    if (this.todayCard.id.length === 0) {
      AppEmpty({ title: '今日卡片准备中', description: '稍后再来看看' })
    } else {
      Column() {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(TreasureMedia.resource(this.todayCard.coverKey.length > 0 ?
            this.todayCard.coverKey : this.todayCard.category))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(180)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,42,108,0.08)', 0.2], ['rgba(26,42,108,0.82)', 1]]
            })
          Column({ space: 6 }) {
            Text(`✦ 今日智慧`)
              .fontSize(Theme.type.caption)
              .fontColor('#F5F3F0')
            Text(CategoryEmojiUtil.tagline(this.todayCard.category, this.todayCard.categoryLabel))
              .fontSize(Theme.type.caption)
              .fontColor('#E8D9A8')
            Text(this.todayCard.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F5F3F0')
              .maxLines(2)
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
        }
        .width('100%')
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        .clip(true)
        .onClick((): void => { TreasureNav.openCard(this.todayCard.id) })

        Column({ space: Theme.space.s3 }) {
          Text(this.todayCard.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(24)
            .width('100%')
            .maxLines(3)
          AppButton({
            label: '阅读全文',
            variant: 'secondary',
            onTap: (): void => { TreasureNav.openCard(this.todayCard.id) }
          })
        }
        .padding(Theme.space.s4)
      }
      .width('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .clip(true)
      .shadow({ radius: 20, color: 'rgba(26,42,108,0.14)', offsetY: 6, offsetX: 0 })
    }
  }

  @Builder
  CardSwiper() {
    if (this.cards.length > 1) {
      Column({ space: Theme.space.s3 }) {
        Text('滑动浏览往期智慧')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Swiper() {
          ForEach(this.cards.slice(0, 7), (c: TreasureCard) => {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(TreasureMedia.resource(c.coverKey.length > 0 ? c.coverKey : c.category))
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(140)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,42,108,0.05)', 0.3], ['rgba(26,42,108,0.85)', 1]]
                })
              Column({ space: 4 }) {
                Text(CategoryEmojiUtil.tagline(c.category, c.categoryLabel))
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8D9A8')
                Text(c.title)
                  .fontSize(Theme.type.subtitleL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .padding({ left: 16, right: 16, bottom: 14 })
            }
            .width('100%')
            .height(140)
            .borderRadius(Theme.radius.xl)
            .clip(true)
            .onClick((): void => { TreasureNav.openCard(c.id) })
          }, (c: TreasureCard) => c.id)
        }
        .width('100%')
        .height(148)
        .indicator(true)
        .loop(false)
        .curve(Curve.EaseOut)
      }
      .width('100%')
    }
  }

  @Builder
  StatsRow() {
    Row({ space: Theme.space.s3 }) {
      AppStatCard({
        label: '智慧积分',
        value: `${this.totalPoints}`,
        trend: `本周 +${this.weekPoints}`,
        positive: true
      }).layoutWeight(1)
      AppStatCard({
        label: '连续探宝',
        value: `${this.streakDays} 天`,
        trend: '坚持有回报',
        positive: true
      }).layoutWeight(1)
    }
    .width('100%')
    if (this.kpis.length > 0) {
      Row({ space: Theme.space.s3 }) {
        ForEach(this.kpis.slice(0, 2), (k: TreasureKpi) => {
          AppStatCard({
            label: k.label,
            value: k.value,
            trend: k.trend,
            positive: k.positive
          }).layoutWeight(1)
        }, (k: TreasureKpi) => k.label)
      }
      .width('100%')
    }
  }

  @Builder
  QuizBlock() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.hero_treasure'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.22)
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(232,234,244,0.92)')
      Column({ space: Theme.space.s3 }) {
        Text('每日智慧闯关')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandDeep)
          .width('100%')
        Text(`今日进度 ${this.todayCount}/5 · 每题 +${TreasureBizService.pointsPerQuestion()} 积分`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: '开始今日 5 题闯关',
          onTap: (): void => { this.startDailyQuiz() }
        })
      }
      .padding(Theme.space.s4)
      .width('100%')
    }
    .width('100%')
    .height(148)
    .borderRadius(Theme.radius.xl)
    .clip(true)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  FeaturedCards() {
    Text('精选智慧卡片')
      .fontSize(Theme.type.subtitleL)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
    Column({ space: Theme.space.s3 }) {
      ForEach(this.cards.slice(0, 4), (c: TreasureCard) => {
        CardListCard({
          categoryLabel: c.categoryLabel,
          category: c.category,
          title: c.title,
          summary: c.summary,
          cover: TreasureMedia.resource(c.coverKey.length > 0 ? c.coverKey : c.category),
          onOpen: (): void => { TreasureNav.openCard(c.id) }
        })
      }, (c: TreasureCard) => c.id)
    }
    .width('100%')
  }
}
