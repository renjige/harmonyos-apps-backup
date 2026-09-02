import { Theme } from '../design-system/Theme'
import { LifeTimelineGroup, LifeNoteItem } from '../../models/LifeModels'
import { LifeNoteCard } from './LifeNoteCard'
import { LifeDetailNav } from '../../services/LifeDetailNav'

@Component
export struct LifeTimelineGroupView {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop group: LifeTimelineGroup = new LifeTimelineGroup()

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text(this.group.displayLabel)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandDeep)
        Blank()
        Text(`${this.group.notes.length} 条`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')

      ForEach(this.group.notes, (note: LifeNoteItem) => {
        LifeNoteCard({
          note: note,
          onTap: (): void => { LifeDetailNav.openNote(note.id) }
        })
      }, (note: LifeNoteItem) => note.id)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
