import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { GearBizService } from '../services/GearBizService'
import { GearDetailNav } from '../services/GearDetailNav'
import { GearMedia } from '../services/GearMedia'
import { CatalogItem } from '../models/GearModels'
import { GearListCard } from '../components/gear/GearListCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '户外装备库'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State gear: CatalogItem[] = []
  @State catalog: CatalogItem[] = []
  @State categories: CatalogItem[] = []
  @State filter: string = '全部'
  private chips: string[] = ['全部', '露营', '徒步', '攀登', '水上']

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.gear = await GearBizService.loadMine('gear')
    this.catalog = await GearBizService.loadCatalog()
    this.categories = await GearBizService.loadCategories()
    this.loading = false
  }

  private filteredGear(): CatalogItem[] {
    if (this.filter === '全部') {
      return this.gear
    }
    const out: CatalogItem[] = []
    for (const g of this.gear) {
      if (g.category === this.filter) {
        out.push(g)
      }
    }
    return out
  }

  private addGear(): void {
    if (!AuthService.requireAuth('manage_gear')) {
      this.onRequireAuth()
      return
    }
    GearDetailNav.openGearNew()
  }

  build() {
    Column() {
      Row() {
        Text(this.appName)
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
        .onClick(() => this.addGear())
        Column() {
          AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => GearDetailNav.openMessages())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '打开克重账本' }).layoutWeight(1)
      } else {
        Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image($r('app.media.hero_ridge'))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(120)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,26,26,0)', 0.0], ['rgba(26,26,26,0.86)', 1.0]]
                  })
                Column({ space: 6 }) {
                  Text('克重账本 · 出装对照')
                    .fontSize(Theme.type.caption)
                    .fontColor('#F5F5F5')
                  Text('出门前一眼知道缺什么')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#F5F5F5')
                }
                .padding(16)
              }
              .width('100%')
              .height(200)
              .clip(true)
              .borderRadius(Theme.radius.card)

              Row({ space: 10 }) {
                AppButton({
                  label: '录入装备',
                  onTap: (): void => { this.addGear() }
                })
                AppButton({
                  label: '出装检视',
                  variant: 'secondary',
                  onTap: (): void => { GearDetailNav.openInspect() }
                })
              }
              .width('100%')

              Column({ space: 4 }) {
                Text(GearBizService.weightKgText(GearBizService.totalWeightG(this.gear)))
                  .fontSize(Theme.type.displayS)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(`${this.gear.length} 件装备 · 新用户列表为空`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              Scroll() {
                Row({ space: 8 }) {
                  ForEach(this.chips, (c: string) => {
                    Text(c)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.filter === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                      .backgroundColor(this.filter === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                      .onClick(() => { this.filter = c })
                  }, (c: string) => c)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')

              if (this.filteredGear().length === 0) {
                AppEmpty({
                  title: '装备库还是空的',
                  description: '游客可看图鉴；登录后录入自己的件',
                  actionLabel: '录入装备',
                  onAction: (): void => { this.addGear() }
                })
              } else {
                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                  ForEach(this.filteredGear(), (g: CatalogItem) => {
                    Column() {
                      GearListCard({
                        title: g.title,
                        brand: g.brand,
                        weightText: g.weightKgText(),
                        coverKey: g.coverKey,
                        onTap: () => GearDetailNav.openGear(g.id)
                      })
                    }
                    .width('48%')
                    .margin({ bottom: 12 })
                  }, (g: CatalogItem) => g.id)
                }
              }

              Text('山野图鉴')
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              Scroll() {
                Row({ space: 12 }) {
                  ForEach(this.catalog, (c: CatalogItem) => {
                    Column({ space: 6 }) {
                      Image(GearMedia.resource(c.coverKey))
                        .width(148)
                        .height(100)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(8)
                      Text(c.title)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(1)
                        .width(148)
                      Text(c.weightKgText())
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    }
                    .onClick(() => GearDetailNav.openCatalog(c.id))
                  }, (c: CatalogItem) => c.id)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')

              Text('分类说明')
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              ForEach(this.categories, (c: CatalogItem) => {
                Row({ space: 12 }) {
                  Image(GearMedia.resource(c.coverKey))
                    .width(72)
                    .height(54)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)
                  Column({ space: 4 }) {
                    Text(c.title)
                      .fontSize(Theme.type.subtitleS)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(c.summary)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .maxLines(2)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(10)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.card)
                .onClick(() => GearDetailNav.openCategory(c.id))
              }, (c: CatalogItem) => c.id)
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
