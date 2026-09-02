import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { GearBizService } from '../services/GearBizService'
import { GearDetailNav } from '../services/GearDetailNav'
import { CatalogItem } from '../models/GearModels'
import { TrailListCard } from '../components/gear/TrailListCard'

@Component
export struct TrailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State keyword: string = ''
  @State trails: CatalogItem[] = []
  @State mine: CatalogItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.trails = await GearBizService.loadTrails()
    this.mine = await GearBizService.loadMine('routes')
    this.loading = false
  }

  private shown(): CatalogItem[] {
    if (this.keyword.trim().length === 0) {
      return this.trails
    }
    const k = this.keyword.trim()
    const out: CatalogItem[] = []
    for (const t of this.trails) {
      if (t.title.indexOf(k) >= 0 || t.origin.indexOf(k) >= 0) {
        out.push(t)
      }
    }
    return out
  }

  private addRoute(): void {
    if (!AuthService.requireAuth('create_route')) {
      this.onRequireAuth()
      return
    }
    GearDetailNav.openRouteNew()
  }

  build() {
    Column() {
      Row() {
        Text('路线规划')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.addRoute())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      TextInput({ text: this.keyword, placeholder: '搜索精选路线' })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        .onChange((v: string) => { this.keyword = v })

      if (this.loading) {
        AppLoading({ label: '打开路线图鉴' }).layoutWeight(1)
      } else {
        Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.banner_ready'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.card)

              if (this.shown().length === 0) {
                AppEmpty({
                  title: '没有匹配的路线',
                  actionLabel: '清空搜索',
                  onAction: (): void => { this.keyword = '' }
                })
              } else {
                ForEach(this.shown(), (t: CatalogItem) => {
                  TrailListCard({
                    title: t.title,
                    meta: t.subtitle,
                    summary: t.summary,
                    coverKey: t.coverKey,
                    onTap: () => GearDetailNav.openTrail(t.id)
                  })
                }, (t: CatalogItem) => t.id)
              }

              Text('我创建的路线')
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              if (this.mine.length === 0) {
                Text('登录后创建的路线会出现在这里。新用户为空。')
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              } else {
                ForEach(this.mine, (t: CatalogItem) => {
                  TrailListCard({
                    title: t.title,
                    meta: t.summary,
                    summary: t.body,
                    coverKey: t.coverKey.length > 0 ? t.coverKey : 'hero_ridge',
                    onTap: () => GearDetailNav.openRoute(t.id)
                  })
                }, (t: CatalogItem) => t.id)
              }

              AppButton({
                label: '创建路线',
                variant: 'secondary',
                onTap: (): void => { this.addRoute() }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            .width('100%')
          }
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
