import { Theme } from '../design-system/Theme'
import { TeaItem, TeaTypeDef } from '../../models/TeaModels'
import { TeaMedia } from '../../services/TeaMedia'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct TeaCabinetCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop tea: TeaItem = new TeaItem()
  onOpen: () => void = () => {}

  private metaLine(): string {
    const typeName = TeaTypeDef.nameOf(this.tea.typeKey)
    const year = this.tea.yearText.length > 0 ? this.tea.yearText : '年份未填'
    const origin = this.tea.origin.length > 0 ? this.tea.origin : '产地未填'
    return `${typeName} · ${year} · ${origin}`
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(TeaMedia.cabinet())
        .width(84)
        .height(84)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
        .flexShrink(0)

      Column({ space: 6 }) {
        Text(this.tea.name.length > 0 ? this.tea.name : '未命名茶品')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(this.metaLine())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(TeaItem.statusLabel(this.tea.stockStatus))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(VerticalAlign.Center)
    .onClick((): void => { this.onOpen() })
  }
}
