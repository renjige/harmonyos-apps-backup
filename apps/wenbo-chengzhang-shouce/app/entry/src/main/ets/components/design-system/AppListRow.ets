import { Theme } from './Theme'
import { AppIcon } from './AppIcon'

/**
 * Settings / list navigation row — HCDS + HarmonyOS Symbol chevron.
 */
@Component
export struct AppListRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop showDivider: boolean = true
  @Prop danger: boolean = false
  onTap: () => void = () => {}

  build() {
    Column() {
      Row() {
        Column({ space: Theme.space.s1 }) {
          Text(this.title)
            .fontSize(Theme.type.body)
            .fontColor(this.danger ? Theme.colors().danger : Theme.colors().textPrimary)
            .width('100%')
          if (this.subtitle.length > 0) {
            Text(this.subtitle)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
      }
      .width('100%')
      .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })
      .alignItems(VerticalAlign.Center)

      if (this.showDivider) {
        Divider()
          .color(Theme.colors().strokeHairline)
          .strokeWidth(1)
      }
    }
    .width('100%')
    .onClick(() => this.onTap())
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}

@Component
export struct AppSectionLabel {
  @Prop label: string = ''

  build() {
    Text(this.label)
      .fontSize(Theme.type.overline)
      .fontColor(Theme.colors().textTertiary)
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s2
      })
  }
}
