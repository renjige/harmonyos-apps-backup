import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SportRecord } from '../../models/SportRecord'
import { SportTypeOption } from '../../models/SportRecord'

@Component
export struct SportRecordCard {
  @Prop record: SportRecord = new SportRecord()
  onTap: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        if (this.record.coverPhoto().length > 0) {
          Image(this.record.coverPhoto())
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
        } else {
          Image($r('app.media.hero_home'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
        }
        Column() {
          Blank()
          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Text(SportTypeOption.labelOf(this.record.sportType))
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor('rgba(255,107,53,0.85)')
                .borderRadius(Theme.radius.pill)
              if (this.record.primaryMetric().length > 0) {
                Text(this.record.primaryMetric())
                  .fontSize(Theme.type.displayS)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
            }
            Text(this.record.displayTitle())
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(`${this.record.date} · ${this.record.summaryLine()}`)
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.78)', 1]]
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height(220)
      .borderRadius(Theme.radius.lg)
      .clip(true)
    }
    .width('100%')
    .onClick((): void => { this.onTap() })
  }
}
