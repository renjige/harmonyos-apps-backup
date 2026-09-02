import { Theme } from '../design-system/Theme'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'
import { AtelierMedia } from '../../services/AtelierMedia'
import { PracticeKind } from '../../models/PracticeModels'

class BenchTile {
  kind: string = 'review'
  title: string = ''
  cover: string = 'cover_biz_01'
}

@Component
export struct WorkshopBench {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private tiles: BenchTile[] = WorkshopBench.buildTiles()

  private static buildTiles(): BenchTile[] {
    const kinds: string[] = ['review', 'aftertaste', 'whitelist', 'walk', 'sketch']
    const titles: string[] = ['三问检修', '余味札', '通知白名单', '同一条路', '临摹三记']
    const list: BenchTile[] = []
    for (let i = 0; i < kinds.length; i++) {
      const t = new BenchTile()
      t.kind = kinds[i]
      t.title = titles[i]
      t.cover = PracticeKind.coverOf(kinds[i])
      list.push(t)
    }
    return list
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('工坊台')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
        Text('我的课业')
          .fontSize(13)
          .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
          .onClick((): void => { AtelierDetailNav.openWorkList() })
      }
      .width('100%')
      Text('读完就练一页。课业只留在本机，不是广场发帖。')
        .fontSize(12)
        .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.tiles, (tile: BenchTile) => {
          this.TileCard(tile)
        }, (tile: BenchTile) => tile.kind)
      }
      .width('100%')

      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.cover_life_02'))
          .width('100%')
          .height(88)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(88)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,42,108,0)', 0.1], ['rgba(26,42,108,0.78)', 1]]
          })
        Column({ space: 2 }) {
          Text('专注计时')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F8F9FA')
          Text('厨房计时器式阅读，到点停下来写一句收获')
            .fontSize(12)
            .fontColor('#F8F9FA')
        }
        .padding({ left: 14, right: 14, bottom: 12 })
      }
      .width('100%')
      .height(88)
      .borderRadius(12)
      .clip(true)
      .onClick((): void => { AtelierDetailNav.openTimer() })
    }
    .width('100%')
  }

  @Builder
  TileCard(tile: BenchTile) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(AtelierMedia.resource(tile.cover))
        .width('100%')
        .height(92)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(92)
        .linearGradient({
          angle: 180,
          colors: [['rgba(26,42,108,0)', 0.12], ['rgba(26,42,108,0.8)', 1]]
        })
      Text(tile.title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F8F9FA')
        .padding({ left: 10, right: 10, bottom: 10 })
    }
    .width('48%')
    .height(92)
    .borderRadius(12)
    .clip(true)
    .margin({ bottom: 8 })
    .onClick((): void => { AtelierDetailNav.openWorkNew(tile.kind, '') })
  }
}
