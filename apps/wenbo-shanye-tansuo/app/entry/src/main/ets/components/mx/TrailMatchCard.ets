import { Theme } from '../design-system/Theme'
import { TrailItem } from '../../models/MxModels'
import { MxMedia } from '../../services/MxMedia'

@Component
export struct TrailMatchCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TrailItem = new TrailItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(MxMedia.resource(this.item.coverKey))
          .width(220)
          .height(140)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Column()
          .width(220)
          .height(64)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,29,31,0)', 0], ['rgba(26,29,31,0.8)', 1]]
          })
          .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 10, right: 10, bottom: 8 })
      }
      .width(220)
      .height(140)
      Text(`${this.item.difficulty} · ${this.item.distanceKm}km`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width(220)
    }
    .width(220)
    .onClick(() => this.onTap())
  }
}
