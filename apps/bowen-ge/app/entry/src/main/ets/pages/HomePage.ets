import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { FeedCardFromItem } from '../components/archive/FeedCard'
import { StatTileCard } from '../components/archive/StatTileCard'
import { FeedItem } from '../models/BowenModels'
import { BowenQuery } from '../services/BowenQuery'
import { BowenNav } from '../services/BowenNav'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('bowenDataRev') @Watch('onDataRevChange') bowenDataRev: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onSwitchTab: (index: number) => void = () => {}
  @State cardCount: number = 0
  @State readingCount: number = 0
  @State favoriteCount: number = 0
  @State themeCount: number = 0
  @State streakDays: number = 0
  @State todayNewCount: number = 0
  @State recent: FeedItem[] = []
  @State recallTitle: string = ''
  @State recallId: string = ''
  @State recallKind: string = ''
  @State listEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataRevChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const s = await BowenQuery.stats()
    this.cardCount = s.cardCount
    this.readingCount = s.readingCount
    this.favoriteCount = s.favoriteCount
    this.themeCount = s.themeCount
    this.streakDays = s.streakDays
    this.todayNewCount = s.todayNewCount
    this.recent = await BowenQuery.recentFeed(5)
    this.listEpoch = this.listEpoch + 1
    const rec = await BowenQuery.recall()
    if (rec === undefined) {
      this.recallTitle = ''
      this.recallId = ''
      this.recallKind = ''
    } else {
      this.recallTitle = rec.title
      this.recallId = rec.id
      this.recallKind = rec.kind
    }
  }

  private openFeed(it: FeedItem): void {
    if (it.kind === 'reading') {
      BowenNav.openReading(it.id)
      return
    }
    if (it.kind === 'card') {
      BowenNav.openCard(it.id)
      return
    }
    if (it.kind === 'study') {
      BowenNav.openStudy(it.id)
      return
    }
    if (it.kind === 'spark') {
      BowenNav.openSpark(it.id)
      return
    }
    BowenNav.openThought(it.id)
  }

  private openRecall(): void {
    if (this.recallId.length === 0) {
      this.onSwitchTab(3)
      return
    }
    if (this.recallKind === 'card') {
      BowenNav.openCard(this.recallId)
      return
    }
    BowenNav.openThought(this.recallId)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_pavilion'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(120)
            .linearGradient({
              angle: 180,
              colors: [['rgba(18,38,47,0)', 0], ['rgba(18,38,47,0.82)', 1]]
            })
          Column({ space: 6 }) {
            Text('博闻阁')
              .fontSize(Theme.type.caption)
              .fontColor('#B8956A')
            Text('今天想沉淀什么？')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F6F1E8')
            Text('广泛收集，深度沉淀')
              .fontSize(Theme.type.footnote)
              .fontColor('#F6F1E8')
            if (this.todayNewCount > 0) {
              Text(`今日新增 ${this.todayNewCount} 条`)
                .fontSize(Theme.type.caption)
                .fontColor('#B8956A')
            }
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
        }
        .clip(true)
        .borderRadius(Theme.radius.lg)

        AppButton({
          label: '新建知识卡片',
          variant: 'primary',
          onTap: (): void => { BowenNav.openEditor('card', '') }
        })

        Text('我的档案')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          StatTileCard({ label: '知识', value: this.cardCount, large: true })
          StatTileCard({ label: '阅读', value: this.readingCount, large: false })
        }
        .width('100%')
        Row({ space: Theme.space.s3 }) {
          StatTileCard({ label: '收藏', value: this.favoriteCount, large: false })
          StatTileCard({ label: '专题', value: this.themeCount, large: false })
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          Column({ space: 4 }) {
            Text(`${this.streakDays}`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('连续学习（天）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }
        .width('100%')

        Text('快捷入口')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          this.Quick('新建知识', (): void => { BowenNav.openEditor('card', '') })
          this.Quick('添加阅读', (): void => { BowenNav.openEditor('reading', '') })
          this.Quick('学习记录', (): void => { BowenNav.openEditor('study', '') })
          this.Quick('创建专题', (): void => { BowenNav.openEditor('theme', '') })
        }
        .width('100%')

        Stack({ alignContent: Alignment.Start }) {
          Image($r('app.media.banner_review'))
            .width('100%')
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Column()
            .width('100%')
            .height(96)
            .backgroundColor('rgba(18,38,47,0.45)')
            .borderRadius(Theme.radius.md)
          Column({ space: 4 }) {
            Text('智慧回顾')
              .fontSize(Theme.type.caption)
              .fontColor('#B8956A')
            if (this.recallId.length === 0) {
              Text('多沉淀几条知识后，这里会翻出过去的卡片。')
                .fontSize(Theme.type.footnote)
                .fontColor('#F6F1E8')
            } else {
              Text(`曾经你记录：${this.recallTitle}`)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F6F1E8')
                .maxLines(2)
            }
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4 })
        }
        .width('100%')
        .onClick((): void => { this.openRecall() })

        Text('最近沉淀')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.recent.length === 0) {
          Column({ space: Theme.space.s3 }) {
            Image($r('app.media.empty_desk'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            AppEmpty({
              title: '档案还是空的',
              description: '从一张知识卡片或一次阅读开始',
              actionLabel: '新建知识卡片',
              onAction: (): void => { BowenNav.openEditor('card', '') }
            })
          }
        } else {
          ForEach(this.recent, (it: FeedItem) => {
            FeedCardFromItem({ item: it, onTap: (): void => { this.openFeed(it) } })
          }, (it: FeedItem) => `${it.id}_${this.listEpoch}`)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: this.bottomInset + Theme.space.s6
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  Quick(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(Theme.colors().textPrimary)
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(onTap)
  }
}
