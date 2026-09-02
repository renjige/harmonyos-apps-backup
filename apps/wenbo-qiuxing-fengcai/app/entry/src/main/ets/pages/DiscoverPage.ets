import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AthletesPage } from './AthletesPage'
import { EventsPage } from './EventsPage'

class DiscoverSegment {
  key: string = 'athletes'
  label: string = ''

  static all(): DiscoverSegment[] {
    const out: DiscoverSegment[] = []
    const a = new DiscoverSegment()
    a.key = 'athletes'
    a.label = '球星'
    out.push(a)
    const e = new DiscoverSegment()
    e.key = 'events'
    e.label = '赛事'
    out.push(e)
    return out
  }
}

/** 发现 Tab — 球星 + 赛事统一入口 */
@Component
export struct DiscoverPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State segment: string = 'athletes'
  private segments: DiscoverSegment[] = DiscoverSegment.all()

  onRefreshChange(): void {
  }

  build() {
    Column() {
      AppHeader({ title: '发现', subtitle: '搜索 · 分类 · 浏览球星与赛事' })
      Row({ space: Theme.space.s2 }) {
        ForEach(this.segments, (seg: DiscoverSegment) => {
          Text(seg.label)
            .fontSize(Theme.type.subhead)
            .fontWeight(this.segment === seg.key ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.segment === seg.key ?
              Theme.colors().brandPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.segment === seg.key ?
              Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { this.segment = seg.key })
        }, (seg: DiscoverSegment) => seg.key)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      if (this.segment === 'athletes') {
        AthletesPage({
          refreshToken: this.refreshToken,
          embedded: true
        }).layoutWeight(1)
      } else {
        EventsPage({
          refreshToken: this.refreshToken,
          embedded: true
        }).layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
