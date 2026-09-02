import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { Archive } from '../../models/ArchiveModels'

@Component
export struct ArchiveCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop archive: Archive = new Archive()
  @Prop categoryLabel: string = ''
  @Prop nodeCount: number = 0
  @Prop completion: number = 0
  onTap: () => void = () => {}

  build() {
    AppCard({
      variant: 'plain',
      onTap: (): void => { this.onTap() }
    }) {
      Column({ space: Theme.space.s2 }) {
        Row() {
          Text(this.archive.yearLabel())
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().brandAccent)
            .fontWeight(FontWeight.Medium)
          Blank()
          if (this.archive.status === 'pending') {
            Text('待整理')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().warning)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(Theme.colors().warningContainer)
              .borderRadius(Theme.radius.pill)
          }
        }
        .width('100%')

        Text(this.archive.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.archive.rangeLabel())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)

        Row({ space: Theme.space.s2 }) {
          Text(this.categoryLabel)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
          Text(`${this.nodeCount} 个节点`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
          Blank()
          Text(`${this.completion}%`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
