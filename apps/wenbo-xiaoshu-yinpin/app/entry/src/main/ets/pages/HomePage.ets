import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { DrinkItem, TipItem } from '../models/DrinkModels'
import { DrinkBizService } from '../services/DrinkBizService'
import { DrinkDetailNav } from '../services/DrinkDetailNav'
import { DrinkMedia } from '../services/DrinkMedia'
import { SessionStore } from '../services/SessionStore'
import { HomeTipsRow } from '../components/drink/HomeTipsRow'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '消暑饮品'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('feelTempC') feelTemp: number = 32
  @State drinks: DrinkItem[] = []
  @State tips: TipItem[] = []
  @State loading: boolean = true
  @State slot: string = 'afternoon'

  aboutToAppear(): void {
    this.slot = DrinkBizService.currentSlot()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.drinks = await DrinkBizService.loadDrinks()
    this.tips = await DrinkBizService.loadTips()
    this.loading = false
  }

  private recItem(): DrinkItem {
    const r = DrinkBizService.recommend(this.drinks, this.feelTemp)
    if (r !== undefined) {
      return r
    }
    return new DrinkItem()
  }

  private pickItem(): DrinkItem {
    const r = DrinkBizService.todayPick(this.drinks)
    if (r !== undefined) {
      return r
    }
    return new DrinkItem()
  }

  private feelWord(): string {
    if (this.feelTemp >= 34) {
      return '燥热'
    }
    if (this.feelTemp >= 30) {
      return '偏热'
    }
    if (this.feelTemp >= 26) {
      return '温热'
    }
    return '还好'
  }

  private onFeel(v: number): void {
    this.feelTemp = Math.round(v)
    void SessionStore.saveFeelTemp(this.feelTemp)
  }

  build() {
    Column() {
      if (this.loading) {
        AppLoading({ label: '正在准备今日消暑' })
      } else if (this.drinks.length === 0) {
        AppEmpty({ title: '还没有饮品', description: '请检查网络后重试', actionLabel: '重试', onAction: () => { void this.reload() } })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            this.Header()
            this.FeelCard()
            this.RecoCard()
            this.TodayCard()
            this.Cats()
            if (this.tips.length > 0) {
              HomeTipsRow({ tips: this.tips })
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Header() {
    Row() {
      Column({ space: 4 }) {
        Text(this.appName)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(`现在是${DrinkBizService.slotLabel(this.slot)}`)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Column() {
        AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick(() => DrinkDetailNav.openMessages())
    }
    .width('100%')
  }

  @Builder
  FeelCard() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日体感')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(`${this.feelTemp}℃ · ${this.feelWord()}`)
          .fontSize(Theme.type.subtitleS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      Slider({ value: this.feelTemp, min: 24, max: 40, step: 1 })
        .blockColor(Theme.colors().brandPrimary)
        .trackColor(Theme.colors().brandPrimaryContainer)
        .selectedColor(Theme.colors().brandPrimary)
        .onChange((v: number) => this.onFeel(v))
        .width('100%')
      Text('不申请定位。把滑杆拖到你现在觉得热的程度，智慧推荐会跟着变。')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .width('100%')
  }

  @Builder
  RecoCard() {
    if (this.recItem().id.length > 0) {
      Column({ space: Theme.space.s3 }) {
        Text('智慧推荐')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(DrinkMedia.resource(this.recItem().coverKey))
            .width('100%')
            .height(188)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(100)
            .linearGradient({ direction: GradientDirection.Bottom, colors: [['#00000000', 0], ['#D90B3A48', 1]] })
          Column({ space: 4 }) {
            Text(this.recItem().title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(`体感 ${this.feelTemp}℃ 的${this.feelWord()}，更适合这杯`)
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 14, right: 14, bottom: 14 })
        }
        .clip(true)
        .borderRadius(Theme.radius.md)
        .width('100%')
        .onClick(() => DrinkDetailNav.openDrink(this.recItem().id))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  TodayCard() {
    if (this.pickItem().id.length > 0) {
      Column({ space: Theme.space.s2 }) {
        Text('今日消暑')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s3 }) {
          Image(DrinkMedia.resource(this.pickItem().coverKey))
            .width(92)
            .height(92)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.sm)
          Column({ space: 6 }) {
            Text(this.pickItem().title)
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .maxLines(1)
            Text(this.pickItem().summary)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(3)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .width('100%')
      .onClick(() => DrinkDetailNav.openDrink(this.pickItem().id))
    }
  }

  @Builder
  Cats() {
    Column({ space: Theme.space.s3 }) {
      Text('分类')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(DrinkBizService.categories(), (c: string) => {
            Text(c)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                AppStorage.setOrCreate('libraryCategory', c)
                AppStorage.setOrCreate('switchTabIndex', 1)
              })
          }, (c: string) => c)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
