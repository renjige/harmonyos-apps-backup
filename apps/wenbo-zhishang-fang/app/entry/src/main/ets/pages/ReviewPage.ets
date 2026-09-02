import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { NoteListCard } from '../components/note/NoteListCard'
import { BookNote, MonthlyReadingReport, ReadingInsight, TagCloudItem, TimelineItem, WeekDayStat } from '../models/BookNoteModels'
import { NoteStore } from '../services/NoteStore'
import { ReviewStatBar } from '../components/note/ReviewStatBar'
import { RecallDrillPane } from '../components/note/RecallDrillPane'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('noteEpoch') @Watch('onNoteEpochChange') noteEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @Prop @Watch('onActiveChange') active: boolean = false
  @State wisdom: BookNote = new BookNote()
  @State hasWisdom: boolean = false
  @State favorites: BookNote[] = []
  @State cloud: TagCloudItem[] = []
  @State insight: ReadingInsight = new ReadingInsight()
  @State monthly: MonthlyReadingReport = new MonthlyReadingReport()
  @State timeline: TimelineItem[] = []
  @State filterTag: string = ''
  @State filtered: BookNote[] = []
  @State showDrill: boolean = false
  onOpenDetail: (id: string) => void = (_id: string) => {}
  onGoCapture: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  onOpenStats: () => void = () => {}
  onOpenAchievements: () => void = () => {}
  onOpenWeekly: () => void = () => {}
  onOpenPlans: () => void = () => {}
  onOpenDiagnosis: () => void = () => {}
  onOpenTimer: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onNoteEpochChange(): void {
    void this.load()
  }

  onActiveChange(): void {
    if (this.active) {
      void this.load()
    }
  }

  private async load(): Promise<void> {
    this.insight = await NoteStore.readingInsight()
    this.monthly = await NoteStore.monthlyReport()
    this.timeline = await NoteStore.recentTimeline(8)
    const one = await NoteStore.todayWisdom()
    if (one !== undefined) {
      this.wisdom = one
      this.hasWisdom = true
    } else {
      this.hasWisdom = false
    }
    this.favorites = await NoteStore.loadFavorites()
    this.cloud = await NoteStore.tagCloud()
    if (this.filterTag.length > 0) {
      this.filtered = await NoteStore.byTag(this.filterTag)
    } else {
      this.filtered = []
    }
  }

  private async pickTag(name: string): Promise<void> {
    if (this.filterTag === name) {
      this.filterTag = ''
      this.filtered = []
      return
    }
    this.filterTag = name
    this.filtered = await NoteStore.byTag(name)
  }

  private goalPercent(): number {
    if (this.monthly.goalTarget <= 0) {
      return 0
    }
    const p = Math.floor((this.monthly.goalProgress * 100) / this.monthly.goalTarget)
    if (p > 100) {
      return 100
    }
    return p
  }

  private async bumpGoal(): Promise<void> {
    const next = this.monthly.goalTarget + 5
    await NoteStore.saveMonthlyGoal(next)
    this.monthly = await NoteStore.monthlyReport()
  }

  private goalLeftWeight(): number {
    const p = this.goalPercent()
    return p <= 0 ? 1 : p
  }

  private goalRightWeight(): number {
    const p = this.goalPercent()
    if (p >= 100) {
      return 1
    }
    return 100 - p
  }

  build() {
    Stack() {
      Column() {
      Text('成长')
        .fontSize(Theme.type.titleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s2
        })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_today'))
              .width('100%')
              .height(168)
              .objectFit(ImageFit.Cover)
            Column() {
              Blank()
              Column({ space: 6 }) {
                Text('今日智慧')
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                if (this.hasWisdom) {
                  Text(this.wisdom.bookName)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                    .maxLines(1)
                  Text(this.wisdom.excerptPreview())
                    .fontSize(Theme.type.bodyS)
                    .fontColor('#FFFFFF')
                    .maxLines(3)
                } else {
                  Text('收藏一条书摘，明天在这里重逢')
                    .fontSize(Theme.type.bodyS)
                    .fontColor('#FFFFFF')
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(44,62,107,0.15)', 0], ['rgba(26,39,68,0.88)', 1]]
              })
            }
            .width('100%')
            .height(168)
          }
          .width('100%')
          .height(168)
          .borderRadius(Theme.radius.md)
          .clip(true)
          .onClick((): void => {
            if (this.hasWisdom) {
              this.onOpenDetail(this.wisdom.id)
            }
          })

          ReviewStatBar()

          Row({ space: 8 }) {
            this.GrowthLink('本周回顾', (): void => { this.onOpenWeekly() })
            this.GrowthLink('成就墙', (): void => { this.onOpenAchievements() })
          }
          .width('100%')
          Row({ space: 8 }) {
            this.GrowthLink('完整时间轴', (): void => { this.onOpenTimeline() })
            this.GrowthLink('数据统计', (): void => { this.onOpenStats() })
          }
          .width('100%')
          Row({ space: 8 }) {
            this.GrowthLink('阅读诊断', (): void => { this.onOpenDiagnosis() })
            this.GrowthLink('专注阅读', (): void => { this.onOpenTimer() })
          }
          .width('100%')
          Text('阅读计划')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
            .textAlign(TextAlign.End)
            .onClick((): void => { this.onOpenPlans() })

          Column({ space: Theme.space.s3 }) {
            Text(`${this.monthly.monthLabel}阅读报告`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Row({ space: 8 }) {
              this.InsightChip('新增摘录', `${this.monthly.newNotes} 条`)
              this.InsightChip('复习次数', `${this.monthly.recallTotal} 次`)
              this.InsightChip('常读书', this.monthly.topBook.length > 0 ?
                this.monthly.topBook : '待记录')
            }
            .width('100%')
            Row({ space: 8 }) {
              Text(`阅读目标 ${this.monthly.goalProgress}/${this.monthly.goalTarget} 条`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .layoutWeight(1)
              Text('提高目标')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { void this.bumpGoal() })
            }
            .width('100%')
            Row() {
              Column()
                .layoutWeight(this.goalLeftWeight())
                .height(8)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius({ topLeft: 4, bottomLeft: 4 })
              Column()
                .layoutWeight(this.goalRightWeight())
                .height(8)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius({ topRight: 4, bottomRight: 4 })
            }
            .width('100%')
            .borderRadius(4)
            .clip(true)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)

          Text('抽卡回顾')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('先看摘录，再回想出自哪本书。记住或标为再看，形成主动复习闭环。')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text('开始抽卡')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(24)
            .onClick((): void => {
              this.showDrill = true
              AppStorage.setOrCreate('tabBarHidden', true)
            })

          Column({ space: Theme.space.s3 }) {
            Text('阅读足迹')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Row({ space: 8 }) {
              this.InsightChip('近7日', `${this.insight.weekTotal} 条`)
              this.InsightChip('连续摘录', `${this.insight.streakDays} 天`)
              this.InsightChip('常读分类', this.insight.topTag.length > 0 ?
                CategoryEmojiUtil.chipLabel(this.insight.topTag) : '待标注')
            }
            .width('100%')
            Row({ space: 6 }) {
              ForEach(this.insight.weekDays, (d: WeekDayStat) => {
                Column({ space: 4 }) {
                  Column()
                    .width(28)
                    .height(Math.max(8, d.count * 14))
                    .backgroundColor(d.count > 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(4)
                  Text(d.label)
                    .fontSize(Theme.type.overline)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }, (d: WeekDayStat) => d.label)
            }
            .width('100%')
            .height(72)
            .alignItems(VerticalAlign.Bottom)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)

          if (this.timeline.length > 0) {
            Text('摘录时间线')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.timeline, (row: TimelineItem) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(row.dateLabel)
                    .fontSize(Theme.type.overline)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  Column()
                    .width(2)
                    .height(28)
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                }
                .alignItems(HorizontalAlign.Center)
                Column({ space: 4 }) {
                  Text(row.bookName)
                    .fontSize(Theme.type.bodyS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                    .width('100%')
                  Text(row.excerptPreview)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                  Text(row.tagLabel)
                    .fontSize(Theme.type.overline)
                    .fontColor(Theme.colors().brandPrimary)
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { this.onOpenDetail(row.id) })
            }, (row: TimelineItem) => `${row.id}_${row.dateLabel}`)
          }

          Text('智慧标签云')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.cloud.length === 0) {
            Text('写下书摘并打上分类后，这里会聚成标签云')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cloud, (t: TagCloudItem) => {
                Text(CategoryEmojiUtil.chipLabel(t.name))
                  .fontSize(t.fontSize)
                  .fontColor(this.filterTag === t.name ? '#FFFFFF' : Theme.colors().brandAccent)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.filterTag === t.name ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.pickTag(t.name) })
              }, (t: TagCloudItem) => t.name)
            }
            .width('100%')
          }

          if (this.filterTag.length > 0) {
            Text(`分类 · ${this.filterTag}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.filtered.length === 0) {
              AppEmpty({ title: '该分类还没有书摘', description: '换一个标签，或去添加一条' })
            } else {
              ForEach(this.filtered, (it: BookNote) => {
                NoteListCard({
                  item: it,
                  onOpen: (): void => { this.onOpenDetail(it.id) }
                })
              }, (it: BookNote) => `f_${it.id}_${it.updatedAt}_${it.tags.join('|')}`)
            }
          }

          Text('我的收藏')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.favorites.length === 0) {
            AppEmpty({
              title: '还没有收藏',
              description: '在书房左滑或详情页收藏，今日智慧会从这里抽取',
              actionLabel: '去添加',
              onAction: (): void => { this.onGoCapture() }
            })
          } else {
            ForEach(this.favorites, (it: BookNote) => {
              NoteListCard({
                item: it,
                onOpen: (): void => { this.onOpenDetail(it.id) }
              })
            }, (it: BookNote) => `fav_${it.id}_${it.updatedAt}_${it.tags.join('|')}`)
          }
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showDrill) {
        RecallDrillPane({
          onClose: (): void => {
            this.showDrill = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onOpenDetail: (id: string): void => {
            this.showDrill = false
            AppStorage.setOrCreate('tabBarHidden', false)
            this.onOpenDetail(id)
          }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  GrowthLink(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontWeight(FontWeight.Medium)
      .fontColor(Theme.colors().brandPrimary)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding({ top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { onTap() })
  }

  @Builder
  InsightChip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(label)
        .fontSize(Theme.type.overline)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10, left: 6, right: 6 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
    .borderRadius(10)
    .alignItems(HorizontalAlign.Center)
  }
}
