import { Theme } from '../design-system/Theme'
import { WarmMediaCover } from './WarmMediaHero'
import { NoiseTrackItem } from '../../models/WarmCompanionModels'

@Component
export struct NoiseTrackCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: NoiseTrackItem = new NoiseTrackItem()
  @Prop active: boolean = false
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      WarmMediaCover({
        coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'cover_noise_rain',
        tileSize: 100,
        cornerRadius: Theme.radius.lg
      })
      Text(this.item.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(this.active ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.active ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('30%')
    .padding(Theme.space.s2)
    .backgroundColor(this.active ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({
      width: this.active ? 2 : 1,
      color: this.active ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
    })
    .onClick((): void => { this.onTap() })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
