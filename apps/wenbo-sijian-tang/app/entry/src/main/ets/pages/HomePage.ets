import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadListCard } from '../components/wisdom/ReadListCard'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'
import { LunarHintUtil } from '../utils/LunarHintUtil'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '思见堂'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State todayQuote: WisdomItem = new WisdomItem()
  @State todayTopic: WisdomItem = new WisdomItem()
  @State reads: WisdomItem[] = []
  @State hasQuote: boolean = false
  @State hasTopic: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const quote = await WisdomHallBizService.loadQuotesToday()
    if (quote !== undefined) {
      this.todayQuote = quote
      this.hasQuote = true
    } else {
      this.hasQuote = false
    }
    const topics = await WisdomHallBizService.loadTopics()
    if (topics.length > 0) {
      const day = new Date().getDate()
      this.todayTopic = topics[day % topics.length]
      this.hasTopic = true
    } else {
      this.hasTopic = false
    }
    const allReads = await WisdomHallBizService.loadReads()
    const slice: WisdomItem[] = []
    const max = allReads.length > 6 ? 6 : allReads.length
    for (let i = 0; i < max; i++) {
      slice.push(allReads[i])
    }
    this.reads = slice
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Text(this.appName)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
        }
        .width('100%')

        Text('今日堂 · 静思一处')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          Column({ space: 4 }) {
            Text(LunarHintUtil.todayLabel())
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(LunarHintUtil.weekdayLabel())
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text(LunarHintUtil.lunarHint())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        if (this.hasQuote) {
          Column({ space: Theme.space.s3 }) {
            Text('今日慧语')
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Column({ space: 8 }) {
              Text(this.todayQuote.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.todayQuote.authorName.length > 0 ? `—— ${this.todayQuote.authorName}` : '')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
              Text(this.todayQuote.summaryLine())
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { WisdomHallNav.openDetail('quote', this.todayQuote.id) })
          }
          .width('100%')
        }

        if (this.hasTopic) {
          Column({ space: Theme.space.s2 }) {
            Text('今日思考')
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.todayTopic.title)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('进入议题 →')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .onClick((): void => { WisdomHallNav.openDetail('topic', this.todayTopic.id) })
        }

        this.SectionHead('推荐阅读')
        if (this.reads.length === 0) {
          AppEmpty({ title: '暂无荐读', description: '请检查网络后下拉刷新' })
        } else {
          ForEach(this.reads, (item: WisdomItem) => {
            ReadListCard({
              title: item.title,
              summary: item.summaryLine(),
              category: item.category,
              readMinutes: item.readMinutes,
              coverKey: item.coverKey,
              onOpen: (): void => { WisdomHallNav.openDetail('read', item.id) }
            })
          }, (item: WisdomItem) => item.id)
        }

        Text('快捷入口')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s3 }) {
          this.QuickEntry('思录', 'biz', (): void => { WisdomHallNav.switchTab(1) })
          this.QuickEntry('思友圈', 'message', (): void => { WisdomHallNav.switchTab(2) })
        }
        .width('100%')
        .padding({ bottom: Theme.space.s10 })
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
  SectionHead(title: string) {
    Text(title)
      .fontSize(Theme.type.subtitleL)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
  }

  @Builder
  QuickEntry(label: string, iconName: 'biz' | 'message', onTap: () => void) {
    Column({ space: 6 }) {
      AppIcon({ name: iconName, iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick((): void => { onTap() })
  }
}
