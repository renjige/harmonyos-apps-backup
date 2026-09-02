import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { UserKnowledge, KnowledgeCategory } from '../../models/UserKnowledgeModels'

@Component
export struct KnowledgeListCard {
  @Prop item: UserKnowledge = new UserKnowledge()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(this.item.title.length > 0 ? this.item.title : '未命名知识')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(2)
          .width('100%')
        Text(`${KnowledgeCategory.emojiOf(this.item.categoryKey)} ${KnowledgeCategory.labelOf(this.item.categoryKey)}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => this.onTap())
  }
}
