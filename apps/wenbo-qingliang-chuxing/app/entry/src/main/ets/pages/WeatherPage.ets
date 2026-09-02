import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AdviceItem, CityItem, HourlyFelt } from '../models/CoolModels'
import { CoolBizService } from '../services/CoolBizService'
import { CoolDetailNav } from '../services/CoolDetailNav'
import { CoolMedia } from '../services/CoolMedia'

@Component
export struct WeatherPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @StorageLink('selectedCityId') selectedCityId: string = 'city-hz'
  @State city: CityItem = new CityItem()
  @State advices: AdviceItem[] = []
  @State loading: boolean = true
  @State hasCity: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const found = await CoolBizService.findCity(this.selectedCityId)
    this.hasCity = found !== undefined
    if (found !== undefined) {
      this.city = found
    }
    this.advices = await CoolBizService.loadAdvices()
    this.loading = false
  }

  private maxFelt(): number {
    let m = 1
    for (const h of this.city.hours) {
      if (h.felt > m) {
        m = h.felt
      }
    }
    return m
  }

  build() {
    Column() {
      AppHeader({ title: '天气洞察', subtitle: '体感变化、穿衣与紫外线提醒' })
      if (this.loading) {
        AppLoading({ label: '读取体感预报' })
      } else if (!this.hasCity) {
        AppEmpty({
          title: '没有天气快照',
          description: '请返回首页选择城市后重试。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CoolMedia.resource(this.city.coverKey.length > 0 ? this.city.coverKey : 'weather_sky'))
                .width('100%')
                .height(168)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column()
                .width('100%')
                .height(90)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(11,42,54,0)', 0], ['rgba(11,42,54,0.8)', 1]]
                })
                .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
              Column({ space: 4 }) {
                Text(`${this.city.title} · ${this.city.condition}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor('#E8FBFF')
                Text(`体感 ${this.city.feltTemp}℃ · 清凉 ${this.city.coolIndex}`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
              .padding({ left: 16, bottom: 14 })
            }
            .width('100%')
            .height(168)
            .onClick(() => CoolDetailNav.openCity(this.city.id))

            Text(this.city.dressHint)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)

            Column({ space: 8 }) {
              Text('24 小时体感')
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Scroll() {
                Row({ space: 8 }) {
                  ForEach(this.city.hours, (h: HourlyFelt) => {
                    Column({ space: 6 }) {
                      Text(`${h.felt}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(h.suitable ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                      Column()
                        .width(14)
                        .height(8 + 90 * (h.felt / this.maxFelt()))
                        .backgroundColor(h.suitable ? Theme.colors().brandPrimary : Theme.colors().chart3)
                        .borderRadius(Theme.radius.xs)
                      Text(h.hour)
                        .fontSize(10)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                    .width(36)
                    .justifyContent(FlexAlign.End)
                    .height(150)
                  }, (h: HourlyFelt) => h.hour)
                }
                .alignItems(VerticalAlign.Bottom)
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              Text('高亮柱为较适宜出门的时段。仅供出行参考。')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            ForEach(this.advices, (a: AdviceItem) => {
              Column({ space: 4 }) {
                Text(`${a.categoryLabel()} · ${a.condition}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                Text(a.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(a.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick(() => CoolDetailNav.openAdvice(a.id))
            }, (a: AdviceItem) => a.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
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
}
