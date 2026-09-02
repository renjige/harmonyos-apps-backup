import { Theme } from '../design-system/Theme'
import { TodoRow, TodoRowBinder } from './TodoRow'
import { MomentTodo } from '../../models/MomentModels'

@Component
export struct TodoBucketSection {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop highlightId: string = ''
  @Prop items: MomentTodo[] = []
  onToggle: (id: string) => void = (id: string) => {
    if (id.length === 0) {
      return
    }
  }
  onOpen: (id: string) => void = (id: string) => {
    if (id.length === 0) {
      return
    }
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.items, (t: MomentTodo) => {
        TodoRow({
          todoId: t.id,
          content: t.content,
          done: t.isCompleted,
          priorityColor: t.priorityColor(),
          meta: TodoRowBinder.meta(t),
          highlight: this.highlightId === t.id,
          onToggle: (): void => this.onToggle(t.id),
          onOpen: (): void => this.onOpen(t.id)
        })
      }, (t: MomentTodo) => `${t.id}_${t.isCompleted ? '1' : '0'}_${t.updatedAt}`)
    }
    .width('100%')
  }
}
