import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InsightAnswerCard } from '../components/ask/InsightAnswerCard'
import { HomeDashboard, HomeDashHelper, HomeRecentActivity } from '../components/home/HomeDashboard'
import { HomePathStrip } from '../components/home/HomePathStrip'
import { HomeHubGrid } from '../components/home/HomeHubGrid'
import { HomeScenarioStrip } from '../components/home/HomeScenarioStrip'
import { HomeTodayMission } from '../components/home/HomeTodayMission'
import { InsightItem } from '../models/AskModels'
import { LearnCatalog } from '../models/LearnModels'
import { AskBizService } from '../services/AskBizService'
import { AskMedia } from '../services/AskMedia'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'
import { LearnStore } from '../services/LearnStore'
import { VaultStore } from '../services/VaultStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '问知'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State question: string = ''
  @State followUp: string = ''
  @State topics: InsightItem[] = []
  @State picks: InsightItem[] = []
  @State answer: InsightItem = new InsightItem()
  @State hasAnswer: boolean = false
  @State loading: boolean = false
  @State toastText: string = ''
  @State collected: boolean = false
  @State category: string = '全部'
  @State dailyGoal: number = 3
  @State todayProgress: number = 0
  @State streakDays: number = 0
  @State askCount: number = 0
  @State quizCount: number = 0
  @State collectCount: number = 0
  @State checkedIn: boolean = false
  @State nick: string = '问知用户'
  @State activityLines: string[] = []
  @State askExpanded: boolean = false
  private cats: string[] = LearnCatalog.categories()

  aboutToAppear(): void {
    this.syncDash()
    void this.loadTopics()
  }

  onRefreshTokenChange(): void {
    this.syncDash()
    if (this.hasAnswer) {
      this.collected = VaultStore.isCollected(this.answer.id)
    }
  }

  private syncDash(): void {
    const s = HomeDashHelper.syncStats()
    this.dailyGoal = s.dailyGoal
    this.todayProgress = s.todayProgress
    this.streakDays = s.streakDays
    this.askCount = s.askCount
    this.quizCount = s.quizCount
    this.collectCount = s.collectCount
    this.checkedIn = s.checkedIn
    this.nick = s.nick
    this.activityLines = HomeDashHelper.formatActivityLines()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private fillTopic(title: string): void {
    this.question = title
  }

  private async sendAsk(): Promise<void> {
    if (this.loading) {
      return
    }
    const q = this.question.trim()
    if (q.length === 0) {
      this.showToast('请先输入你想了解的问题')
      return
    }
    this.loading = true
    try {
      const list = AskBizService.filterCategory(await AskBizService.search(q), this.category)
      const use = list.length > 0 ? list : await AskBizService.search(q)
      if (use.length === 0) {
        this.hasAnswer = false
        this.showToast('解答库暂不可用，请检查网络后重试')
        return
      }
      this.answer = InsightItem.copy(use[0])
      this.hasAnswer = true
      this.collected = VaultStore.isCollected(this.answer.id)
      this.followUp = ''
      await LearnStore.addHistory(q, this.answer)
      await VaultStore.bumpAsk()
      await GrowthStore.logActivity('ask', q, this.answer.id, this.answer.category)
      AskNav.bumpRefresh()
      this.syncDash()
    } catch {
      this.hasAnswer = false
      this.showToast('解答失败，请稍后重试')
    } finally {
      this.loading = false
    }
  }

  private async sendFollow(): Promise<void> {
    const q = this.followUp.trim()
    if (q.length === 0) {
      this.showToast('请输入追问内容')
      return
    }
    this.question = q
    await this.sendAsk()
  }

  private async collectNow(): Promise<void> {
    if (!this.hasAnswer) {
      return
    }
    await VaultStore.collect(this.question, this.answer, this.answer.category, '')
    await GrowthStore.logActivity('collect', this.answer.title, this.answer.id, this.answer.category)
    this.collected = true
    AskNav.bumpRefresh()
    this.syncDash()
    this.showToast('已收入知识库')
  }

  private async handleCheckin(): Promise<void> {
    const ok = await GrowthStore.checkinToday('')
    if (ok) {
      AskNav.bumpRefresh()
      this.syncDash()
      this.showToast('打卡成功，今日进度已更新')
      return
    }
    this.showToast('今日已打卡')
  }

  private openAnswer(): void {
    if (this.hasAnswer) {
      AskNav.openDetail('insight', this.answer.id)
    }
  }

  private openPick(item: InsightItem): void {
    AskNav.openDetail('insight', item.id)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('工作台')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column() {
            AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => { AskNav.openMessages() })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3
        })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_ask'))
                .width('100%')
                .height(148)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(88)
                .linearGradient({
                  direction: GradientDirection.Bottom,
                  colors: [['rgba(11,31,58,0)', 0], ['rgba(11,31,58,0.72)', 1]]
                })
              Column({ space: 4 }) {
                Text('个人知识学习工作台')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                Text('路径 · 复习 · 计划 · 知识库')
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8EDF5')
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)

            Image($r('app.media.banner_insight'))
              .width('100%')
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.card)

            HomeDashboard({
              nick: this.nick,
              dailyGoal: this.dailyGoal,
              todayProgress: this.todayProgress,
              streakDays: this.streakDays,
              askCount: this.askCount,
              quizCount: this.quizCount,
              collectCount: this.collectCount,
              checkedIn: this.checkedIn,
              onCheckin: (): void => { void this.handleCheckin() },
              onOpenPlan: (): void => { AskNav.openLearn('plan') }
            })

            HomeScenarioStrip()

            HomeHubGrid()

            HomeTodayMission({ refreshToken: this.refreshToken })

            HomePathStrip({ refreshToken: this.refreshToken })

            HomeRecentActivity({ events: this.activityLines })

            Row() {
              Text(this.askExpanded ? '收起提问检索' : '展开知识检索提问')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
              Blank()
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { this.askExpanded = !this.askExpanded })

            if (this.askExpanded) {
            Column({ space: Theme.space.s3 }) {
              Text('知识检索提问')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              TextInput({ text: this.question, placeholder: '输入你想了解的问题...' })
                .height(48)
                .fontSize(Theme.type.body)
                .placeholderColor(Theme.colors().textTertiary)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
                .padding({ left: 12, right: 12 })
                .enterKeyType(EnterKeyType.Search)
                .onChange((v: string) => { this.question = v })
                .onSubmit(() => { void this.sendAsk() })
              Row() {
                AppButton({
                  label: this.loading ? '匹配中…' : '智能解答',
                  disabled: this.loading,
                  onTap: (): void => { void this.sendAsk() }
                })
              }
              .width('100%')
              .onClick((): void => { void this.sendAsk() })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .border({ width: 1, color: Theme.colors().strokeHairline })

            if (this.hasAnswer) {
              InsightAnswerCard({
                answer: this.answer,
                collected: this.collected,
                followUp: this.followUp,
                onCollect: (): void => { void this.collectNow() },
                onOpen: (): void => { this.openAnswer() },
                onFollowChange: (v: string) => { this.followUp = v },
                onFollowSend: (): void => { void this.sendFollow() }
              })
            } else {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.cats, (f: string) => {
                    Text(f)
                      .fontSize(Theme.type.footnote)
                      .fontColor(this.category === f ? Theme.colors().brandOnPrimary :
                        (this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary))
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .constraintSize({ minHeight: 40 })
                      .backgroundColor(this.category === f ?
                        Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                      .onClick(() => { this.pickCategory(f) })
                  }, (f: string) => f)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')

              if (this.picks.length > 0) {
                Text('推荐继续学')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.picks, (t: InsightItem) => {
                  Row({ space: Theme.space.s3 }) {
                    Image(AskMedia.resource(t.coverKey))
                      .width(56)
                      .height(56)
                      .borderRadius(Theme.radius.sm)
                      .objectFit(ImageFit.Cover)
                    Column({ space: 4 }) {
                      Text(t.title)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(2)
                      Text(t.category)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.card)
                  .onClick(() => { this.openPick(t) })
                }, (t: InsightItem) => t.id)
              }

              Text('热门问题')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.topics, (t: InsightItem) => {
                  Text(t.title)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .constraintSize({ minHeight: 40 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.fillTopic(t.title) })
                }, (t: InsightItem) => t.id)
              }
              .width('100%')
              if (this.topics.length === 0) {
                AppEmpty({
                  title: '正在连接解答库',
                  description: '热门问题加载后即可点击填入',
                  actionLabel: '重试',
                  onAction: (): void => { void this.loadTopics() }
                })
              }
            }
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10,
            top: Theme.space.s2
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
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
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  private pickCategory(f: string): void {
    this.category = f
    void this.loadTopics()
  }

  private async loadTopics(): Promise<void> {
    const all = await AskBizService.loadTopics()
    this.topics = AskBizService.filterCategory(all, this.category)
    if (this.topics.length === 0) {
      const insights = await AskBizService.loadInsights()
      this.topics = AskBizService.filterCategory(insights, this.category)
    }
    const rec: InsightItem[] = []
    for (let i = 0; i < this.topics.length && i < 3; i++) {
      rec.push(this.topics[i])
    }
    this.picks = rec
  }
}
