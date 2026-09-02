import { Theme } from '../design-system/Theme'
import { TrailItem } from '../../models/NqModels'
import { NqMedia } from '../../services/NqMedia'
import { NqBizService } from '../../services/NqBizService'

@Component
export struct DiscoverCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TrailItem = new TrailItem()
  @Prop cardHeight: number = 180
  onTap: () => void = () => {}

  private categoryLabel(): string {
    const cat = NqBizService.discoverCategory(this.item)
    if (cat === 'forest') {
      return '森林徒步'
    }
    if (cat === 'lake') {
      return '湖泊湿地'
    }
    if (cat === 'star') {
      return '星空观测'
    }
    if (cat === 'park') {
      return '城市公园'
    }
    return '山川风光'
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(NqMedia.resource(this.item.coverKey))
          .width('100%')
          .height(this.cardHeight)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
        Column()
          .width('100%')
          .height(72)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,26,26,0)', 0], ['rgba(26,26,26,0.82)', 1]]
          })
          .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
        Column({ space: 2 }) {
          Text(this.categoryLabel())
            .fontSize(Theme.type.caption)
            .fontColor('#F5F0E8')
          Text(this.item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .padding({ left: 10, right: 10, bottom: 10 })
      }
      .width('100%')
      .height(this.cardHeight)

      Text(`${this.item.region} · ${this.item.distanceKm}km`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .onClick(() => this.onTap())
  }
}
