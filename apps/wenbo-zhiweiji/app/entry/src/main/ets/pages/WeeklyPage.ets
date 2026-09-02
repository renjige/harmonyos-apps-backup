import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CaptureListCard } from '../components/capture/CaptureListCard'
import { CaptureItem, CategoryCount } from '../models/ZhiweiModels'
import { InsightEngine } from '../services/InsightEngine'
import { ZhiweiMedia } from '../services/ZhiweiMedia'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct WeeklyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @State summary: string = ''
  @State keywordCsv: string = ''
  @State captureCount: number = 0
  @State distTitle: string = '分类分布'
  @State cats: CategoryCount[] = []
  @State weekItems: CaptureItem[] = []

  aboutToAppear(): void {
    void this.load()
  }

  onRev(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const week = await ZhiweiStore.weeklyDigest()
    this.summary = week.summary
    this.keywordCsv = week.keywordCsv
    const bars = ZhiweiStore.weeklyBarItems()
    this.cats = ZhiweiStore.categoryRows(bars)
    this.captureCount = bars.length
    const recent = ZhiweiStore.weekCaptures()
    if (recent.length === 0 && bars.length > 0) {
      this.distTitle = '累计分类分布（近七日暂无新笔记，点分类仍可查看）'
      this.weekItems = ZhiweiStore.sortedCaptures()
    } else {
      this.distTitle = '近七日分类分布（点分类查看条目）'
      this.weekItems = recent
    }
  }

  private barWidth(count: number): number {
    let max = 1
    for (const row of this.cats) {
      if (row.count > max) {
        max = row.count
      }
    }
    if (count <= 0) {
      return 0
    }
    const n = Math.floor(count * 100 / max)
    if (n < 10) {
      return 10
    }
    return n
  }

  private summaryOf(item: CaptureItem): string {
    if (item.body.length <= 40) {
      return item.body
    }
    return `${item.body.substring(0, 40)}…`
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => ZhiweiNav.closeWeekly())
        Text('周度洞察')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Image(ZhiweiMedia.bannerInsight())
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Text(`统计范围共 ${this.captureCount} 条`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          Text(this.summary)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
            .lineHeight(22)
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.card)

          Text(this.distTitle)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          ForEach(this.cats, (row: CategoryCount) => {
            this.BarRow(row)
          }, (row: CategoryCount) => row.id)

          if (this.keywordCsv.length > 0) {
            Text('关键词 · 点词查看相关收录')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Text(this.keywordCsv)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick(() => {
                const words = InsightEngine.keywordHitsOf(this.keywordCsv)
                let first = ''
                for (const w of words) {
                  first = w
                  break
                }
                if (first.length > 0) {
                  ZhiweiNav.openFocus('keyword', first, `线索「${first}」`)
                }
              })
          }

          AppButton({
            label: '查看本范围全部笔记',
            variant: 'primary',
            onTap: (): void => ZhiweiNav.openFocus('weekAll', '', '周度相关笔记')
          })
          AppButton({
            label: '重新生成本周报告',
            variant: 'secondary',
            onTap: (): void => { void this.load() }
          })

          Text('笔记列表')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          if (this.weekItems.length === 0) {
            AppEmpty({
              title: '还没有微知识',
              description: '回去记一条，这里会按六大分类统计条数。',
              actionLabel: '记微知识',
              onAction: (): void => {
                ZhiweiNav.closeWeekly()
                ZhiweiNav.openCompose('', false)
              }
            })
          } else {
            ForEach(this.weekItems, (item: CaptureItem) => {
              CaptureListCard({
                itemId: item.id,
                title: item.title,
                summary: this.summaryOf(item),
                category: item.category,
                priority: item.priority,
                status: item.status,
                timeLabel: ZhiweiStore.displayTime(item.updatedAt),
                onTap: (): void => ZhiweiNav.openCapture(item.id)
              })
            }, (item: CaptureItem) => item.id)
          }
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
    .id(`weekly_${this.themeEpoch}`)
  }

  @Builder
  BarRow(row: CategoryCount) {
    Column({ space: 6 }) {
      Row() {
        Text(`${row.name} ${row.count}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        Blank()
        Text('查看')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
      }
      .width('100%')
      Row() {
        Column()
          .width(row.count > 0 ? `${this.barWidth(row.count)}%` : '0%')
          .height(10)
          .backgroundColor(Theme.colorOf(this.themeEpoch).brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
      .height(10)
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceSubtle)
      .borderRadius(Theme.radius.pill)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(() => ZhiweiNav.openFocus('weekCat', row.id, `${row.name}`))
  }
}
