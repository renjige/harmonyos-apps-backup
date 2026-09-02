import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CwGoal } from '../../models/ChenwuModels'
import { ChenwuMedia } from '../../services/ChenwuMedia'

@Component
export struct GoalListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop goal: CwGoal = new CwGoal()
  @Prop categoryLabel: string = ''
  @Prop coverKey: string = 'cover_goal_learn'
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(ChenwuMedia.coverOf(this.coverKey))
        .width(56)
        .height(56)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)

      Column({ space: 4 }) {
        Text(this.goal.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.categoryLabel} · 进度 ${this.goal.progress}%`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
        Progress({ value: this.goal.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(4)
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
        if (this.goal.description.length > 0) {
          Text(this.goal.description)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onOpen() })
  }
}
