import { Theme } from '../design-system/Theme'
import { DeskAction } from '../../models/ResearchModels'
import { ResearchNav } from '../../services/ResearchNav'

@Component
export struct ResearchDeskGrid {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  private actions: DeskAction[] = DeskAction.all()

  private handlePick(key: string): void {
    if (key === 'notes') {
      ResearchNav.open('notes')
      return
    }
    ResearchNav.open(key)
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(this.actions, (a: DeskAction) => {
        Column({ space: 4 }) {
          Text(a.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
            .width('100%')
          Text(a.hint)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .maxLines(2)
            .width('100%')
        }
        .width('48%')
        .constraintSize({ minHeight: 72 })
        .padding(Theme.space.s3)
        .margin({ bottom: 8 })
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
        .borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
        .onClick((): void => { this.handlePick(a.key) })
      }, (a: DeskAction) => a.key)
    }
    .width('100%')
  }
}
