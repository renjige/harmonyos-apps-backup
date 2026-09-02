import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RenoDates, RenoProject } from '../../models/RenoModels'
import { RenoMedia } from '../../services/RenoMedia'

@Component
export struct ProjectCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoProject = new RenoProject()
  onOpen: (item: RenoProject) => void = (_i: RenoProject) => {}

  build() {
    Column({ space: 10 }) {
      Row() {
        Image(RenoMedia.cover(RenoDates.coverOf(this.item.stage)))
          .width(56)
          .height(56)
          .borderRadius(14)
          .objectFit(ImageFit.Cover)
        Column({ space: 4 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .width('100%')
          Text(`${this.item.houseType} · ${this.item.startDate}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')
      Row() {
        Text(this.item.stage)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.sm)
        Text(this.item.status === 'done' ? '已完成' : '施工中')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .margin({ left: 8 })
        Blank()
        Text(`${this.item.progress}%`)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .width('100%')
      Progress({ value: this.item.progress, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(6)
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(3)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .shadow({ radius: 8, color: 'rgba(10,37,64,0.06)', offsetY: 1, offsetX: 0 })
    .onClick(() => this.onOpen(this.item))
  }
}
