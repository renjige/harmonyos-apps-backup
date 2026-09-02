import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { MatchListCard } from '../components/sports/MatchListCard'
import { FavoriteItem, ReminderItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

@Component
export struct MyActivityPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State segment: number = 0
  @State teamFavs: FavoriteItem[] = []
  @State matchFavs: FavoriteItem[] = []
  @State reminders: ReminderItem[] = []
  @State loading: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.teamFavs = []
    this.matchFavs = []
    this.reminders = []
    if (this.isLoggedIn()) {
      const all = await SportsBizService.loadFavorites('')
      for (const row of all) {
        if (row.targetType === 'team') {
          this.teamFavs.push(row)
        } else if (row.targetType === 'match') {
          this.matchFavs.push(row)
        }
      }
      this.reminders = await SportsBizService.loadReminders('')
    }
    this.loading = false
  }

  private async cancelReminder(id: string): Promise<void> {
    const ok = await SportsBizService.removeReminder(id)
    if (ok) {
      this.showToast('已取消提醒')
      void this.reload()
      return
    }
    this.showToast(SportsBizService.lastError.length > 0 ? SportsBizService.lastError : '取消失败')
  }

  @Builder
  SegmentBtn(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontWeight(this.segment === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.segment === index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.segment === index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.segment = index })
  }

  build() {
    Stack() {
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
            Text('我的动态')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text('关注球队 · 关注比赛 · 开赛提醒')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

        Row({ space: Theme.space.s2 }) {
          this.SegmentBtn('球队', 0)
          this.SegmentBtn('比赛', 1)
          this.SegmentBtn('提醒', 2)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        if (!this.isLoggedIn()) {
          Column({ space: Theme.space.s4 }) {
            AppEmpty({
              title: '登录后查看动态',
              description: '关注与提醒仅保存在你的账号下，新用户默认为空'
            })
            AppButton({
              label: '登录 / 注册',
              onTap: (): void => { this.onRequireAuth() }
            })
          }
          .layoutWeight(1)
          .padding(Theme.space.pageX)
        } else if (this.loading) {
          AppLoading({ label: '加载动态…' }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              if (this.segment === 0) {
                if (this.teamFavs.length === 0) {
                  AppEmpty({
                    title: '尚未关注球队',
                    description: '在球队详情页可添加关注，桌面卡片也会同步'
                  })
                } else {
                  ForEach(this.teamFavs, (row: FavoriteItem) => {
                    Row({ space: Theme.space.s3 }) {
                      Column({ space: 2 }) {
                        Text(row.targetTitle)
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(Theme.colors().textPrimary)
                        Text('已关注球队')
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().brandPrimary)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
                    }
                    .width('100%')
                    .padding(Theme.space.s4)
                    .backgroundColor(Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.xl)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                    .onClick((): void => { DetailNav.openTeam(row.targetId) })
                  }, (row: FavoriteItem) => `act-team-${row.id}`)
                }
              } else if (this.segment === 1) {
                if (this.matchFavs.length === 0) {
                  AppEmpty({
                    title: '尚未关注比赛',
                    description: '在比赛详情页可关注重点场次'
                  })
                } else {
                  ForEach(this.matchFavs, (row: FavoriteItem) => {
                    Row({ space: Theme.space.s3 }) {
                      Column({ space: 2 }) {
                        Text(row.targetTitle)
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(Theme.colors().textPrimary)
                        Text('已关注比赛')
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().brandPrimary)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
                    }
                    .width('100%')
                    .padding(Theme.space.s4)
                    .backgroundColor(Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.xl)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                    .onClick((): void => { DetailNav.openMatch(row.targetId) })
                  }, (row: FavoriteItem) => `act-match-${row.id}`)
                }
              } else {
                if (this.reminders.length === 0) {
                  AppEmpty({
                    title: '暂无开赛提醒',
                    description: '在比赛详情设置提醒后，会出现在这里'
                  })
                } else {
                  ForEach(this.reminders, (row: ReminderItem) => {
                    Column({ space: Theme.space.s3 }) {
                      Column({ space: 2 }) {
                        Text(row.targetTitle.length > 0 ? row.targetTitle : row.title)
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(Theme.colors().textPrimary)
                          .width('100%')
                        Text(`${row.startAt} · ${row.remindLabel()}`)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().textSecondary)
                          .width('100%')
                      }
                      .alignItems(HorizontalAlign.Start)
                      AppButton({
                        label: '取消提醒',
                        variant: 'secondary',
                        onTap: (): void => { void this.cancelReminder(row.id) }
                      })
                    }
                    .width('100%')
                    .padding(Theme.space.s4)
                    .backgroundColor(Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.xl)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                  }, (row: ReminderItem) => `act-rem-${row.id}`)
                }
              }
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
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
