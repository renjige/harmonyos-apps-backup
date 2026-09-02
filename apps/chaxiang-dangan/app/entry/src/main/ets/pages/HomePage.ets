import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { TeaNav } from '../services/TeaNav'
import { TeaStatsService } from '../services/TeaStatsService'
import { TeaStore } from '../services/TeaStore'
import { TastingCard } from '../components/tea/TastingCard'
import { TastingRecord, TeaStats } from '../models/TeaModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('teaRev') @Watch('onTeaRevChange') teaRev: number = 0
  @State stats: TeaStats = new TeaStats()
  @State today: TastingRecord[] = []
  @State last: TastingRecord = new TastingRecord()
  @State hasLast: boolean = false
  @State snippet: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onTeaRevChange(): void {
    this.reload()
  }

  private reload(): void {
    this.stats = TeaStatsService.compute()
    this.today = TeaStore.todayTastings()
    const last = TeaStore.lastTasting()
    this.hasLast = last !== null
    if (last !== null) {
      this.last = last
    }
    this.snippet = TeaStatsService.yearAgoSnippet()
  }

  @Builder
  quick(title: string, sub: string, onTap: () => void) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(sub)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
    .onClick(onTap)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_tea_space'))
            .width('100%')
            .height(188)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(100)
            .linearGradient({
              angle: 180,
              colors: [['rgba(28,46,38,0)', 0], ['rgba(28,46,38,0.78)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Column({ space: 4 }) {
            Text('我的茶藏')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(`${this.stats.teaCount}`)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            Text('款档案')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding({ left: Theme.space.s5, bottom: Theme.space.s4 })
        }
        .width('100%')
        .clip(true)

        Text('今日品饮')
          .fontSize(Theme.type.subtitleS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        if (this.today.length === 0) {
          Row({ space: Theme.space.s3 }) {
            Image($r('app.media.empty_cup'))
              .width(72)
              .height(72)
              .borderRadius(Theme.radius.sm)
              .objectFit(ImageFit.Cover)
            Column({ space: 6 }) {
              Text('今天还是空杯')
                .fontSize(Theme.type.subtitleS)
                .fontColor(Theme.colors().textPrimary)
              AppButton({
                label: this.stats.teaCount > 0 ? '记一笔品饮' : '先建一款茶档案',
                variant: 'primary',
                onTap: (): void => {
                  if (this.stats.teaCount > 0) {
                    TeaNav.openTastingEditor('', '')
                  } else {
                    TeaNav.openTeaEditor('')
                  }
                }
              })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        } else {
          ForEach(this.today, (r: TastingRecord) => {
            TastingCard({ rec: r, onOpen: (): void => { TeaNav.openTasting(r.id) } })
          }, (r: TastingRecord) => r.id)
        }

        if (this.hasLast) {
          Text('最近记录')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          TastingCard({
            rec: this.last,
            onOpen: (): void => { TeaNav.openTasting(this.last.id) }
          })
        }

        Grid() {
          GridItem() {
            this.quick('新增茶档案', '立一档', (): void => { TeaNav.openTeaEditor('') })
          }
          GridItem() {
            this.quick('记录品饮', '记当下', (): void => { TeaNav.openTastingEditor('', '') })
          }
          GridItem() {
            this.quick('创建茶单', '整理口粮', (): void => { TeaNav.openSheet('listSheetOpen') })
          }
          GridItem() {
            this.quick('添加茶故事', '写下相遇', (): void => { TeaNav.openTeaEditor('') })
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(Theme.space.s3)
        .columnsGap(Theme.space.s3)
        .width('100%')

        Column({ space: 6 }) {
          Text('茶香回顾')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          Text(this.snippet)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .lineHeight(22)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .alignItems(HorizontalAlign.Start)

        Row() {
          Column({ space: 2 }) {
            Text(`${this.stats.teaCount}`).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
            Text('茶品').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          Column({ space: 2 }) {
            Text(`${this.stats.tastingCount}`).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
            Text('品饮').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          Column({ space: 2 }) {
            Text(`${this.stats.favoriteCount}`).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
            Text('在藏').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: 96
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => { this.reload() })
    .backgroundColor(this.teaRev >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
