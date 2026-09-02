import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SportRecord, SportTypeOption } from '../../models/SportRecord'
import { WatchStatus } from '../../models/CollectModels'
import { SportAccent } from './SportAccent'
import { StarRow, StatusBadge } from './SportVisual'

@Component
export struct RecordCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: SportRecord = new SportRecord()
  onTap: () => void = () => {}

  private statusTone(): string {
    const st = WatchStatus.normalize(this.record.status)
    if (st === 'want') {
      return 'want'
    }
    if (st === 'focus') {
      return 'focus'
    }
    return 'watched'
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Column()
          .width(76)
          .height(76)
          .borderRadius(Theme.radius.md)
          .backgroundColor(SportAccent.softBg(this.record.sportType))
        Text(SportTypeOption.emojiOf(this.record.sportType))
          .fontSize(28)
          .width(76)
          .height(76)
          .textAlign(TextAlign.Center)
        Column()
          .width(76)
          .height(4)
          .backgroundColor(SportAccent.colorOf(this.record.sportType))
          .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
          .position({ x: 0, y: 72 })
      }
      .width(76)
      .height(76)

      Column({ space: 6 }) {
        Row({ space: Theme.space.s2 }) {
          Text(this.record.title.length > 0 ? this.record.title : '未命名赛事')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          if (this.record.pinned) {
            Text('📌')
              .fontSize(12)
          }
          StatusBadge({
            label: WatchStatus.label(this.record.status),
            tone: this.statusTone()
          })
        }
        .width('100%')

        Text(`${SportTypeOption.labelOf(this.record.sportType)} · ${this.record.date}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

        if (this.record.rating > 0) {
          StarRow({ rating: this.record.rating })
        }

        Text(this.record.summaryLine())
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 6, color: 'rgba(15,23,42,0.05)', offsetY: 2 })
    .onClick((): void => { this.onTap() })
  }
}
