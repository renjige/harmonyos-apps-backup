import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TimelineEntry } from '../models/SaituGrowthModels'
import { SaituTimelineService } from '../services/SaituTimelineService'
import { SaituDetailNav } from '../services/SaituDetailNav'

class TimelineMonthGroup {
  label: string = ''
  entries: TimelineEntry[] = []
}

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onChanged: () => void = () => {}
  @State entries: TimelineEntry[] = []
  @State typeFilter: string = 'all'

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.entries = await SaituTimelineService.build(0)
  }

  private filtered(): TimelineEntry[] {
    if (this.typeFilter === 'all') {
      return this.entries
    }
    const out: TimelineEntry[] = []
    for (const e of this.entries) {
      if (e.kind === this.typeFilter) {
        out.push(e)
      }
    }
    return out
  }

  private monthGroups(): TimelineMonthGroup[] {
    const list = this.filtered()
    const map = new Map<string, TimelineEntry[]>()
    for (const e of list) {
      const d = new Date(e.timestamp)
      const y = d.getFullYear()
      const m = d.getMonth() + 1
      const ms = m < 10 ? `0${m}` : `${m}`
      const label = `${y}-${ms}`
      const bucket = map.get(label)
      if (bucket === undefined) {
        map.set(label, [e])
      } else {
        bucket.push(e)
      }
    }
    const keys: string[] = []
    map.forEach((_v: TimelineEntry[], k: string): void => {
      keys.push(k)
    })
    keys.sort((a, b) => b.localeCompare(a))
    const out: TimelineMonthGroup[] = []
    for (const k of keys) {
      const g = new TimelineMonthGroup()
      g.label = k
      const evs = map.get(k)
      g.entries = evs !== undefined ? evs : []
      out.push(g)
    }
    return out
  }

  private openEntry(e: TimelineEntry): void {
    if (e.kind === 'record') {
      SaituDetailNav.closeTimeline()
      SaituDetailNav.openRecord(e.refId)
      return
    }
    if (e.kind === 'sport') {
      SaituDetailNav.closeTimeline()
      SaituDetailNav.openSportDetail(e.refId)
      return
    }
    if (e.kind === 'insight') {
      SaituDetailNav.closeTimeline()
      SaituDetailNav.openInsight(e.refId)
      return
    }
    if (e.kind === 'milestone') {
      SaituDetailNav.closeTimeline()
      SaituDetailNav.openMilestone(e.refId)
      return
    }
    if (e.kind === 'plan') {
      SaituDetailNav.closeTimeline()
      SaituDetailNav.openPlan(e.refId)
      return
    }
    if (e.kind === 'checkin') {
      SaituDetailNav.closeTimeline()
      SaituDetailNav.openCheckInEditor('')
    }
  }

  @Builder
  FilterChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.typeFilter === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.typeFilter === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.typeFilter = key })
  }

  build() {
    Column() {
      AppNavBar({
        title: '成长时间轴',
        onBack: (): void => SaituDetailNav.closeTimeline()
      })
      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.FilterChip('all', '全部')
          this.FilterChip('record', '札记')
          this.FilterChip('sport', '赛事')
          this.FilterChip('checkin', '打卡')
          this.FilterChip('milestone', '节点')
          this.FilterChip('plan', '计划')
          this.FilterChip('insight', '小结')
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.filtered().length === 0) {
        Column() {
          AppEmpty({
            title: '时间轴还是空的',
            description: '记录、赛事、打卡与小结会按月份串联在这里'
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            ForEach(this.monthGroups(), (g: TimelineMonthGroup) => {
              Column({ space: Theme.space.s3 }) {
                Text(g.label)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                ForEach(g.entries, (e: TimelineEntry) => {
                  Row({ space: Theme.space.s3 }) {
                    Column()
                      .width(4)
                      .height(48)
                      .backgroundColor(Theme.colors().brandPrimary)
                      .borderRadius(2)
                    Column({ space: 4 }) {
                      Row({ space: Theme.space.s2 }) {
                        Text(e.kindLabel())
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().brandPrimary)
                        if (e.favorite) {
                          Text('★')
                            .fontSize(Theme.type.caption)
                            .fontColor(Theme.colors().brandPrimary)
                        }
                      }
                      Text(e.title)
                        .fontSize(Theme.type.body)
                        .fontColor(Theme.colors().textPrimary)
                      Text(e.subtitle)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textTertiary)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(Theme.space.cardPadding)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => this.openEntry(e))
                }, (e: TimelineEntry) => e.id)
              }
              .width('100%')
            }, (g: TimelineMonthGroup) => g.label)
            Blank().height(Theme.space.s10)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
