import { Theme } from '../design-system/Theme'
import { CityItem, HourlyFelt, RouteItem } from '../../models/CoolModels'
import { CoolDetailNav } from '../../services/CoolDetailNav'
import { CoolMedia } from '../../services/CoolMedia'

@Component
export struct HomeFeed {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop city: CityItem = new CityItem()
  @Prop cities: CityItem[] = []
  @Prop selectedId: string = ''
  @Prop adviceText: string = ''
  @Prop warnText: string = ''
  @Prop suitable: HourlyFelt[] = []
  @Prop featured: RouteItem = new RouteItem()
  @Prop hasFeatured: boolean = false
  onPickCity: (id: string) => void = (_id: string) => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(CoolMedia.resource(this.city.coverKey))
          .width('100%').height(176).objectFit(ImageFit.Cover).borderRadius(Theme.radius.lg)
        Column()
          .width('100%').height(100)
          .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
          .linearGradient({
            angle: 180,
            colors: [['rgba(11,42,54,0)', 0], ['rgba(11,42,54,0.82)', 1]]
          })
        Column({ space: 4 }) {
          Text(`${this.city.title} · ${this.city.condition}`)
            .fontSize(Theme.type.footnote).fontColor('#E8FBFF')
          Text(`${this.city.temp}℃`)
            .fontSize(Theme.type.displayS).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          Text(`体感 ${this.city.feltTemp}℃ · 湿度 ${this.city.humidity}% · 紫外线 ${this.city.uv}`)
            .fontSize(Theme.type.caption).fontColor('#E8FBFF')
        }
        .padding({ left: 16, right: 16, bottom: 14 })
      }
      .width('100%').height(176)
      .onClick(() => CoolDetailNav.openCity(this.city.id))

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.cities, (c: CityItem) => {
            Text(c.title)
              .fontSize(Theme.type.footnote)
              .fontColor(this.selectedId === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.selectedId === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => this.onPickCity(c.id))
          }, (c: CityItem) => c.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      if (this.warnText.length > 0) {
        Text(this.warnText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().dangerContainer)
          .borderRadius(Theme.radius.md)
      }

      this.IndexCard()
      this.AdviceCard()
      this.HoursRow()
      this.QuickRow()
      if (this.hasFeatured) {
        Column({ space: 6 }) {
          Text('今日推荐路线')
            .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
          Text(this.featured.title)
            .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
          Text(`${this.featured.origin} → ${this.featured.dest} · 清凉 ${this.featured.coolIndex}`)
            .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
        }
        .width('100%').padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick(() => CoolDetailNav.openRoute(this.featured.id))
      }
      Text('天气为出行参考，不替代气象台预警。')
        .fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
    }
    .width('100%')
  }

  @Builder
  IndexCard() {
    Row({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.Center }) {
        Progress({ value: this.city.coolIndex, total: 100, type: ProgressType.Ring })
          .width(128).height(128)
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .style({ strokeWidth: 12 })
        Column({ space: 2 }) {
          Text(`${this.city.coolIndex}`)
            .fontSize(Theme.type.title1).fontWeight(FontWeight.Bold).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('清凉指数')
            .fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
      }
      .width(128).height(128)
      Column({ space: 8 }) {
        Text('0 最闷热，100 最清凉。综合气温、湿度、紫外线、风力与空气质量。')
          .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
        Text(`风力 ${this.city.wind} 级 · 空气 ${this.city.aqi}`)
          .fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%').padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  AdviceCard() {
    Column({ space: 8 }) {
      Text('智能出行建议')
        .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
      Text(this.adviceText)
        .fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
      Text('查看完整建议')
        .fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).width('100%')
    }
    .width('100%').padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => CoolDetailNav.openAdvice('ad-timing'))
  }

  @Builder
  HoursRow() {
    Column({ space: 8 }) {
      Text('适宜出行时段')
        .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
      if (this.suitable.length === 0) {
        Text('今天没有明显凉爽窗口，优先室内路线。')
          .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
      } else {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.suitable, (h: HourlyFelt) => {
            Text(h.hour)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }, (h: HourlyFelt) => h.hour)
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  QuickRow() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Text('规划路线').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).textAlign(TextAlign.Center)
          .layoutWeight(1).padding({ top: 14, bottom: 14 })
          .backgroundColor(Theme.colors().brandPrimaryContainer).borderRadius(Theme.radius.md)
          .onClick(() => CoolDetailNav.switchTabRoutes())
        Text('天气洞察').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).textAlign(TextAlign.Center)
          .layoutWeight(1).padding({ top: 14, bottom: 14 })
          .backgroundColor(Theme.colors().brandPrimaryContainer).borderRadius(Theme.radius.md)
          .onClick(() => CoolDetailNav.switchTabWeather())
      }.width('100%')
      Row({ space: Theme.space.s3 }) {
        Text('出行自检').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).textAlign(TextAlign.Center)
          .layoutWeight(1).padding({ top: 14, bottom: 14 })
          .backgroundColor(Theme.colors().brandPrimaryContainer).borderRadius(Theme.radius.md)
          .onClick(() => CoolDetailNav.openDiagnose())
        Text('我的收藏').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).textAlign(TextAlign.Center)
          .layoutWeight(1).padding({ top: 14, bottom: 14 })
          .backgroundColor(Theme.colors().brandPrimaryContainer).borderRadius(Theme.radius.md)
          .onClick(() => CoolDetailNav.openFavorites())
      }.width('100%')
    }
    .width('100%')
  }
}
