import { Theme } from '../design-system/Theme'
import { TripItem } from '../../models/TravelModels'
import { TravelService } from '../../services/TravelService'

@Component
export struct CountdownCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop trip: TripItem = new TripItem()

  private daysLabel(): string {
    const days = TravelService.daysUntil(this.trip.startDate)
    if (days < 0) {
      return '行程已结束'
    }
    if (days === 0) {
      return '今天出发'
    }
    return `还有 ${days} 天出发`
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('最近行程倒计时')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(this.daysLabel())
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width('100%')
      Text(`${this.trip.title} · ${this.trip.destination}`)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`${this.trip.startDate} 至 ${this.trip.endDate} · 准备 ${this.trip.progress}%`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
