import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { WisdomItem, DayWeatherMock } from '../../models/ZizaiModels'

@Component
export struct WisdomCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop wisdom: WisdomItem = new WisdomItem()
  @Prop isFavorite: boolean = false
  onToggleFavorite: () => void = () => {}

  @Builder
  FavoriteAction() {
    Row({ space: 6 }) {
      AppIcon({
        name: 'ai',
        iconSize: Theme.icon.md,
        color: this.isFavorite ? Theme.colors().brandAccent : 'rgba(255,255,255,0.85)'
      })
      Text(this.isFavorite ? '已收藏' : '收藏')
        .fontSize(Theme.type.footnote)
        .fontColor('rgba(255,255,255,0.88)')
    }
    .onClick((): void => { this.onToggleFavorite() })
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.banner_wisdom'))
        .width('100%')
        .height(220)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)

      Column()
        .width('100%')
        .height(220)
        .borderRadius(Theme.radius.lg)
        .linearGradient({
          angle: 180,
          colors: [['rgba(45,45,45,0.05)', 0], ['rgba(45,45,45,0.72)', 1]]
        })

      Column({ space: Theme.space.s3 }) {
        Text(this.wisdom.content)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .lineHeight(28)
          .maxLines(4)

        Row() {
          Text(`— ${this.wisdom.source}`)
            .fontSize(Theme.type.footnote)
            .fontColor('rgba(255,255,255,0.88)')
          Blank()
          this.FavoriteAction()
        }
        .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s5)
    }
    .width('100%')
  }
}

@Component
export struct WeatherHeader {
  @Prop greeting: string = ''
  @Prop dateLabel: string = ''
  @Prop weekday: string = ''
  @Prop weather: DayWeatherMock = new DayWeatherMock()

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.greeting)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(`${this.dateLabel} · ${this.weekday}`)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Row({ space: Theme.space.s4 }) {
        Text(`${this.weather.condition} ${this.weather.tempLow}~${this.weather.tempHigh}°C`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(this.weather.solarTerm)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
