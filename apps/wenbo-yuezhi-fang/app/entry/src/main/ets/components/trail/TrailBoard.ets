import { Theme } from '../design-system/Theme'
import { AtelierTrails, ReadingTrail } from '../../services/AtelierTrails'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'
import { AtelierProgress } from '../../services/AtelierProgress'
import { AtelierMedia } from '../../services/AtelierMedia'

@Component
export struct TrailBoard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('atelierRefresh') @Watch('onRefreshBump') atelierRefresh: number = 0
  private trails: ReadingTrail[] = AtelierTrails.all()

  onRefreshBump(): void {
    this.trails = AtelierTrails.all()
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('专题路线')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
        Text(`连续 ${AtelierProgress.streakDays()} 天 · 已读 ${AtelierProgress.readCardCount()} 篇`)
          .fontSize(12)
          .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
      }
      .width('100%')
      Text('把相关卡片串成路径，读完做对应工坊练习，比乱点更记得住。')
        .fontSize(12)
        .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
        .width('100%')

      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.trails, (trail: ReadingTrail) => {
            this.TrailCard(trail)
          }, (trail: ReadingTrail) => trail.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  TrailCard(trail: ReadingTrail) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(AtelierMedia.resource(trail.coverKey))
        .width(168)
        .height(108)
        .objectFit(ImageFit.Cover)
      Column()
        .width(168)
        .height(108)
        .linearGradient({
          angle: 180,
          colors: [['rgba(26,42,108,0)', 0.1], ['rgba(26,42,108,0.85)', 1]]
        })
      Column({ space: 2 }) {
        Text(trail.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F8F9FA')
          .maxLines(1)
        Text(`${AtelierProgress.trailDoneCount(trail.cardIds)}/${trail.stepCount()} · ${trail.subtitle}`)
          .fontSize(11)
          .fontColor('#F8F9FA')
          .maxLines(1)
      }
      .padding({ left: 10, right: 10, bottom: 10 })
      .width(168)
    }
    .width(168)
    .height(108)
    .borderRadius(12)
    .clip(true)
    .onClick((): void => { AtelierDetailNav.openTrail(trail.id) })
  }
}
