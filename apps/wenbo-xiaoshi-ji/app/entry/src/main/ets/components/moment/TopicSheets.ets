import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { TopicCollection, MomentNote } from '../../models/MomentModels'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'
import { NoteCard, NoteCardBinder } from './NoteCard'

@Component
export struct TopicEditorSheet {
  @Prop topicId: string = ''
  onDone: () => void = () => {}
  @State title: string = ''
  @State color: string = '#C44A22'

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.topicId.length === 0) {
      return
    }
    const t = await MomentStore.findTopic(this.topicId)
    if (t !== undefined) {
      this.title = t.title
      this.color = t.coverColor
    }
  }

  private async save(): Promise<void> {
    let topic: TopicCollection
    if (this.topicId.length > 0) {
      const found = await MomentStore.findTopic(this.topicId)
      topic = found !== undefined ? found : TopicCollection.createNew()
    } else {
      topic = TopicCollection.createNew()
    }
    topic.title = this.title
    topic.coverColor = this.color
    const ok = await MomentStore.saveTopic(topic)
    if (ok) {
      if (this.topicId.length === 0) {
        MomentNav.openTopic(topic.id)
      } else {
        this.onDone()
      }
    }
  }

  build() {
    DetailShell({ title: '生活专题', onClose: (): void => MomentNav.close() }) {
      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.title, placeholder: '专题名称，如家庭片段 / 2026 旅行' })
          .width('100%')
          .onChange((v: string): void => { this.title = v })
        AppButton({ label: '保存', onTap: (): void => { void this.save() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      .width('100%')
    }
  }
}

@Component
export struct TopicListPane {
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @State topics: TopicCollection[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.topics = await MomentStore.loadTopics()
  }

  build() {
    DetailShell({ title: '生活专题', onClose: (): void => MomentNav.close() }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          AppButton({ label: '新建专题', onTap: (): void => MomentNav.openTopicEditor('') })
          if (this.topics.length === 0) {
            AppEmpty({
              title: '还没有专题',
              description: '把星标或标签相关的小事收成主题合集'
            })
          } else {
            ForEach(this.topics, (t: TopicCollection) => {
              Row({ space: Theme.space.s3 }) {
                Row()
                  .width(8)
                  .height(40)
                  .backgroundColor(t.coverColor)
                  .borderRadius(4)
                Column({ space: 2 }) {
                  Text(t.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${t.noteIds.length} 条小事`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(12)
              .onClick((): void => MomentNav.openTopic(t.id))
            }, (t: TopicCollection) => `${t.id}_${t.updatedAt}`)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
  }
}

@Component
export struct TopicDetailPane {
  @Prop topicId: string = ''
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @State topic: TopicCollection | undefined = undefined
  @State notes: MomentNote[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.topic = await MomentStore.findTopic(this.topicId)
    this.notes = await MomentStore.notesInTopic(this.topicId)
  }

  build() {
    DetailShell({ title: '专题详情', onClose: (): void => MomentNav.openTopics() }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.topic === undefined) {
            AppEmpty({ title: '专题不存在' })
          } else {
            Text(this.topic.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (this.notes.length === 0) {
              AppEmpty({
                title: '专题里还没有小事',
                description: '在小事详情页可加入本专题（后续版本）或从星标整理'
              })
            } else {
              ForEach(this.notes, (n: MomentNote) => {
                NoteCard({
                  noteId: n.id,
                  content: n.content,
                  tagsText: NoteCardBinder.tagsText(n),
                  stripe: n.stripeColor(),
                  timeLabel: NoteCardBinder.timeLabel(n),
                  pinned: n.pinned,
                  onOpen: (): void => MomentNav.openNote(n.id)
                })
              }, (n: MomentNote) => n.id)
            }
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
  }
}
