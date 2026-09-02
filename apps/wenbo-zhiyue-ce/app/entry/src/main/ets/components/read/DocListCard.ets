import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ReadingDoc } from '../../models/FolioModels'
import { FolioStore } from '../../services/FolioStore'

@Component
export struct DocListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop formatLabel: string = ''
  @Prop progressLabel: string = ''
  @Prop updatedLabel: string = ''
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Column() {
        AppIcon({ name: 'book', iconSize: 22, color: '#FFFFFF' })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .borderRadius(12)
      .backgroundColor(Theme.colors().brandPrimary)

      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.formatLabel} · 进度 ${this.progressLabel}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.updatedLabel)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .constraintSize({ minHeight: 72 })
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick((): void => { this.onTap() })
  }
}

export class DocCardBinder {
  static progressOf(doc: ReadingDoc): string {
    return doc.progressLabel()
  }

  static dateOf(doc: ReadingDoc): string {
    return FolioStore.timeLabel(doc.lastReadAt > 0 ? doc.lastReadAt : doc.createdAt)
  }
}
