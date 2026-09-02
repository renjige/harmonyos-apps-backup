import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InsightItem } from '../models/AskModels'
import { LearningPath } from '../models/PathModels'
import { LearnCatalog } from '../models/LearnModels'
import { AskBizService } from '../services/AskBizService'
import { AskMedia } from '../services/AskMedia'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'
import { LearnStore } from '../services/LearnStore'
import { PathStore } from '../services/PathStore'
import { HomeCompactTile } from '../components/home/HomeCompactTile'

class StudyTopic {
  key: string = ''
  title: string = ''
  coverKey: string = ''
}

class StudyTool {
  title: string = ''
  sub: string = ''
  icon: string = 'chart'
  action: string = ''
}

@Component
export struct StudyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State keyword: string = ''
  @State hotItems: InsightItem[] = []
  @State paths: LearningPath[] = []
  @State wrongCount: number = 0
  @State cardCount: number = 0
  @State taskPending: number = 0
  @State unlocked: number = 0
  @State checkedIn: boolean = false
  private topics: StudyTopic[] = StudyPage.topicRows()
  private tools: StudyTool[] = StudyPage.toolRows()
  private cats: string[] = LearnCatalog.folders()

  aboutToAppear(): void {
    void this.load()
  }

  onRefreshTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    await PathStore.ensureReady()
    this.paths = PathStore.all()
    const all = await AskBizService.loadInsights()
    const hot: InsightItem[] = []
    for (let i = 0; i < all.length && i < 6; i++) {
      hot.push(all[i])
    }
    this.hotItems = hot
    this.wrongCount = LearnStore.wrongAll().length
    this.cardCount = LearnStore.cardAll().length
    this.unlocked = GrowthStore.achievementUnlockedCount()
    this.checkedIn = GrowthStore.hasCheckinToday()
    let pending = 0
    for (const t of GrowthStore.weekTasks()) {
      if (!t.done) {
        pending += 1
      }
    }
    this.taskPending = pending
  }

  private static topicRows(): StudyTopic[] {
    const rows: StudyTopic[] = []
    const defs: string[][] = [
      ['历史专题', 'cover_history'],
      ['科学专题', 'cover_tech'],
      ['生活技巧专题', 'cover_life'],
      ['文化专题', 'cover_study']
    ]
    for (const d of defs) {
      const row = new StudyTopic()
      row.key = d[0]
      row.title = d[0]
      row.coverKey = d[1]
      rows.push(row)
    }
    return rows
  }

  private static toolIcon(key: string): AppIconName {
    if (key === 'book') {
      return 'book'
    }
    if (key === 'alert') {
      return 'alert'
    }
    if (key === 'message') {
      return 'message'
    }
    if (key === 'biz') {
      return 'biz'
    }
    if (key === 'bookmark') {
      return 'bookmark'
    }
    if (key === 'check') {
      return 'check'
    }
    return 'chart'
  }

  private static toolRows(): StudyTool[] {
    const rows: StudyTool[] = []
    const defs: string[][] = [
      ['闪卡复习', '卡片+错题巩固', 'bookmark', 'flashcards'],
      ['学习日历', '14 日热力图', 'biz', 'calendar'],
      ['快速挑战', '5 题热身', 'chart', 'challenge5'],
      ['进阶挑战', '10 题巩固', 'chart', 'challenge10'],
      ['错题再练', '专攻薄弱点', 'alert', 'wrong'],
      ['学习计划', '目标与打卡', 'check', 'plan'],
      ['学习动态', '时间轴回顾', 'message', 'timeline'],
      ['我的笔记', '自建知识沉淀', 'book', 'notes']
    ]
    for (const d of defs) {
      const row = new StudyTool()
      row.title = d[0]
      row.sub = d[1]
      row.icon = d[2]
      row.action = d[3]
      rows.push(row)
    }
    return rows
  }

  private openTool(action: string): void {
    if (action === 'flashcards') {
      AskNav.openLearn('flashcards')
      return
    }
    if (action === 'calendar') {
      AskNav.openLearn('calendar')
      return
    }
    if (action === 'challenge5') {
      AskNav.openChallenge(5)
      return
    }
    if (action === 'challenge10') {
      AskNav.openChallenge(10)
      return
    }
    if (action === 'wrong') {
      AskNav.openLearn('wrong')
      return
    }
    if (action === 'plan') {
      AskNav.openLearn('plan')
      return
    }
    if (action === 'timeline') {
      AskNav.openLearn('timeline')
      return
    }
    AskNav.openLearn('notes')
  }

  private async checkin(): Promise<void> {
    const ok = await GrowthStore.checkinToday('')
    if (ok) {
      AskNav.bumpRefresh()
      await this.load()
    }
  }

  build() {
    Column() {
      Row() {
        Text('学习')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
        Text(`今日 ${LearnStore.todayCount()}/${LearnStore.goal()}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s2
      })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s3 }) {
            Text('今日学习清单')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Progress({
              value: LearnStore.todayCount(),
              total: LearnStore.goal() > 0 ? LearnStore.goal() : 1,
              type: ProgressType.Linear
            })
              .width('100%')
              .color(Theme.colors().brandPrimary)
            Row() {
              Text(`待完成任务 ${this.taskPending} · 错题 ${this.wrongCount} · 卡片 ${this.cardCount}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .layoutWeight(1)
            }
            .width('100%')
            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: this.checkedIn ? '已打卡' : '学习打卡',
                variant: this.checkedIn ? 'secondary' : 'primary',
                onTap: (): void => { void this.checkin() }
              })
                .layoutWeight(1)
              AppButton({
                label: '本周计划',
                variant: 'secondary',
                onTap: (): void => { AskNav.openLearn('plan') }
              })
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.card)

          Text('结构化学习路径')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          if (this.paths.length === 0) {
            AppEmpty({
              title: '路径加载中',
              description: '联网后将按专题生成章节',
              actionLabel: '重试',
              onAction: (): void => { void this.load() }
            })
          } else {
            ForEach(this.paths, (path: LearningPath) => {
              Row({ space: Theme.space.s3 }) {
                Image(AskMedia.resource(path.coverKey))
                  .width(72)
                  .height(72)
                  .borderRadius(Theme.radius.sm)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(path.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                    .maxLines(1)
                  Text(path.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                    .maxLines(2)
                  Text(`${path.doneCount()}/${path.totalCount()} 节 · ${path.progressPercent()}%`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick((): void => { AskNav.openPath(path.id) })
            }, (path: LearningPath) => path.id)
          }

          TextInput({ text: this.keyword, placeholder: '搜索知识库、关键词或分类' })
            .height(48)
            .fontSize(Theme.type.body)
            .placeholderColor(Theme.colorOf(this.themeEpoch).textTertiary)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.sm)
            .padding({ left: 12, right: 12 })
            .onChange((v: string) => { this.keyword = v })
            .onSubmit(() => {
              AppStorage.setOrCreate('catalogKeyword', this.keyword)
              AskNav.openLearn('catalog')
            })

          Text('专题速览')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          Grid() {
            ForEach(this.topics, (t: StudyTopic) => {
              GridItem() {
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image(AskMedia.resource(t.coverKey))
                    .width('100%')
                    .height(88)
                    .objectFit(ImageFit.Cover)
                  Column()
                    .width('100%')
                    .height(48)
                    .linearGradient({
                      direction: GradientDirection.Bottom,
                      colors: [['rgba(11,31,58,0)', 0], ['rgba(11,31,58,0.75)', 1]]
                    })
                  Text(t.title)
                    .fontSize(Theme.type.footnote)
                    .fontColor('#FFFFFF')
                    .padding(8)
                }
                .width('100%')
                .borderRadius(Theme.radius.card)
                .clip(true)
                .onClick((): void => {
                  AppStorage.setOrCreate('catalogTopic', t.key)
                  AskNav.openLearn('topics')
                })
              }
            }, (t: StudyTopic) => t.key)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(Theme.space.s3)
          .rowsGap(Theme.space.s3)
          .width('100%')

          Text('分类百科')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.cats, (f: string) => {
                Text(f)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .constraintSize({ minHeight: 40 })
                  .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    AppStorage.setOrCreate('catalogCategory', f)
                    AskNav.openLearn('catalog')
                  })
              }, (f: string) => f)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          Row() {
            Text('练习与工具')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            Blank()
            Text(`成就 ${this.unlocked}/10`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          }
          .width('100%')

          Grid() {
            ForEach(this.tools, (tool: StudyTool) => {
              GridItem() {
                HomeCompactTile({
                  title: tool.title,
                  sub: tool.sub,
                  icon: StudyPage.toolIcon(tool.icon),
                  onTap: (): void => { this.openTool(tool.action) }
                })
              }
            }, (tool: StudyTool) => tool.action)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(Theme.space.s2)
          .rowsGap(Theme.space.s2)
          .width('100%')

          Text('精选解答')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          ForEach(this.hotItems, (item: InsightItem) => {
            Row({ space: Theme.space.s3 }) {
              Image(AskMedia.resource(item.coverKey))
                .width(56)
                .height(56)
                .borderRadius(Theme.radius.sm)
                .objectFit(ImageFit.Cover)
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .maxLines(2)
                Text(item.category)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { AskNav.openDetail('insight', item.id) })
          }, (item: InsightItem) => item.id)
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
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }
}
