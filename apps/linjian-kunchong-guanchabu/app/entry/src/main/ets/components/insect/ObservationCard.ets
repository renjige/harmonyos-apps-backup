import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { Observation, WeatherOption } from '../../models/ObservationModels'
import { InsectMedia } from '../../services/InsectMedia'

@Component
export struct ObservationCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: Observation = new Observation()
  onTap: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        if (this.item.photoUri.length > 0) {
          Image(this.item.photoUri)
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.lg, topRight: Theme.radius.lg })
        } else {
          Image(InsectMedia.cover('hero_leaf_dew'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.lg, topRight: Theme.radius.lg })
        }
        if (this.item.isFavorite) {
          AppIcon({ name: 'heart', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
            .margin({ top: 8, right: 8 })
        }
      }
      Column({ space: 4 }) {
        Text(this.item.name.length > 0 ? this.item.name : '未命名观察')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.item.date} · ${WeatherOption.labelOf(this.item.weather)}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(12)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .shadow({ radius: 8, color: 'rgba(26,74,58,0.06)', offsetY: 2 })
    .onClick((): void => this.onTap())
  }
}
