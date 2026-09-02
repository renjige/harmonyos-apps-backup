import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MicroEssay, SenseOption } from '../../models/EssayModels'
import { DateHelper } from '../../services/DateHelper'
import { ImagePathUtil } from '../../services/ImagePathUtil'

@Component
export struct EssayListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop essay: MicroEssay = new MicroEssay()
  @Prop fontScale: number = 1
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.essay.imagePath.length > 0) {
        Image(ImagePathUtil.toDisplayUri(this.essay.imagePath))
          .width(72)
          .height(72)
          .borderRadius(Theme.radius.md)
          .objectFit(ImageFit.Cover)
      } else {
        Image($r('app.media.banner_ink'))
          .width(72)
          .height(72)
          .borderRadius(Theme.radius.md)
          .objectFit(ImageFit.Cover)
          .opacity(0.85)
      }

      Column({ space: Theme.space.s1 }) {
        Row({ space: 6 }) {
          Text(this.essay.title.length > 0 ? this.essay.title : '无标题')
            .fontSize(Theme.type.subhead * this.fontScale)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.kindLabel().length > 0) {
            Text(this.kindLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }
          if (this.essay.favorite) {
            AppIcon({ name: 'heart', iconSize: Theme.icon.sm, color: Theme.colors().danger })
          }
        }
        .width('100%')
        Text(this.essay.previewSummary(50))
          .fontSize(Theme.type.bodyS * this.fontScale)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.metaLine())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({ radius: 8, color: 'rgba(26,42,58,0.06)', offsetY: 2 })
    .onClick((): void => { this.onTap() })
  }

  private kindLabel(): string {
    if (this.essay.kind === 'contrast' || this.essay.tagsCsv.indexOf('对照') >= 0) {
      return '对照'
    }
    if (this.essay.kind === 'card') {
      return '五感卡'
    }
    if (this.essay.kind === 'free') {
      return '拓展'
    }
    return ''
  }

  private metaLine(): string {
    const obsKey = DateHelper.normalizeKey(this.essay.dateKey)
    const sense = SenseOption.labelOf(this.essay.senseKey)
    if (obsKey.length > 0) {
      const obs = DateHelper.displayDate(obsKey)
      if (sense.length > 0) {
        return `${obs} · ${sense}`
      }
      return obs
    }
    return DateHelper.displayDateTime(this.essay.updatedAt)
  }
}
