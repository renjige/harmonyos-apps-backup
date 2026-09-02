import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { EngProjectView } from '../../services/BizService'

@Component
export struct ZhukeProjectCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: EngProjectView = new EngProjectView()
  onTap: () => void = () => {}

  private statusColor(): string {
    if (this.item.statusCode === 'in_progress') {
      return Theme.colors().brandPrimary
    }
    if (this.item.statusCode === 'accepting') {
      return Theme.colors().warning
    }
    if (this.item.statusCode === 'archived') {
      return Theme.colors().textTertiary
    }
    return Theme.colors().info
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: Theme.space.s1 }) {
          Text(this.item.name)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.item.code)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.item.status)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.statusColor())
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Column({ space: Theme.space.s1 }) {
        Row() {
          Text('施工进度')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Blank()
          Text(`${this.item.progressPct}%`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .width('100%')
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(6)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
          Row()
            .width(`${Math.min(this.item.progressPct, 100)}%`)
            .height(6)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
      }

      Row() {
        Row({ space: Theme.space.s1 }) {
          AppIcon({ name: 'user', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
          Text(this.item.managerName.length > 0 ? this.item.managerName : '待指定')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        Blank()
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow(Theme.cardShadow())
    .onClick(() => this.onTap())
  }
}
