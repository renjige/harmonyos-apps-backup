import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'
import { CampMedia } from '../services/CampMedia'
import { CatalogItem } from '../models/CampModels'
import { GuideCard } from '../components/camp/GuideCard'
import { SectionHeader } from '../components/camp/SectionHeader'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '露营玩家'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenDiscover: () => void = () => {}
  onOpenGear: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State weather: CatalogItem | undefined = undefined
  @State templates: CatalogItem[] = []
  @State guides: CatalogItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const hints = await CampBizService.loadWeather()
    this.weather = undefined
    for (const h of hints) {
      if (this.weather === undefined) {
        this.weather = h
      }
    }
    this.templates = await CampBizService.loadTemplates()
    this.guides = await CampBizService.loadGuides()
    this.loading = false
  }

  private plan(): void {
    if (!AuthService.requireAuth('create_trip')) {
      this.onRequireAuth()
      return
    }
    CampDetailNav.openTripNew()
  }

  build() {
    Column() {
      Row() {
        Text(this.appName)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Column() {
          AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => CampDetailNav.openMessages())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '称一称今晚的包' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s6 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CampMedia.resource('hero_camp_night'))
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(180)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(22,51,24,0)', 0.05], ['rgba(22,51,24,0.84)', 1.0]]
                })
              Column({ space: 10 }) {
                Text('林线之下，先把装备称完')
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F5F0E8')
                  .width('100%')
                Text('按天数、季节和人数生成打包清单。没有支付，没有导航电商。')
                  .fontSize(Theme.type.body)
                  .fontColor('#F5F0E8')
                  .width('100%')
                AppButton({ label: '规划行程', onTap: () => this.plan() })
              }
              .padding(18)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height(300)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .borderRadius(Theme.radius.card)
            .clip(true)

            if (this.weather !== undefined) {
              Column({ space: 6 }) {
                Text('目的地天气预览')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                Text(this.weather.title)
                  .fontSize(Theme.type.subtitleL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(`${this.weather.city} · ${this.weather.season} · ${this.weather.tempRange}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(this.weather.hint)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(this.weather.extraGear)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick(() => CampDetailNav.openDiagnose())
            }

            Row({ space: 10 }) {
              Column() {
                AppButton({
                  label: '智慧清单',
                  variant: 'secondary',
                  onTap: () => CampDetailNav.openDiagnose()
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: '发现营地',
                  variant: 'secondary',
                  onTap: () => this.onOpenDiscover()
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            SectionHeader({ title: '装备模板', action: '打开装备库', onAction: () => this.onOpenGear() })
            Scroll() {
              Row({ space: 10 }) {
                ForEach(this.templates, (t: CatalogItem) => {
                  Column({ space: 8 }) {
                    Image(CampMedia.resource(t.coverKey))
                      .width(148)
                      .height(96)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                    Text(t.title)
                      .fontSize(Theme.type.subtitleS)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(t.weightLabel())
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  }
                  .width(148)
                  .onClick(() => CampDetailNav.openTemplate(t.id))
                }, (t: CatalogItem) => t.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)

            SectionHeader({ title: '热门攻略', action: '发现营地', onAction: () => this.onOpenDiscover() })
            if (this.guides.length === 0) {
              AppEmpty({
                title: '攻略还在路上',
                description: '下拉刷新或检查网络',
                actionLabel: '重试',
                onAction: () => { void this.reload() }
              })
            } else {
              Column({ space: 10 }) {
                ForEach(this.guides, (g: CatalogItem) => {
                  GuideCard({
                    title: g.title,
                    summary: g.summary,
                    coverKey: g.coverKey,
                    minutes: g.readMinutes,
                    onTap: () => CampDetailNav.openGuide(g.id)
                  })
                }, (g: CatalogItem) => g.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            }
          }
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
