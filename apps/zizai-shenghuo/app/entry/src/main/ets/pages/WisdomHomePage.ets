import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { WeatherHeader, WisdomCard } from '../components/zizai/WisdomCard'
import { WisdomItem, DayWeatherMock } from '../models/ZizaiModels'
import { DateHelper } from '../services/DateHelper'
import { ZizaiStore } from '../services/ZizaiStore'
import { WisdomData } from '../constants/WisdomData'

@Component
export struct WisdomHomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State wisdom: WisdomItem = new WisdomItem()
  @State isFavorite: boolean = false
  @State favCount: number = 0
  @State toastText: string = ''
  @State greeting: string = ''
  @State dateLabel: string = ''
  @State weekday: string = ''
  @State weather: DayWeatherMock = new DayWeatherMock()
  @State showFavorites: boolean = false
  @State favoriteItems: WisdomItem[] = []

  aboutToAppear(): void {
    this.greeting = DateHelper.greeting()
    const key = DateHelper.todayKey()
    this.dateLabel = DateHelper.displayDate(key)
    this.weekday = DateHelper.displayWeekday(key)
    this.weather = ZizaiStore.weatherMock()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.wisdom = ZizaiStore.todayWisdom()
    this.isFavorite = await ZizaiStore.isFavorite(this.wisdom.id)
    const favIds = await ZizaiStore.loadFavorites()
    this.favCount = favIds.length
    const all = WisdomData.items()
    const favs: WisdomItem[] = []
    for (const w of all) {
      for (const id of favIds) {
        if (w.id === id) {
          favs.push(w)
        }
      }
    }
    this.favoriteItems = favs
  }

  private async handleFavorite(): Promise<void> {
    const nowFav = await ZizaiStore.toggleFavorite(this.wisdom.id)
    this.isFavorite = nowFav
    this.showToast(nowFav ? '已加入收藏' : '已取消收藏')
    await this.reload()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          WeatherHeader({
            greeting: this.greeting,
            dateLabel: this.dateLabel,
            weekday: this.weekday,
            weather: this.weather
          })

          WisdomCard({
            wisdom: this.wisdom,
            isFavorite: this.isFavorite,
            onToggleFavorite: (): void => { void this.handleFavorite() }
          })

          Row() {
            Column({ space: 4 }) {
              Text('我的收藏')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`${this.favCount} 条生活智慧`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text('›')
              .fontSize(20)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => {
            this.showFavorites = true
            AppStorage.setOrCreate('tabBarHidden', true)
          })

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_ambient'))
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(100)
              .borderRadius(Theme.radius.lg)
              .linearGradient({
                angle: 180,
                colors: [['rgba(45,45,45,0.1)', 0], ['rgba(45,45,45,0.55)', 1]]
              })
            Text('每日一条，慢慢积累生活的智慧 ✨')
              .fontSize(Theme.type.subhead)
              .fontColor('#FFFFFF')
              .padding(Theme.space.s4)
          }
          .width('100%')
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: this.bottomInset + Theme.space.s6
        })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      if (this.showFavorites) {
        this.FavoritesOverlay()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FavoritesOverlay() {
    Column() {
      Row() {
        Text('收藏的生活智慧')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => {
            this.showFavorites = false
            AppStorage.setOrCreate('tabBarHidden', false)
          })
      }
      .width('100%')
      .padding(Theme.space.s4)

      if (this.favoriteItems.length === 0) {
        Column({ space: Theme.space.s4 }) {
          Image($r('app.media.empty_calm'))
            .width(160)
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          AppEmpty({
            title: '还没有收藏',
            description: '在首页智慧卡片点击收藏，慢慢积累你的灵感库'
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.favoriteItems, (w: WisdomItem) => {
            ListItem() {
              Column({ space: Theme.space.s2 }) {
                Text(w.content)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(22)
                Text(`— ${w.source}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }
          }, (w: WisdomItem) => w.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.s4, right: Theme.space.s4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(20)
  }
}
