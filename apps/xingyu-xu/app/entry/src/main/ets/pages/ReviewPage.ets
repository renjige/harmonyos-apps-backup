import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { TimelineEvent, YearbookData, ArchiveStats, Narrative } from '../models/XingyuModels'
import { XingyuStats } from '../services/XingyuStats'
import { XingyuNav } from '../services/XingyuNav'
import { XingyuMedia } from '../services/XingyuMedia'
import { DateHelper } from '../services/DateHelper'

@Component
export struct ReviewPage {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State tab: string = 'rail'
  @State events: TimelineEvent[] = []
  @State year: YearbookData = new YearbookData()
  @State stats: ArchiveStats = new ArchiveStats()
  @State recall: Narrative = new Narrative()

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.events = await XingyuStats.timeline()
    this.year = await XingyuStats.yearbook(DateHelper.currentYear())
    this.stats = await XingyuStats.snapshot()
    const rec = await XingyuStats.recallToday()
    this.recall = rec !== undefined ? rec : new Narrative()
  }

  private openEvent(e: TimelineEvent): void {
    if (e.kind === 'narrative') {
      XingyuNav.openNarrative(e.targetId)
    } else if (e.kind === 'spark') {
      XingyuNav.openSpark(e.targetId)
    } else {
      XingyuNav.openTheme(e.targetId)
    }
  }

  private kindLabel(kind: string): string {
    if (kind === 'spark') {
      return '灵感'
    }
    if (kind === 'theme') {
      return '主题'
    }
    return '叙事'
  }

  @Builder
  tabChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.tab === key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .margin({ right: 8 })
      .backgroundColor(this.tab === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.tab = key
      })
  }

  build() {
    Column() {
      AppHeader({ title: '回望', subtitle: '时间长廊与成长档案' })
      Row() {
        this.tabChip('星轨', 'rail')
        this.tabChip('智慧回望', 'recall')
        this.tabChip('年册', 'year')
        this.tabChip('数据', 'stats')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.tab === 'rail') {
            if (this.events.length === 0) {
              AppEmpty({
                title: '星轨尚未点亮',
                description: '留下叙事、灵感或主题后，这里会按时间展开。',
                actionLabel: '去写下',
                onAction: () => XingyuNav.openEditor('narrative', '')
              })
            }
            ForEach(this.events, (e: TimelineEvent) => {
              Row({ space: Theme.space.s3 }) {
                Column()
                  .width(8)
                  .height(8)
                  .borderRadius(4)
                  .backgroundColor(Theme.colors().brandAccent)
                  .margin({ top: 6 })
                Column({ space: 4 }) {
                  Text(`${DateHelper.displayDate(e.dateKey)} · ${this.kindLabel(e.kind)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  Text(e.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick(() => this.openEvent(e))
            }, (e: TimelineEvent) => e.id)
          }

          if (this.tab === 'recall') {
            Image(XingyuMedia.image('banner_01'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            Text('根据已保存的日期匹配往日片段，不使用生成式 AI。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            if (this.recall.id.length > 0) {
              Column({ space: 8 }) {
                Text('三个月前或一年前，你留下过这段')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandAccent)
                  .width('100%')
                Text(this.recall.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.recall.preview())
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Text('打开详情')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick(() => XingyuNav.openNarrative(this.recall.id))
            } else {
              AppEmpty({
                title: '还没有可回望的日子',
                description: '先留下几条叙事，之后会按日期翻出往日。'
              })
            }
          }

          if (this.tab === 'year') {
            AppCard({ title: `我的${this.year.year}` }) {
              Column({ space: Theme.space.s2 }) {
                Text(`叙事 ${this.year.narrativeCount} · 灵感 ${this.year.sparkCount} · 主题 ${this.year.themeCount}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.year.topTag.length > 0 ? `高频标签：${this.year.topTag}` : '标签会随记录慢慢出现')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Text(this.year.topTheme.length > 0 ? `常用主题：${this.year.topTheme}` : '创建主题后会统计常用星域')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                if (this.year.highlightTitle.length > 0) {
                  Text(`重要片段：${this.year.highlightTitle}`)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                    .onClick(() => {
                      if (this.year.highlightId.length > 0) {
                        XingyuNav.openNarrative(this.year.highlightId)
                      }
                    })
                }
              }
              .width('100%')
            }
            if (this.year.narrativeCount === 0) {
              AppEmpty({
                title: '本年还没有年册',
                description: '留下至少一条叙事，就能生成今年的星册。',
                actionLabel: '写下今年第一条',
                onAction: () => XingyuNav.openEditor('narrative', '')
              })
            }
          }

          if (this.tab === 'stats') {
            AppCard({ title: '成长数据' }) {
              Column({ space: Theme.space.s3 }) {
                Text(`记录 ${this.stats.narrativeCount}`)
                  .fontSize(Theme.type.title3)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`灵感 ${this.stats.sparkCount} · 收藏 ${this.stats.favoriteCount} · 主题 ${this.stats.themeCount}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Text(`连续 ${this.stats.streakDays} 天`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().brandAccent)
                  .width('100%')
              }
              .width('100%')
            }
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
