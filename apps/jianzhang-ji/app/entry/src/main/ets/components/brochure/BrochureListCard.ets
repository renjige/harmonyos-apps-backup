import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { BrochureItem } from '../../models/BrochureModels'

@Component
export struct BrochureListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: BrochureItem = new BrochureItem()
  @Prop favorited: boolean = false
  @Prop inCompare: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      Column({ space: 6 }) {
        Row({ space: Theme.space.s2 }) {
          if (this.item.level.length > 0) {
            Text(this.item.level)
              .fontSize(Theme.type.overline)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }
          Text(this.item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          if (this.favorited) {
            AppIcon({ name: 'bookmark', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row({ space: 4 }) {
          AppIcon({ name: 'biz', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
          Text(this.item.metaLine())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
            .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        if (this.item.enrollmentTotal > 0) {
          Row({ space: 4 }) {
            AppIcon({ name: 'calendar', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
            Text(`计划 ${this.item.enrollmentTotal} 人 · ${this.item.majorsPreview(3)}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        } else if (this.item.summary.length > 0 || this.item.majorsPreview(3).length > 0) {
          Text(this.item.summary.length > 0 ? this.item.summary : this.item.majorsPreview(3))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }

        if (this.item.tagList().length > 0 || this.inCompare) {
          Row({ space: 6 }) {
            ForEach(this.item.tagPreview(4), (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.overline)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
            if (this.inCompare) {
              Row({ space: 4 }) {
                AppIcon({ name: 'chart', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                Text('已对比')
                  .fontSize(Theme.type.overline)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .alignItems(VerticalAlign.Center)
            }
          }
          .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 12,
      color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(10,37,64,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .alignItems(VerticalAlign.Center)
    .onClick((): void => { this.onTap() })
  }
}
