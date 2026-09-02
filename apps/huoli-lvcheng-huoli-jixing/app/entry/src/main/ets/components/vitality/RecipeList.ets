import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MicroAction } from '../../models/VitalityModels'

@Component
export struct RecipeList {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop actions: MicroAction[] = []
  @Prop actionRevision: number = 0
  onToggle: (id: string) => void = () => {}

  private doneCount(): number {
    let c = 0
    for (const a of this.actions) {
      if (a.done) {
        c++
      }
    }
    return c
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: 2 }) {
          Text('今日活力处方')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text('根据刚记录的状态生成 · 非医疗建议')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.actions.length > 0) {
          Text(`${this.doneCount()}/${this.actions.length}`)
            .fontSize(Theme.type.bodyS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      ForEach(this.actions, (a: MicroAction) => {
        Row({ space: Theme.space.s3 }) {
          Column() {
            AppIcon({
              name: 'check',
              iconSize: Theme.icon.sm,
              color: a.done ? Theme.colors().brandOnPrimary : Theme.colors().textTertiary
            })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(a.done ? Theme.colors().success : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .border({
            width: a.done ? 0 : 1,
            color: Theme.colors().strokeHairline
          })

          Column({ space: 4 }) {
            Text(a.title)
              .fontSize(Theme.type.body)
              .fontWeight(a.done ? FontWeight.Regular : FontWeight.Medium)
              .fontColor(a.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
              .decoration({ type: a.done ? TextDecorationType.LineThrough : TextDecorationType.None })
            Text(a.hint)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
        .onClick((): void => this.onToggle(a.id))
      }, (a: MicroAction) => `${a.id}-${a.done ? '1' : '0'}-${this.actionRevision}`)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
