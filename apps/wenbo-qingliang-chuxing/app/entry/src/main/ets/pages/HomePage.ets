import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { HomeFeed } from '../components/cool/HomeFeed'
import { CityItem, HourlyFelt, RouteItem } from '../models/CoolModels'
import { CoolBizService } from '../services/CoolBizService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '清凉出行'
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @StorageLink('selectedCityId') selectedCityId: string = 'city-hz'
  @State cities: CityItem[] = []
  @State city: CityItem = new CityItem()
  @State featured: RouteItem = new RouteItem()
  @State hasFeatured: boolean = false
  @State suitable: HourlyFelt[] = []
  @State loading: boolean = true
  @State adviceText: string = ''
  @State warnText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.cities = await CoolBizService.loadCities()
    let picked: CityItem | undefined = undefined
    for (const c of this.cities) {
      if (c.id === this.selectedCityId) {
        picked = c
      }
    }
    if (picked === undefined) {
      for (const c of this.cities) {
        picked = c
        break
      }
    }
    if (picked !== undefined) {
      this.city = picked
      this.selectedCityId = picked.id
      this.adviceText = CoolBizService.smartAdvice(picked)
      this.warnText = this.buildWarn(picked)
      const suit: HourlyFelt[] = []
      for (const h of picked.hours) {
        if (h.suitable) {
          suit.push(h)
        }
      }
      this.suitable = suit
      const routes = await CoolBizService.loadRoutes(picked.id, '')
      this.hasFeatured = false
      for (const r of routes) {
        this.featured = r
        this.hasFeatured = true
        break
      }
    }
    this.loading = false
  }

  private buildWarn(c: CityItem): string {
    if (c.feltTemp >= 38) {
      return '体感很高，非必要请避开正午户外步行。'
    }
    if (c.uv >= 8) {
      return '紫外线很强，10 点到 16 点优先室内或树荫。'
    }
    if (c.aqi > 80) {
      return '空气质量一般，敏感人群缩短骑行。'
    }
    return ''
  }

  private pickCity(id: string): void {
    this.selectedCityId = id
    void this.reload()
  }

  build() {
    Column() {
      Row() {
        Text(this.appName)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'refresh', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => { void this.reload() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      if (this.loading) {
        AppLoading({ label: '读取城市快照' })
      } else if (this.cities.length === 0) {
        AppEmpty({
          title: '暂时读不到天气',
          description: '请检查网络后重试。栏目来自平台，不会用本地假数据顶上。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          HomeFeed({
            city: this.city,
            cities: this.cities,
            selectedId: this.selectedCityId,
            adviceText: this.adviceText,
            warnText: this.warnText,
            suitable: this.suitable,
            featured: this.featured,
            hasFeatured: this.hasFeatured,
            onPickCity: (id: string): void => this.pickCity(id)
          })
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
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
