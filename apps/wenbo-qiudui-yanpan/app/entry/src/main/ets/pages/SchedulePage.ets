import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { SportCategoryChips } from '../components/sports/SportCategoryChips'
import { MatchListCard } from '../components/sports/MatchListCard'
import { MatchItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { SportsMedia } from '../services/SportsMedia'
import { DetailNav } from '../services/DetailNav'

class StatusChip {
  key: string = ''
  label: string = ''
}

@Component
export struct SchedulePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State allMatches: MatchItem[] = []
  @State sport: string = ''
  @State statusKey: string = ''
  @State loading: boolean = true
  private statusChips: StatusChip[] = SchedulePage.buildStatusChips()

  private static buildStatusChips(): StatusChip[] {
    const chips: StatusChip[] = []
    const all = new StatusChip()
    all.key = ''
    all.label = '全部'
    chips.push(all)
    const live = new StatusChip()
    live.key = 'live'
    live.label = '进行中'
    chips.push(live)
    const upcoming = new StatusChip()
    upcoming.key = 'upcoming'
    upcoming.label = '即将开始'
    chips.push(upcoming)
    const finished = new StatusChip()
    finished.key = 'finished'
    finished.label = '已结束'
    chips.push(finished)
    return chips
  }

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private filtered(): MatchItem[] {
    const out: MatchItem[] = []
    for (const row of this.allMatches) {
      if (this.sport.length > 0 && row.sport !== this.sport) {
        continue
      }
      if (this.statusKey.length > 0 && row.status !== this.statusKey) {
        continue
      }
      out.push(row)
    }
    return out
  }

  private liveCount(): number {
    let n = 0
    for (const row of this.allMatches) {
      if (row.status === 'live') {
        n += 1
      }
    }
    return n
  }

  private upcomingCount(): number {
    let n = 0
    for (const row of this.allMatches) {
      if (row.status === 'upcoming') {
        n += 1
      }
    }
    return n
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.allMatches = await SportsBizService.loadMatches('', false, '')
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({
        title: '公开赛程',
        subtitle: `${this.allMatches.length} 场 · 进行中 ${this.liveCount()} · 待赛 ${this.upcomingCount()}`
      })
      Image(SportsMedia.bannerPrimary())
        .width('100%')
        .height(96)
        .objectFit(ImageFit.Cover)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .borderRadius(Theme.radius.lg)
        .clip(true)

      if (this.loading) {
        AppLoading({ label: '加载赛程…' }).layoutWeight(1)
      } else if (this.allMatches.length === 0) {
        AppEmpty({
          title: '暂无赛程',
          description: '请检查网络后下拉刷新'
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            SportCategoryChips({
              selectedKey: this.sport,
              onSelect: (key: string): void => { this.sport = key }
            })

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.statusChips, (chip: StatusChip) => {
                  Text(chip.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.statusKey === chip.key ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.statusKey === chip.key ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.statusKey = chip.key })
                }, (chip: StatusChip) => chip.key.length > 0 ? chip.key : 'all-status')
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            if (this.filtered().length === 0) {
              AppEmpty({
                title: '该筛选暂无比赛',
                description: '切换项目或状态试试'
              })
            } else {
              ForEach(this.filtered(), (row: MatchItem) => {
                MatchListCard({
                  item: row,
                  onTap: (): void => { DetailNav.openMatch(row.id) }
                })
              }, (row: MatchItem) => row.id)
            }

            Text('赛程为联赛公开资料；点击可查看详情并设置开赛提醒')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .textAlign(TextAlign.Center)
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
