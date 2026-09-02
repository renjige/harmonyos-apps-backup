import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MicroGoalItem } from '../../models/MicroGoalModels'

@Component
export struct MicroGoalCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: MicroGoalItem = new MicroGoalItem()
  onComplete: () => void = () => {}
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        if (this.item.status === 'done') {
          AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().success })
        } else {
          AppIcon({ name: 'empty', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.item.status === 'done'
        ? Theme.colors().successContainer
        : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)

      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.item.description.length > 0) {
          Text(this.item.description)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
        }
        if (this.item.note.length > 0) {
          Text(this.item.note)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .maxLines(2)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.item.status !== 'done') {
        Text('完成')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandAccent)
          .borderRadius(Theme.radius.pill)
          .onClick(() => {
            this.onComplete()
          })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => {
      this.onTap()
    })
  }
}
