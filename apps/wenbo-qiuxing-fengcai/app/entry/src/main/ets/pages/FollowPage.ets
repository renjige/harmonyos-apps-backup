import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AthleteListCard } from '../components/sports/AthleteListCard'
import { EventListCard } from '../components/sports/EventListCard'
import { AthleteItem, EventItem, FavoriteItem } from '../models/StarModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'
import { AuthService } from '../services/AuthService'
import { SportCategoryOption } from '../components/sports/SportCategoryBar'

class SportGroup {
  sport: string = ''
  label: string = ''
  athletes: AthleteItem[] = []

  static build(athletes: AthleteItem[]): SportGroup[] {
    const opts = SportCategoryOption.all()
    const labelMap: string[] = []
    for (const opt of opts) {
      labelMap.push(opt.key)
    }
    const out: SportGroup[] = []
    for (const opt of opts) {
      if (opt.key === 'all') {
        continue
      }
      const group = new SportGroup()
      group.sport = opt.key
      group.label = opt.label
      group.athletes = []
      for (const athlete of athletes) {
        if (athlete.sport === opt.key) {
          group.athletes.push(athlete)
        }
      }
      if (group.athletes.length > 0) {
        out.push(group)
      }
    }
    return out
  }
}

@Component
export struct FollowPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @Prop overlayMode: boolean = false
  onRequireAuth: () => void = () => {}
  onClose: () => void = () => {}
  @StorageLink('accessToken') accessToken: string = ''
  @State favorites: FavoriteItem[] = []
  @State athletes: AthleteItem[] = []
  @State groups: SportGroup[] = []
  @State events: EventItem[] = []
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
      this.favorites = []
      this.athletes = []
      this.groups = []
      this.events = []
      this.loading = false
      return
    }
    this.favorites = await StarBizService.loadFavorites('')
    this.athletes = []
    for (const fav of this.favorites) {
      if (fav.targetType !== 'athlete') {
        continue
      }
      const athlete = await StarBizService.findAthlete(fav.targetId)
      if (athlete !== undefined) {
        this.athletes.push(athlete)
      }
    }
    this.groups = SportGroup.build(this.athletes)
    this.events = await StarBizService.loadFollowedEvents(this.favorites)
    this.loading = false
  }

  build() {
    Column() {
      if (this.overlayMode) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('我的关注')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
      } else {
        AppHeader({ title: '关注', subtitle: '智能整理 · 关联赛程 · 提醒' })
      }
      if (!this.isLoggedIn()) {
        Column({ space: Theme.space.s4 }) {
          AppEmpty({
            title: '登录后查看关注',
            description: '游客可浏览球星资料；关注与提醒需登录'
          })
          AppButton({
            label: '登录 / 注册',
            onTap: (): void => { this.onRequireAuth() }
          })
        }
        .padding(Theme.space.pageX)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.loading) {
        AppLoading({ label: '加载关注…' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Column({ space: Theme.space.s3 }) {
              Text('智能整理 · 按项目分组')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.groups.length === 0) {
                AppEmpty({
                  title: '还没有关注球星',
                  description: '在球星详情页点击「关注球星」即可加入'
                })
              } else {
                ForEach(this.groups, (group: SportGroup) => {
                  Column({ space: Theme.space.s2 }) {
                    Text(`${group.label}（${group.athletes.length}）`)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .width('100%')
                    ForEach(group.athletes, (item: AthleteItem) => {
                      AthleteListCard({
                        item: item,
                        compact: true,
                        onTap: (): void => { StarDetailNav.openAthlete(item.id) }
                      })
                    }, (item: AthleteItem) => item.id)
                  }
                  .width('100%')
                }, (group: SportGroup) => group.sport)
              }
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('关联赛程')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.events.length === 0) {
                AppEmpty({
                  title: '暂无关联赛程',
                  description: '关注球星后，其即将开始的赛事会显示在这里'
                })
              } else {
                ForEach(this.events, (ev: EventItem) => {
                  EventListCard({
                    item: ev,
                    compact: true,
                    onTap: (): void => { StarDetailNav.openEvent(ev.id) }
                  })
                }, (ev: EventItem) => ev.id)
              }
            }
            .width('100%')
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
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
