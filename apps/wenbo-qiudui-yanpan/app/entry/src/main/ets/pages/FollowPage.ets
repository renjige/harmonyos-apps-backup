import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { FavoriteItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

@Component
export struct FollowPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @StorageLink('themeRevision') themeRevision: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State items: FavoriteItem[] = []
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
    if (!this.isLoggedIn()) {
      this.items = []
      this.loading = false
      return
    }
    const all = await SportsBizService.loadFavorites('')
    const teams: FavoriteItem[] = []
    for (const row of all) {
      if (row.targetType === 'team') {
        teams.push(row)
      }
    }
    this.items = teams
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Column() {
          AppHeader({ title: '我的关注', subtitle: '仅显示你主动关注的球队，新账号为空' })
        }
        .layoutWeight(1)
      }
      .width('100%')
      if (!this.isLoggedIn()) {
        Column({ space: Theme.space.s4 }) {
          AppEmpty({
            title: '登录后查看关注',
            description: '游客可浏览公开档案；关注需登录'
          })
          AppButton({
            label: '登录 / 注册',
            onTap: (): void => { this.onRequireAuth() }
          })
        }
        .layoutWeight(1)
        .padding(Theme.space.pageX)
        .justifyContent(FlexAlign.Center)
      } else if (this.loading) {
        AppLoading({ label: '加载关注…' }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '还没有关注球队',
          description: '在球队详情页点击「关注球队」，桌面卡片才会显示状态'
        }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (row: FavoriteItem) => {
            ListItem() {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(row.targetTitle)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text('已关注 · 点击查看档案')
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
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { DetailNav.openTeam(row.targetId) })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (row: FavoriteItem) => row.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
