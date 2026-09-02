import { Theme } from '../design-system/Theme'
import { YunTimelineGroup, YunNoteItem } from '../../models/YunModels'
import { YunNoteCard } from './YunNoteCard'
import { YunDetailNav } from '../../services/YunDetailNav'

@Component
export struct YunTimelineGroupView {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop group: YunTimelineGroup = new YunTimelineGroup()

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

      ForEach(this.group.notes, (note: YunNoteItem) => {
        YunNoteCard({
          note: note,
          onTap: (): void => { YunDetailNav.openNote(note.id) }
        })
      }, (note: YunNoteItem) => note.id)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
