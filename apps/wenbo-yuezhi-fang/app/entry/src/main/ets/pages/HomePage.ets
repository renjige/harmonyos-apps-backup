import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppIcon } from '../components/design-system/AppIcon'
import { ContentCard } from '../components/ContentCard'
import { CardItem, DailyItem } from '../models/AtelierModels'
import { AtelierBizService } from '../services/AtelierBizService'
import { AtelierDetailNav } from '../services/AtelierDetailNav'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { WorkshopBench } from '../components/practice/WorkshopBench'
import { TrailBoard } from '../components/trail/TrailBoard'

class CatChip {
  id: string = 'all'
  label: string = '全部'
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '悦知坊'
  @Prop tagline: string = '悦读片刻，智识日常'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State cards: CardItem[] = AtelierBizService.packCards()
  @State shown: CardItem[] = AtelierBizService.packCards()
  @State today: DailyItem = AtelierBizService.pickToday(AtelierBizService.packDaily())
  @State cat: string = 'all'
  @State loadError: string = ''
  private chips: CatChip[] = HomePage.buildChips()

  aboutToAppear(): void {
    this.cards = AtelierBizService.packCards()
    this.today = AtelierBizService.pickToday(AtelierBizService.packDaily())
    this.applyFilter()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private static buildChips(): CatChip[] {
    const ids: string[] = ['all', 'business', 'humanity', 'tech', 'life', 'art']
    const list: CatChip[] = []
    for (const id of ids) {
      const c = new CatChip()
      c.id = id
      c.label = id === 'all' ? '全部' : CategoryEmojiUtil.chipLabel(id)
      list.push(c)
    }
    return list
  }

  private async reload(): Promise<void> {
    this.loadError = ''
    if (this.cards.length === 0) {
      this.cards = AtelierBizService.packCards()
      this.applyFilter()
    }
    const remote = await AtelierBizService.loadCards()
    if (remote.length > 0) {
      this.cards = remote
    }
    this.loadError = AtelierBizService.lastError
    const days = await AtelierBizService.loadDaily()
    if (days.length > 0) {
      this.today = AtelierBizService.pickToday(days)
    } else if (this.today.id.length === 0) {
      this.today = AtelierBizService.pickToday(AtelierBizService.packDaily())
    }
    this.applyFilter()
  }

  private applyFilter(): void {
    this.shown = AtelierBizService.filterByCategory(this.cards, this.cat)
  }

  private selectCat(id: string): void {
    this.cat = id
    this.applyFilter()
  }

  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text(this.appName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(this.tagline)
            .fontSize(13)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { AtelierDetailNav.openSearch() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_atelier'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(200)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,42,108,0)', 0.2], ['rgba(26,42,108,0.78)', 1]]
              })
            Column({ space: 6 }) {
              Text('悦知坊')
                .fontSize(13)
                .fontColor('#F8F9FA')
              Text('悦读片刻，智识日常')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F8F9FA')
            }
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .height(200)
          .borderRadius(12)
          .clip(true)

          WorkshopBench()

          TrailBoard()

          if (this.today.id.length > 0) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.banner_daily'))
                .width('100%')
                .height(112)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(112)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,42,108,0)', 0.15], ['rgba(26,42,108,0.72)', 1]]
                })
              Column({ space: 4 }) {
                Text('每日精选')
                  .fontSize(12)
                  .fontColor('#F8F9FA')
                Text(this.today.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F8F9FA')
                  .maxLines(1)
              }
              .padding({ left: 14, right: 14, bottom: 12 })
            }
            .width('100%')
            .height(112)
            .borderRadius(12)
            .clip(true)
            .onClick((): void => { AtelierDetailNav.openDaily(this.today.id) })
          }

          List({ space: 8 }) {
            ForEach(this.chips, (chip: CatChip) => {
              ListItem() {
                Text(chip.label)
                  .fontSize(13)
                  .fontColor(this.cat === chip.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.cat === chip.id ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(8)
                  .onClick((): void => { this.selectCat(chip.id) })
              }
            }, (chip: CatChip) => chip.id)
          }
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
          .height(44)

          if (this.shown.length === 0) {
            if (this.loadError.length > 0) {
              AppError({
                title: '知识卡加载失败',
                message: this.loadError,
                retryLabel: '重新加载',
                onRetry: (): void => { void this.reload() }
              })
            } else {
              AppEmpty({
                title: '这一工坊暂时还没有知识卡',
                description: '换个分类，或稍后刷新。',
                actionLabel: '重新加载',
                onAction: (): void => { void this.reload() }
              })
            }
          } else {
            ForEach(this.shown, (row: CardItem) => {
              ContentCard({
                item: row,
                onOpen: (): void => { AtelierDetailNav.openCard(row.id) }
              })
            }, (row: CardItem) => row.id)
          }
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
