import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SportRecord } from '../../models/SportModels'
import { SportVisual } from './SportVisual'

@Component
export struct SportListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: SportRecord = new SportRecord()
  onTap: () => void = () => {}

  build() {
    Row({ space: 0 }) {
      Column()
        .width(4)
        .alignSelf(ItemAlign.Stretch)
        .backgroundColor(SportVisual.accentHex(this.record.sportType))
        .borderRadius({ topLeft: Theme.radius.xl, bottomLeft: Theme.radius.xl })

      Row({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(SportVisual.coverImage(this.record.sportType))
            .width(64)
            .height(64)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column()
            .width(64)
            .height(64)
            .borderRadius(Theme.radius.lg)
            .linearGradient({
              angle: 180,
              colors: [
                ['rgba(7,11,20,0.05)', 0.0],
                ['rgba(7,11,20,0.72)', 1.0]
              ]
            })
          Text(SportVisual.coverLabel(this.record.sportType))
            .fontSize(Theme.type.overline)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ left: 6, bottom: 6 })
        }
        .width(64)
        .height(64)

        Column({ space: 6 }) {
          Row({ space: Theme.space.s2 }) {
            Text(this.record.sportType)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            if (this.record.feeling.length > 0) {
              Text(SportVisual.feelingTag(this.record.feeling))
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().brandOnPrimary)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
            }
          }
          Text(`${this.record.durationMin} 分钟 · ${this.record.recordDate}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          if (this.record.takeaway.length > 0) {
            Text(this.record.takeaway)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          if (this.record.distanceKm > 0) {
            Text(`${this.record.distanceKm.toFixed(1)} km`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
          }
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .alignItems(HorizontalAlign.End)
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.s4, right: Theme.space.s5, top: Theme.space.s4, bottom: Theme.space.s4 })
    }
    .width('100%')
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 14,
      color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(26,35,50,0.08)',
      offsetY: 6
    })
    .onClick(() => {
      this.onTap()
    })
  }
}
