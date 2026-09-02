import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'
import { CatalogItem } from '../models/CampModels'
import { CampEmojiUtil } from '../utils/CampEmojiUtil'

@Component
export struct TripsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @StorageLink('accessToken') accessToken: string = ''
  @State items: CatalogItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (this.isLoggedIn()) {
      this.items = await CampBizService.loadMine('trips')
    } else {
      this.items = []
    }
    this.loading = false
  }

  private createTrip(): void {
    if (!AuthService.requireAuth('create_trip')) {
      this.onRequireAuth()
      return
    }
    CampDetailNav.openTripNew()
  }

  private countdownLabel(startAt: string): string {
    if (startAt.length === 0) {
      return '日期待定'
    }
    const target = new Date(startAt).getTime()
    const now = Date.now()
    const diff = target - now
    if (diff <= 0) {
      return '已出发或进行中'
    }
    const days = Math.ceil(diff / (24 * 3600 * 1000))
    return `距出发 ${days} 天`
  }

  build() {
    Column() {
      AppHeader({ title: '行程规划', subtitle: CampEmojiUtil.tripHint() })
      Row() {
        AppButton({ label: '新建行程', onTap: (): void => this.createTrip() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '读取行程' }).layoutWeight(1)
      } else if (!this.isLoggedIn()) {
        AppEmpty({
          title: '登录后规划行程',
          description: '游客可浏览首页课程。创建行程、关联装备清单需登录。',
          actionLabel: '去登录',
          onAction: (): void => this.onRequireAuth()
        }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '还没有露营行程',
          description: '新账号默认空列表。填写目的地与日期即可开始倒计时。',
          actionLabel: '创建第一个行程',
          onAction: (): void => this.createTrip()
        }).layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(this.items, (t: CatalogItem) => {
            ListItem() {
              AppCard({
                onTap: (): void => CampDetailNav.openTrip(t.id)
              }) {
                Row({ space: 12 }) {
                  Image($r('app.media.hero_camp_night'))
                    .width(72)
                    .height(72)
                    .borderRadius(Theme.radius.sm)
                    .objectFit(ImageFit.Cover)
                  Column({ space: 6 }) {
                    Text(t.title)
                      .fontSize(Theme.type.subtitleL)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(`${t.startAt.length > 0 ? t.startAt.slice(0, 10) : '日期待定'} · ${t.people} 人同行`)
                      .fontSize(Theme.type.footnote)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    Text(this.countdownLabel(t.startAt))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandAccent)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                }
                .width('100%')
              }
            }
          }, (t: CatalogItem) => t.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
