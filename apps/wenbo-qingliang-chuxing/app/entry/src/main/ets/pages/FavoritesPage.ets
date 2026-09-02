import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { FavoriteItem, PlanItem } from '../models/CoolModels'
import { CoolBizService } from '../services/CoolBizService'
import { CoolDetailNav } from '../services/CoolDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: FavoriteItem[] = []
  @State plans: PlanItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.items = []
      this.plans = []
      this.loading = false
      return
    }
    this.items = await CoolBizService.loadFavorites()
    this.plans = await CoolBizService.loadPlans()
    this.loading = false
  }

  private openItem(f: FavoriteItem): void {
    if (f.targetKind === 'stop') {
      CoolDetailNav.openStop(f.targetId)
      return
    }
    CoolDetailNav.openRoute(f.targetId)
  }

  private async remove(f: FavoriteItem): Promise<void> {
    await CoolBizService.removeFavorite(f.id)
    await this.reload()
  }

  build() {
    DetailShell({ title: '我的收藏', onClose: () => CoolDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '打开收藏' })
        } else if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后才能收藏',
            description: '游客可以先看清凉指数和路线。'
          })
        } else if (this.items.length === 0 && this.plans.length === 0) {
          AppEmpty({
            title: '还没有收藏或规划',
            description: '在路线或休息点详情里留下来。新账号不会出现别人的记录。'
          })
        } else {
          if (this.plans.length > 0) {
            Text('我的规划')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.plans, (p: PlanItem) => {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(p.title)
                    .fontSize(Theme.type.subtitleM)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${p.origin} → ${p.dest}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick(() => {
                if (p.routeId.length > 0) {
                  CoolDetailNav.openRoute(p.routeId)
                }
              })
            }, (p: PlanItem) => p.id)
          }
          if (this.items.length > 0) {
            Text('收藏')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          ForEach(this.items, (f: FavoriteItem) => {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(f.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(f.targetKind === 'stop' ? '休息点' : '清凉路线')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .layoutWeight(1)
              Text('移除')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .onClick(() => { void this.remove(f) })
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => this.openItem(f))
          }, (f: FavoriteItem) => f.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
