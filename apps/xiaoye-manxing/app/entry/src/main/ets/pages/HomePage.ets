import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { SectionHeader } from '../components/wander/SectionHeader'
import { RouteCard } from '../components/wander/RouteCard'
import { InspirationCard } from '../components/wander/InspirationCard'
import { QuoteCard } from '../components/wander/QuoteCard'
import { InspirationItem, QuoteItem, RouteItem } from '../models/WanderModels'
import { WanderBizService } from '../services/WanderBizService'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderMedia } from '../services/WanderMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '夏野漫行'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenRoutes: () => void = () => {}
  @State loading: boolean = true
  @State routes: RouteItem[] = []
  @State inspirations: InspirationItem[] = []
  @State quotes: QuoteItem[] = []
  @State featuredQuote: QuoteItem | undefined = undefined
  @State today: RouteItem | undefined = undefined
  @State appearOpacity: number = 0
  @State appearY: number = 16

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.routes = await WanderBizService.loadRoutes()
    this.inspirations = await WanderBizService.loadInspirations()
    this.quotes = await WanderBizService.loadQuotes()
    this.featuredQuote = undefined
    for (const q of this.quotes) {
      if (this.featuredQuote === undefined) {
        this.featuredQuote = q
      }
    }
    this.today = WanderBizService.pickToday(this.routes)
    this.loading = false
    this.appearY = 0
    this.appearOpacity = 1
  }

  private kindLabel(r: RouteItem): string {
    const d = r.durationKind === 'weekend' ? '周末' : (r.durationKind === 'day' ? '一日' : '半日')
    const s = r.sceneKind === 'city' ? '城市' : '自然'
    return `${d} · ${s}`
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
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => WanderDetailNav.openSearch())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '风正在过来' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s6 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(WanderMedia.resource('hero_summer'))
                .width('100%')
                .height(320)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(36,53,43,0)', 0.08], ['rgba(36,53,43,0.82)', 1.0]]
                })
              Column({ space: 8 }) {
                Text('去吹一阵夏风')
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F6F1E8')
                  .width('100%')
                Text('今天，也可以慢一点。')
                  .fontSize(Theme.type.body)
                  .fontColor('#F6F1E8')
                  .width('100%')
              }
              .padding(20)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height(320)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .borderRadius(Theme.radius.lg)
            .clip(true)

            Column({ space: 12 }) {
              SectionHeader({ title: '今日漫行', action: '全部路线', onAction: () => this.onOpenRoutes() })
              if (this.today === undefined) {
                AppEmpty({ title: '今天先把风听完', description: '路线还在路上，点一下重试', actionLabel: '重试', onAction: () => { void this.reload() } })
              } else {
                RouteCard({
                  title: this.today.title,
                  summary: this.today.summary,
                  coverKey: this.today.coverKey,
                  duration: this.today.duration,
                  difficulty: this.today.difficulty,
                  kindLabel: this.kindLabel(this.today),
                  onTap: (): void => {
                    if (this.today !== undefined) {
                      WanderDetailNav.openRoute(this.today.id)
                    }
                  }
                }).padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }
            }

            Column({ space: 12 }) {
              SectionHeader({ title: '夏日灵感' })
              Scroll() {
                Row({ space: 12 }) {
                  ForEach(this.inspirations, (it: InspirationItem) => {
                    InspirationCard({
                      title: it.title,
                      subtitle: it.subtitle,
                      coverKey: it.coverKey,
                      onTap: (): void => WanderDetailNav.openInspiration(it.id)
                    })
                  }, (it: InspirationItem) => it.id)
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
            }

            Column({ space: 12 }) {
              SectionHeader({ title: '适合今天' })
              Row() {
                Column({ space: 6 }) {
                  Text('不必打开地图')
                    .fontSize(Theme.type.subtitleL)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text('六题，匹配一条今天走得动的轻路线。')
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(18)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick(() => WanderDetailNav.openDiagnose())
            }

            Column({ space: 12 }) {
              SectionHeader({ title: '漫行语录' })
              if (this.featuredQuote !== undefined) {
                QuoteCard({ text: this.featuredQuote.text, author: this.featuredQuote.author })
                  .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
              }
            }
          }
          .width('100%')
          .padding({ bottom: 24 })
          .opacity(this.appearOpacity)
          .translate({ y: this.appearY })
          .animation({ duration: 420, curve: Curve.EaseOut })
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
