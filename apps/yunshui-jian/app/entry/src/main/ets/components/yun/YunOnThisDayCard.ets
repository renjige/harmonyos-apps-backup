import { Theme } from '../design-system/Theme'
import { YunNoteItem } from '../../models/YunModels'
import { YunDateHelper } from '../../services/YunLocalStore'
import { YunDetailNav } from '../../services/YunDetailNav'

@Component
export struct YunOnThisDayCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop notes: YunNoteItem[] = []

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('去年今天')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandDeep)
      Text('根据已写下的札记，在应用内回顾同一天（不发送系统通知）')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(18)
      ForEach(this.notes, (n: YunNoteItem) => {
        Column({ space: Theme.space.s1 }) {
          Text(n.title.length > 0 ? n.title : '无标题札记')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .maxLines(1)
          Text(YunDateHelper.formatDateTime(YunDateHelper.effectiveTs(n.createdAt, n.updatedAt, n.id)))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onClick((): void => { YunDetailNav.openNote(n.id) })
      }, (n: YunNoteItem) => n.id)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
