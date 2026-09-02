import { Theme } from '../design-system/Theme'
import { YunNoteItem } from '../../models/YunModels'
import { YunTagChips } from './YunTagChips'
import { YunSandboxImage } from './YunSandboxImage'
import { YunDateHelper } from '../../services/YunLocalStore'

@Component
export struct YunNoteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop note: YunNoteItem = new YunNoteItem()
  onTap: () => void = () => {}

  private displayClock(): string {
    const ts = YunDateHelper.effectiveTs(this.note.createdAt, this.note.updatedAt, this.note.id)
    return YunDateHelper.formatClock(ts)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Row({ space: Theme.space.s3 }) {
        Column({ space: 4 }) {
          Text(this.note.title.length > 0 ? this.note.title : '无标题')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.note.category.length > 0 || this.note.mood.length > 0) {
            Text(`${this.note.category}${this.note.mood.length > 0 ? ' · ' + this.note.mood : ''}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
          }
          Text(this.note.summary(80))
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(18)
          if (this.note.tags.length > 0) {
            YunTagChips({ tags: this.note.tags, compact: true })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.note.imagePaths.length > 0) {
          Stack() {
            YunSandboxImage({ srcPath: this.note.imagePaths[0], imgWidth: 64, imgHeight: 64, radius: Theme.radius.sm })
            if (this.note.imagePaths.length > 1) {
              Text(`+${this.note.imagePaths.length - 1}`)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor('rgba(0,0,0,0.55)')
                .borderRadius(Theme.radius.pill)
                .position({ x: 36, y: 44 })
            }
          }
        }

        Text(this.displayClock())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
