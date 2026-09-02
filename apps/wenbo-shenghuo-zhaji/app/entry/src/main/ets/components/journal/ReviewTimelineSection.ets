import { Theme } from '../design-system/Theme'
import { JournalItem } from '../../models/JournalModels'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct ReviewTimelineSection {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: JournalItem[] = []

  private kindLabel(item: JournalItem): string {
    if (item.kind === 'album') {
      return '相册'
    }
    return '札记'
  }

  private openItem(item: JournalItem): void {
    if (item.kind === 'album') {
      JournalDetailNav.openAlbum(item.id)
      return
    }
    JournalDetailNav.openDiary(item.id)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('回忆时间轴')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')

      if (this.items.length === 0) {
        Text('登录并创建札记或相册后，这里会按时间串联你的记录。')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.items, (item: JournalItem) => {
          Row({ space: Theme.space.s3 }) {
            Image(JournalMedia.coverMedia(item.coverKey))
              .width(56)
              .height(56)
              .borderRadius(Theme.radius.md)
              .objectFit(ImageFit.Cover)
            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(this.kindLabel(item))
                  .fontSize(Theme.type.overline)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                if (item.category.length > 0) {
                  Text(MoodCatalog.labelOf(item.category))
                    .fontSize(Theme.type.overline)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
              }
              Text(item.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
              Text(item.recordDate.length > 0 ? item.recordDate : item.createdAt.slice(0, 10))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.openItem(item) })
        }, (item: JournalItem) => `tl_${item.id}`)
      }
    }
    .width('100%')
  }
}
