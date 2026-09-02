import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { SectionHeader } from '../components/wander/SectionHeader'
import { RouteCard } from '../components/wander/RouteCard'
import { InspirationCard } from '../components/wander/InspirationCard'
import { InspirationItem, RouteItem } from '../models/WanderModels'
import { WanderBizService } from '../services/WanderBizService'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderMedia } from '../services/WanderMedia'

class CategoryTile {
  id: string = ''
  label: string = ''
  emoji: string = ''
  mediaKey: string = ''

  static all(): CategoryTile[] {
    const out: CategoryTile[] = []
    const mk = (id: string, label: string, emoji: string, mediaKey: string): CategoryTile => {
      const t = new CategoryTile()
      t.id = id
      t.label = label
      t.emoji = emoji
      t.mediaKey = mediaKey
      return t
    }
    out.push(mk('food', '美食', '🍜', 'banner_cafe'))
    out.push(mk('culture', '人文', '📖', 'banner_bookstore'))
    out.push(mk('nature', '自然', '🌳', 'cat_nature'))
    out.push(mk('art', '艺术', '🎨', 'cat_art'))
    out.push(mk('shop', '购物', '🛍️', 'route_town'))
    out.push(mk('city', '城市', '🏙️', 'hero_discovery'))
    return out
  }
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '发现之旅'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenRoutes: () => void = () => {}
  @State loading: boolean = true
  @State routes: RouteItem[] = []
  @State inspirations: InspirationItem[] = []
  @State today: RouteItem | undefined = undefined
  @State featured: RouteItem[] = []
  @State appearOpacity: number = 0
  @State appearY: number = 16
  private categories: CategoryTile[] = CategoryTile.all()

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
    this.today = WanderBizService.pickToday(this.routes)
    this.featured = HomePage.pickFeatured(this.routes)
    this.loading = false
    this.appearY = 0
    this.appearOpacity = 1
  }

  private static pickFeatured(routes: RouteItem[]): RouteItem[] {
    const out: RouteItem[] = []
    let i = 0
    for (const r of routes) {
      if (i >= 6) {
        break
      }
      out.push(r)
      i += 1
    }
    return out
  }

  private kindLabel(r: RouteItem): string {
    const d = r.durationKind === 'weekend' ? '周末' : (r.durationKind === 'day' ? '一日' : '半日')
    const s = r.sceneKind === 'city' ? '城市' : '自然'
    return `${d} · ${s}`
  }

  private categoryImage(key: string): Resource {
    if (key === 'banner_cafe') {
      return $r('app.media.banner_cafe')
    }
    if (key === 'banner_bookstore') {
      return $r('app.media.banner_bookstore')
    }
    if (key === 'cat_nature') {
      return $r('app.media.cat_nature')
    }
    if (key === 'cat_art') {
      return $r('app.media.cat_art')
    }
    if (key === 'hero_discovery') {
      return $r('app.media.hero_discovery')
    }
    return WanderMedia.resource('route_town')
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
        AppLoading({ label: '正在加载探索灵感' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s6 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_discovery'))
                .width('100%')
                .height(320)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,42,108,0)', 0.08], ['rgba(26,42,108,0.88)', 1.0]]
                })
              Column({ space: 8 }) {
                Text('开启城市发现')
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .width('100%')
                Text('咖啡馆、书店、艺术空间，都在附近等你。')
                  .fontSize(Theme.type.body)
                  .fontColor('#FFFFFF')
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
              SectionHeader({ title: '精选推荐', action: '全部', onAction: () => this.onOpenRoutes() })
              Scroll() {
                Row({ space: 12 }) {
                  ForEach(this.featured, (r: RouteItem) => {
                    RouteCard({
                      title: r.title,
                      summary: r.summary,
                      coverKey: r.coverKey,
                      duration: r.duration,
                      difficulty: r.difficulty,
                      kindLabel: this.kindLabel(r),
                      onTap: (): void => WanderDetailNav.openRoute(r.id)
                    }).width(280)
                  }, (r: RouteItem) => r.id)
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
            }

            Column({ space: 12 }) {
              SectionHeader({ title: '今日探索', action: '查看详情', onAction: (): void => {
                if (this.today !== undefined) {
                  WanderDetailNav.openRoute(this.today.id)
                }
              } })
              if (this.today === undefined) {
                AppEmpty({ title: '今日探索准备中', description: '稍后再来看看', actionLabel: '重试', onAction: () => { void this.reload() } })
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
              SectionHeader({ title: '分类浏览' })
              Grid() {
                ForEach(this.categories, (c: CategoryTile) => {
                  GridItem() {
                    Column({ space: 6 }) {
                      Stack({ alignContent: Alignment.BottomStart }) {
                        Image(this.categoryImage(c.mediaKey))
                          .width('100%')
                          .height(72)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(Theme.radius.sm)
                        Column()
                          .width('100%')
                          .height(36)
                          .linearGradient({
                            angle: 180,
                            colors: [['rgba(26,42,108,0)', 0], ['rgba(26,42,108,0.75)', 1]]
                          })
                          .borderRadius({ bottomLeft: Theme.radius.sm, bottomRight: Theme.radius.sm })
                        Text(`${c.emoji} ${c.label}`)
                          .fontSize(Theme.type.subhead)
                          .fontColor('#FFFFFF')
                          .padding({ left: 8, bottom: 8 })
                      }
                      .width('100%')
                      .height(72)
                    }
                    .onClick((): void => this.onOpenRoutes())
                  }
                }, (c: CategoryTile) => c.id)
              }
              .columnsTemplate('1fr 1fr 1fr')
              .rowsGap(10)
              .columnsGap(10)
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }

            Column({ space: 12 }) {
              SectionHeader({ title: '探索灵感' })
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
              SectionHeader({ title: '探索匹配' })
              Row() {
                Column({ space: 6 }) {
                  Text('找到适合今天的路线')
                    .fontSize(Theme.type.subtitleL)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text('六题问卷，匹配一条可执行的轻探索路线。')
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
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick(() => WanderDetailNav.openDiagnose())
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
