import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { CityItem } from '../../models/CoolModels'
import { CoolBizService } from '../../services/CoolBizService'
import { CoolDetailNav } from '../../services/CoolDetailNav'
import { CoolMedia } from '../../services/CoolMedia'

@Component
export struct CityDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCityIdChange') cityId: string = ''
  @Prop @Watch('onCityIdChange') refreshToken: number = 0
  @State item: CityItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onCityIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CoolBizService.findCity(this.cityId)
    this.loading = false
  }

  private useCity(): void {
    if (this.item !== undefined) {
      AppStorage.setOrCreate('selectedCityId', this.item.id)
    }
    CoolDetailNav.switchTabRoutes()
    CoolDetailNav.close()
  }

  build() {
    if (this.loading) {
      Column() { AppLoading({ label: '打开城市' }) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '城市', onClose: () => CoolDetailNav.close() }) {
        AppEmpty({ title: '城市不存在' })
      }
    } else {
      DetailShell({ title: this.item.title, contentKey: this.cityId, onClose: () => CoolDetailNav.close() }) {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(CoolMedia.resource(this.item !== undefined ? this.item.coverKey : 'hero_city_shade'))
              .width('100%').height(220).objectFit(ImageFit.Cover)
            Column()
              .width('100%').height(110)
              .linearGradient({
                angle: 180,
                colors: [['rgba(11,42,54,0)', 0], ['rgba(11,42,54,0.82)', 1]]
              })
            Column({ space: 4 }) {
              Text(this.item !== undefined ? this.item.title : '')
                .fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
              Text(this.item !== undefined ? `${this.item.condition} · 清凉 ${this.item.coolIndex}` : '')
                .fontSize(Theme.type.footnote).fontColor('#E8FBFF')
            }
            .padding({ left: Theme.space.pageX, bottom: 16 })
          }
          .width('100%').height(220)

          Column({ space: 8 }) {
            Text(this.item !== undefined
              ? `气温 ${this.item.temp}℃ · 体感 ${this.item.feltTemp}℃ · 湿度 ${this.item.humidity}%`
              : '')
              .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            Text(this.item !== undefined ? this.item.summary : '')
              .fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            Text(this.item !== undefined ? this.item.body : '')
              .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            Text(this.item !== undefined ? `穿衣：${this.item.dressHint}` : '')
              .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            Text('天气快照来自平台栏目，为出行参考，不替代气象台预警。')
              .fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: Theme.space.s3 }) {
            AppButton({ label: '查看该城清凉路线', onTap: (): void => this.useCity() })
            AppButton({
              label: '打开天气洞察',
              variant: 'secondary',
              onTap: (): void => {
                CoolDetailNav.switchTabWeather()
                CoolDetailNav.close()
              }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .width('100%')
      }
    }
  }
}
