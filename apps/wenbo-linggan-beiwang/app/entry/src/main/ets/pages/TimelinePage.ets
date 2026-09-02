import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationItem } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { AuthService } from '../services/AuthService'
import { GrowthStore } from '../services/GrowthStore'
import { GrowthService } from '../services/GrowthService'

class TimelineMixItem {
  key: string = ''
  kind: string = 'capture'
  title: string = ''
  date: string = ''
  refKind: string = ''
  refId: string = ''
}

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: InspirationItem[] = []
  @State mix: TimelineMixItem[] = []
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private openMix(row: TimelineMixItem): void {
    if (row.kind === 'capture' && row.refId.length > 0) {
      InspirationDetailNav.openInspiration(row.refId)
      return
    }
    if (row.refKind === 'inspiration' && row.refId.length > 0) {
      InspirationDetailNav.openInspiration(row.refId)
      return
    }
    if (row.refKind === 'plan' && row.refId.length > 0) {
      InspirationDetailNav.openPlan(row.refId)
    }
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.items = await InspirationBizService.loadInspirations(this.currentUsername)
      const growth = await GrowthStore.load(this.currentUsername)
      const rows: TimelineMixItem[] = []
      for (const ev of growth.activity) {
        const m = new TimelineMixItem()
        m.key = `ev_${ev.at}_${ev.refId}_${ev.type}`
        m.kind = 'activity'
        m.title = `${GrowthService.typeLabel(ev.type)} · ${ev.title}`
        m.date = ev.at
        m.refKind = ev.refKind
        m.refId = ev.refId
        rows.push(m)
      }
      for (const item of this.items) {
        const m = new TimelineMixItem()
        m.key = `cap_${item.id}`
        m.kind = 'capture'
        m.title = item.title
        m.date = item.recordDate.length > 0 ? item.recordDate : item.createdAt.slice(0, 10)
        m.refKind = 'inspiration'
        m.refId = item.id
        rows.push(m)
      }
      this.mix = rows
    } else {
      this.items = []
      this.mix = []
    }
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
        .onClick((): void => this.onClose())
        Column({ space: 2 }) {
          Text('灵感时间轴')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('按时间回顾你的创意轨迹')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s3
      })

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Theme.colors().brandPrimary)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (!AuthService.isLoggedIn()) {
        AppEmpty({
          title: '登录后查看时间轴',
          description: '你的灵感记录将按时间排列展示创意轨迹',
          actionLabel: '去登录',
          onAction: (): void => this.onRequireAuth()
        })
      } else if (this.mix.length === 0) {
        AppEmpty({
          title: '暂无历史记录',
          description: '记录第一条灵感或完成一次打卡后，轨迹会出现在这里'
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            ForEach(this.mix, (row: TimelineMixItem, index: number) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Column()
                    .width(10)
                    .height(10)
                    .borderRadius(Theme.radius.pill)
                    .backgroundColor(index === 0 ?
                      Theme.colors().brandAccent : Theme.colors().brandPrimaryContainer)
                  if (index < this.mix.length - 1) {
                    Column()
                      .width(2)
                      .height(36)
                      .backgroundColor(Theme.colors().strokeHairline)
                  }
                }
                .alignItems(HorizontalAlign.Center)
                Column({ space: 4 }) {
                  Text(row.date)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                  Text(row.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
              .onClick((): void => { this.openMix(row) })
            }, (row: TimelineMixItem) => row.key)
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
