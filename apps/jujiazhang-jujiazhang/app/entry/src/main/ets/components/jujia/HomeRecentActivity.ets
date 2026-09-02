import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ActivityEvent } from '../../models/JujiaModels'
import { ActivityService } from '../../services/ActivityService'

@Component
export struct HomeRecentActivity {
  @Prop items: ActivityEvent[] = []
  onOpenAll: () => void = () => {}
  onTapItem: (ev: ActivityEvent) => void = (_e: ActivityEvent) => {}

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('最近动态')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('查看全部')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => this.onOpenAll())
      }
      .width('100%')
      if (this.items.length === 0) {
        Text('完成计划、登记物品或写备忘后，这里会留下家庭足迹。')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
      } else {
        ForEach(this.items, (ev: ActivityEvent) => {
          Row({ space: 10 }) {
            AppIcon({ name: 'clock', iconSize: 16, color: Theme.colors().textSecondary })
            Column({ space: 2 }) {
              Text(ev.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`${ActivityService.formatTime(ev.occurredAt)} · ${ev.summary}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onTapItem(ev))
        }, (ev: ActivityEvent) => `${ev.id}_${ev.occurredAt}`)
      }
    }
    .width('100%')
  }
}
