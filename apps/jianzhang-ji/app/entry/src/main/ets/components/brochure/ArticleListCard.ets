import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ArticleItem } from '../../models/BrochureModels'

/** 资讯列表卡片 — Symbol 封面 + 现代卡片样式 */
@Component
export struct ArticleListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ArticleItem = new ArticleItem()
  onTap: () => void = () => {}

  private metaLine(): string {
    if (this.item.readMinutes > 0) {
      return `约 ${this.item.readMinutes} 分钟阅读`
    }
    return '政策解读'
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: 'book', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: Theme.space.s1 }) {
          AppIcon({ name: 'calendar', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
          Text(this.metaLine())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
        }
        .alignItems(VerticalAlign.Center)
        Text(this.item.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
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
    .onClick((): void => { this.onTap() })
  }
}
