import { Theme } from '../design-system/Theme'
import { AppBarChart, BarChartItem } from '../design-system/AppChart'
import { DayCount, GewuBadge, GewuEvent } from '../../models/FieldModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct TraceGrowthPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop weekLine: string = ''
  @Prop monthLine: string = ''
  @Prop bars: DayCount[] = []
  @Prop badges: GewuBadge[] = []
  @Prop events: GewuEvent[] = []

  private chartItems(): BarChartItem[] {
    const out: BarChartItem[] = []
    for (const d of this.bars) {
      const item = new BarChartItem()
      item.value = d.count
      item.label = d.label
      out.push(item)
    }
    return out
  }

  private unlockedCount(): number {
    let n = 0
    for (const b of this.badges) {
      if (b.unlocked) {
        n++
      }
    }
    return n
  }

  private kindLabel(kind: string): string {
    if (kind === 'record') {
      return '观察'
    }
    if (kind === 'checkin') {
      return '打卡'
    }
    if (kind === 'fav') {
      return '收藏'
    }
    if (kind === 'read') {
      return '已读'
    }
    if (kind === 'quiz') {
      return '小测'
    }
    if (kind === 'plan') {
      return '功课'
    }
    if (kind === 'topic') {
      return '专题'
    }
    if (kind === 'badge') {
      return '印记'
    }
    return '足迹'
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Column({ space: Theme.space.s2 }) {
        Text('本周 / 本月回顾')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.weekLine)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.monthLine)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)

      if (this.bars.length > 0) {
        AppBarChart({
          title: '近七日观察则数',
          items: this.chartItems()
        })
      }

      Column({ space: Theme.space.s2 }) {
        Text(`成就印记  ${this.unlockedCount()}/${this.badges.length}`)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('印记只按你在本机留下的观察、打卡、收藏与浏览解锁，没有假进度。')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.badges, (b: GewuBadge) => {
            Column({ space: 4 }) {
              Text(b.title)
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(b.unlocked ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              Text(b.hint)
                .fontSize(Theme.type.caption)
                .fontColor(b.unlocked ? Theme.colors().brandOnPrimary : Theme.colors().textTertiary)
            }
            .width('46%')
            .padding(Theme.space.s3)
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(b.unlocked ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .opacity(b.unlocked ? 1 : 0.7)
          }, (b: GewuBadge) => b.id)
        }
        .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)

      Column({ space: Theme.space.s2 }) {
        Text('格物年谱')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.events.length === 0) {
          Text('阅读、观察、收藏、打卡后，这里会按时间串起你的足迹。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        } else {
          ForEach(this.events, (e: GewuEvent) => {
            Row({ space: Theme.space.s3 }) {
              Text(this.kindLabel(e.kind))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width(36)
              Column({ space: 2 }) {
                Text(e.title)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(2)
                  .width('100%')
                Text(DateHelper.displayShort(e.dateKey))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
          }, (e: GewuEvent) => `${e.at}-${e.kind}-${e.refId}`)
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
    }
    .width('100%')
  }
}
