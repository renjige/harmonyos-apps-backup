import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { FeedCardFromItem } from '../components/archive/FeedCard'
import { StatTileCard } from '../components/archive/StatTileCard'
import { FeedItem } from '../models/JianModels'
import { JianQuery } from '../services/JianQuery'
import { JianNav } from '../services/JianNav'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('jianDataRev') @Watch('onDataRevChange') jianDataRev: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onSwitchTab: (index: number) => void = () => {}
  @State thoughtCount: number = 0
  @State sparkCount: number = 0
  @State favoriteCount: number = 0
  @State themeCount: number = 0
  @State recent: FeedItem[] = []
  @State recallTitle: string = ''
  @State recallId: string = ''
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
    const s = await JianQuery.stats()
    this.thoughtCount = s.thoughtCount
    this.sparkCount = s.sparkCount
    this.favoriteCount = s.favoriteCount
    this.themeCount = s.themeCount
    this.recent = await JianQuery.recentFeed(5)
    this.listEpoch = this.listEpoch + 1
    const rec = await JianQuery.recall()
    if (rec === undefined) {
      this.recallTitle = ''
      this.recallId = ''
    } else {
      this.recallTitle = rec.title
      this.recallId = rec.id
    }
  }

  private openFeed(it: FeedItem): void {
    if (it.kind === 'card') {
      JianNav.openCard(it.id)
      return
    }
    if (it.kind === 'spark') {
      JianNav.openSpark(it.id)
      return
    }
    JianNav.openThought(it.id)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_slip_light'))
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
            Text('思维空间')
              .fontSize(Theme.type.caption)
              .fontColor('#C4A574')
            Text('今天有什么值得留下？')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F6F1E8')
            Text('记录每一次思考，让想法拥有归处')
              .fontSize(Theme.type.footnote)
              .fontColor('#F6F1E8')
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
        }
        .clip(true)
        .borderRadius(Theme.radius.lg)

        AppButton({
          label: '写下今日思考',
          variant: 'primary',
          onTap: (): void => { JianNav.openEditor('thought', '') }
        })

        Text('我的档案')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          StatTileCard({ label: '思考', value: this.thoughtCount, large: true })
          StatTileCard({ label: '灵感', value: this.sparkCount, large: false })
        }
        .width('100%')
        Row({ space: Theme.space.s3 }) {
          StatTileCard({ label: '主题', value: this.themeCount, large: false })
          StatTileCard({ label: '收藏', value: this.favoriteCount, large: false })
        }
        .width('100%')

        Text('快捷入口')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          this.Quick('新建思维', (): void => { JianNav.openEditor('thought', '') })
          this.Quick('添加灵感', (): void => { JianNav.openEditor('spark', '') })
          this.Quick('观点卡片', (): void => { JianNav.openEditor('card', '') })
          this.Quick('创建主题', (): void => { JianNav.openEditor('theme', '') })
          this.Quick('查看回顾', (): void => { this.onSwitchTab(3) })
        }
        .width('100%')

        Stack({ alignContent: Alignment.Start }) {
          Image($r('app.media.banner_timeline'))
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
              .fontColor('#C4A574')
            if (this.recallId.length === 0) {
              Text('多写几条思考后，这里会翻出过去的观点。')
                .fontSize(Theme.type.footnote)
                .fontColor('#F6F1E8')
            } else {
              Text(`曾经你写过：${this.recallTitle}`)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F6F1E8')
                .maxLines(2)
            }
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4 })
        }
        .width('100%')
        .onClick((): void => {
          if (this.recallId.length > 0) {
            JianNav.openThought(this.recallId)
          } else {
            this.onSwitchTab(3)
          }
        })

        Text('最近沉淀')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.recent.length === 0) {
          Column({ space: Theme.space.s3 }) {
            Image($r('app.media.empty_slip_desk'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            AppEmpty({
              title: '档案还是空的',
              description: '从一条思考或一个灵感开始',
              actionLabel: '写下思考',
              onAction: (): void => { JianNav.openEditor('thought', '') }
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
