import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { HandcraftWork } from '../../models/HandcraftModels'
import { CraftMedia } from '../../services/CraftMedia'

@Component
export struct WorkListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop work: HandcraftWork = new HandcraftWork()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Stack() {
        Column()
          .width(this.compact ? 72 : 88)
          .height(this.compact ? 72 : 88)
          .backgroundColor(CraftMedia.categoryTint(this.work.category))
          .borderRadius(Theme.radius.lg)
        Image(CraftMedia.byKey(this.work.coverKey))
          .width(this.compact ? 72 : 88)
          .height(this.compact ? 72 : 88)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
      }

      Column({ space: 6 }) {
        Row() {
          Text(this.work.category)
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().brandDeep)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().successContainer)
            .borderRadius(Theme.radius.pill)
        }.width('100%')
        Text(this.work.title)
          .fontSize(this.compact ? Theme.type.subhead : Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.work.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(this.compact ? 1 : 2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: Theme.space.s3 }) {
          if (this.work.userName.length > 0) {
            Text(this.work.userName)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
        }.width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 12,
      color: 'rgba(61,58,54,0.06)',
      offsetY: 2
    })
    .onClick(() => this.onTap())
  }
}
