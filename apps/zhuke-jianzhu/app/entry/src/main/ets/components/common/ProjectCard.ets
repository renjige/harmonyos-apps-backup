import { Theme } from '../design-system/Theme'
import { ProjectItem } from '../../models/ZhukeModels'
import { ContentService } from '../../services/ContentService'
import { ContentCover } from './ContentCover'

@Component
export struct ProjectCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ProjectItem = new ProjectItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      ContentCover({
        imageKey: this.item.coverKey,
        label: ContentService.projectCategoryLabel(this.item.category),
        coverHeight: 120,
        coverRadius: Theme.radius.md,
        showGradient: true
      })

      Column({ space: Theme.space.s1 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.item.location} · ${this.item.completedAt}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s3 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({
      radius: 8,
      color: Theme.isDark() ? 'rgba(0,0,0,0.25)' : 'rgba(10,37,64,0.06)',
      offsetY: 2
    })
    .clip(true)
    .onClick(() => this.onTap())
  }
}

@Component
export struct ProjectRow {
  @Prop item: ProjectItem = new ProjectItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      ContentCover({
        imageKey: this.item.coverKey,
        coverHeight: 72,
        coverRadius: Theme.radius.sm,
        showGradient: false
      })
      .width(96)

      Column({ space: Theme.space.s1 }) {
        Text(this.item.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${ContentService.projectCategoryLabel(this.item.category)} · ${this.item.location}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .onClick(() => this.onTap())
  }
}
