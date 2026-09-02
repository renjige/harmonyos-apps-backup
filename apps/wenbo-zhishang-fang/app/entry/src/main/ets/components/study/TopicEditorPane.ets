import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { NoteAreaCard, NoteFieldCard } from '../note/NoteFieldCard'
import { OverlayShell } from './OverlayShell'
import { TopicShelf } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct TopicEditorPane {
  @Prop topicId: string = ''
  @State title: string = ''
  @State summary: string = ''
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.topicId.length === 0) {
      return
    }
    const found = await StudyStore.findTopic(this.topicId)
    if (found === undefined) {
      return
    }
    this.title = found.title
    this.summary = found.summary
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写专题名称')
      return
    }
    let topic: TopicShelf
    if (this.topicId.length > 0) {
      const found = await StudyStore.findTopic(this.topicId)
      topic = found ?? TopicShelf.createNew()
    } else {
      topic = TopicShelf.createNew()
    }
    topic.title = this.title.trim()
    topic.summary = this.summary.trim()
    await StudyStore.saveTopic(topic)
    this.showToast('专题已保存')
    this.onSaved()
  }

  build() {
    Stack() {
      OverlayShell({
        title: this.topicId.length > 0 ? '编辑专题' : '新建专题',
        onClose: (): void => { this.onClose() },
        body: (): void => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      NoteFieldCard({
        label: '专题名称 *',
        value: this.title,
        placeholder: '如：2026 哲学书单',
        onChange: (v: string): void => { this.title = v }
      })
      NoteAreaCard({
        label: '专题简介（可选）',
        value: this.summary,
        placeholder: '这个专题收录哪些书摘',
        onChange: (v: string): void => { this.summary = v }
      })
      AppButton({
        label: '保存专题',
        onTap: (): void => { void this.save() }
      })
    }
    .width('100%')
  }
}
