import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecipeListCard } from '../components/kitchenlab/RecipeListCard'
import { RecipeItem, PantryItem, KpiItem } from '../models/KitchenLabModels'
import { KitchenLabBizService } from '../services/KitchenLabBizService'
import { KitchenLabDetailNav } from '../services/KitchenLabDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '厨验Lab'
  @Prop tagline: string = ''
  @StorageLink('kitchenTick') @Watch('onKitchenTick') kitchenTick: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @State kpis: KpiItem[] = []
  @State expiring: PantryItem[] = []
  @State matched: RecipeItem[] = []
  @State loading: boolean = true
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onKitchenTick(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.kpis = await KitchenLabBizService.loadKpis()
    if (this.isLoggedIn()) {
      const pantry = await KitchenLabBizService.loadPantry()
      this.expiring = HomePage.filterExpiring(pantry)
      const names: string[] = []
      for (let p of pantry) {
        names.push(p.title)
      }
      this.matched = await KitchenLabBizService.matchRecipes(names)
    } else {
      this.expiring = []
      const all = await KitchenLabBizService.loadRecipes()
      this.matched = all.slice(0, 4)
    }
    this.loading = false
  }

  private static filterExpiring(items: PantryItem[]): PantryItem[] {
    const out: PantryItem[] = []
    const now = Date.now()
    for (let p of items) {
      if (p.expiryDate.length === 0) {
        continue
      }
      const d = new Date(p.expiryDate).getTime()
      const days = Math.ceil((d - now) / 86400000)
      if (days <= 7) {
        out.push(p)
      }
    }
    return out
  }

  private daysLeft(item: PantryItem): number {
    if (item.expiryDate.length === 0) {
      return 999
    }
    const d = new Date(item.expiryDate).getTime()
    return Math.ceil((d - Date.now()) / 86400000)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_kitchen_lab'))
            .width('100%')
            .height(168)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
          Column() {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(this.tagline)
              .fontSize(Theme.type.footnote)
              .fontColor('#FFFFFF')
              .maxLines(2)
              .margin({ top: Theme.space.s1 })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .linearGradient({
            angle: 180,
            colors: [['#00000000', 0.0], ['#00000099', 1.0]]
          })
        }
        .width('100%')

        if (this.kpis.length > 0) {
          Row({ space: Theme.space.s3 }) {
            ForEach(this.kpis.slice(0, 2), (k: KpiItem) => {
              AppStatCard({
                label: k.label,
                value: `${k.value}`,
                trend: '',
                positive: true
              }).layoutWeight(1)
            }, (k: KpiItem) => k.key)
          }
          .width('100%')
        }

        if (this.isLoggedIn() && this.expiring.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Row() {
              AppIcon({ name: 'alert', iconSize: Theme.icon.md, color: Theme.colors().warning })
              Text('保质期提醒')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .margin({ left: Theme.space.s2 })
            }
            .width('100%')
            Scroll() {
              Row({ space: Theme.space.s3 }) {
                ForEach(this.expiring, (p: PantryItem) => {
                  Column({ space: 4 }) {
                    Text(p.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(1)
                    Text(this.daysLeft(p) < 0 ? '已过期' : `${this.daysLeft(p)} 天内到期`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.daysLeft(p) <= 3 ? Theme.colors().danger : Theme.colors().warning)
                  }
                  .width(140)
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().warningContainer)
                  .borderRadius(Theme.radius.lg)
                }, (p: PantryItem) => p.id)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%')
        } else if (!this.isLoggedIn()) {
          Row({ space: Theme.space.s2 }) {
            AppIcon({ name: 'leaf', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
            Text('登录后可同步食材库存并接收保质期提醒')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onRequireAuth())
        }

        Row() {
          AppIcon({ name: 'spark', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('智慧推荐')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .margin({ left: Theme.space.s2 })
        }
        .width('100%')

        if (this.loading) {
          Text('加载中…')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else if (this.matched.length === 0) {
          AppEmpty({
            title: '暂无推荐',
            description: this.isLoggedIn() ? '先录入食材，系统将智慧匹配可做菜谱' : '浏览菜谱库发现灵感',
            actionLabel: this.isLoggedIn() ? '' : '去菜谱',
            onAction: (): void => {
              AppStorage.setOrCreate('mainTab', 2)
            }
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.matched.slice(0, 6), (r: RecipeItem) => {
              RecipeListCard({
                item: r,
                compact: true,
                onTap: (): void => KitchenLabDetailNav.open('recipe', r.id)
              })
            }, (r: RecipeItem) => r.id)
          }
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
