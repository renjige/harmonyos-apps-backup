import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TimelineNode } from '../../models/ArchiveModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct TimelineRail {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop nodes: TimelineNode[] = []
  @Prop archiveTitles: string[] = []
  onNodeTap: (nodeId: string) => void = () => {}

  build() {
    if (this.nodes.length === 0) {
      Column({ space: Theme.space.s2 }) {
        AppIcon({ name: 'empty', iconSize: Theme.icon.lg, color: Theme.colors().textTertiary })
        Text('暂无时间节点')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
      }
      .width('100%')
      .padding(Theme.space.s6)
      .alignItems(HorizontalAlign.Center)
    } else {
      Column({ space: 0 }) {
        ForEach(this.nodes, (node: TimelineNode, index: number) => {
          this.RailItem(node, index)
        }, (node: TimelineNode) => node.id)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  RailItem(node: TimelineNode, index: number) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Column()
          .width(10)
          .height(10)
          .backgroundColor(Theme.colors().brandAccent)
          .borderRadius(Theme.radius.pill)
        if (index < this.nodes.length - 1) {
          Column()
            .width(2)
            .height(48)
            .backgroundColor(Theme.colors().strokeStrong)
        }
      }
      .width(20)
      .alignItems(HorizontalAlign.Center)

      Column({ space: Theme.space.s1 }) {
        Text(DateHelper.displayDate(node.dateKey))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
        Text(node.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (node.whatHappened.length > 0) {
          Text(node.whatHappened)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .padding({ bottom: Theme.space.s4 })
      .alignItems(HorizontalAlign.Start)
      .onClick((): void => { this.onNodeTap(node.id) })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
