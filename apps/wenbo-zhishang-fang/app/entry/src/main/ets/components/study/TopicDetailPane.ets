import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { NoteListCard } from '../note/NoteListCard'
import { OverlayShell } from './OverlayShell'
import { TopicShelf } from '../../models/StudyModels'
import { BookNote } from '../../models/BookNoteModels'
import { StudyStore } from '../../services/StudyStore'
import { NoteStore } from '../../services/NoteStore'

@Component
export struct TopicDetailPane {
  @Prop topicId: string = ''
  @State topic: TopicShelf = new TopicShelf()
  @State notes: BookNote[] = []
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await StudyStore.findTopic(this.topicId)
    if (found === undefined) {
      return
    }
    this.topic = found
    const out: BookNote[] = []
    for (const id of found.noteIds) {
      const n = await NoteStore.findById(id)
      if (n !== undefined) {
        out.push(n)
      }
    }
    this.notes = out
  }

  build() {
    OverlayShell({
      title: '专题详情',
      showBack: true,
      onClose: (): void => { this.onClose() },
      onBack: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      Column({ space: 6 }) {
        Text(this.topic.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.topic.summary.length > 0) {
          Text(this.topic.summary)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        Text(`${this.notes.length} 条书摘`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(12)

      AppButton({
        label: '编辑专题',
        variant: 'secondary',
        onTap: (): void => { this.onEdit() }
      })

      if (this.notes.length === 0) {
        AppEmpty({
          title: '专题还没有书摘',
          description: '在书摘详情页可将摘录加入本专题'
        })
      } else {
        ForEach(this.notes, (n: BookNote) => {
          NoteListCard({
            item: n,
            onOpen: (): void => { this.onOpenDetail(n.id) }
          })
        }, (n: BookNote) => `${n.id}_${n.updatedAt}`)
      }
    }
    .width('100%')
  }
}
