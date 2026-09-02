import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DetailShell } from '../components/detail/DetailShell'
import { DrinkBizService } from '../services/DrinkBizService'
import { DrinkDetailNav } from '../services/DrinkDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct DashboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State drinkCount: number = 0
  @State favCount: number = 0
  @State tryCount: number = 0
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const drinks = await DrinkBizService.loadDrinks()
    this.drinkCount = drinks.length
    if (AuthService.isLoggedIn()) {
      const favs = await DrinkBizService.loadFavorites()
      const tries = await DrinkBizService.loadTries()
      this.favCount = favs.length
      this.tryCount = tries.length
    } else {
      this.favCount = 0
      this.tryCount = 0
    }
    this.loaded = true
  }

  build() {
    DetailShell({
      title: '消暑册',
      contentKey: `${this.drinkCount}-${this.favCount}-${this.tryCount}`,
      onClose: () => DrinkDetailNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        if (!this.loaded) {
          AppEmpty({ title: '正在汇总' })
        } else {
          this.Stat('饮品库', `${this.drinkCount}`, '栏目来自平台，可随时刷新')
          this.Stat('我的收藏', `${this.favCount}`, '新用户为 0，收藏后才会增加')
          this.Stat('试做记录', `${this.tryCount}`, '新用户为 0，记下试做后才会增加')
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }

  @Builder
  Stat(title: string, value: string, hint: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(value)
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
