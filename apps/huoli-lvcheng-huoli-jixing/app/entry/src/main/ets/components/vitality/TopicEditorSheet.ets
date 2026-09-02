import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { VitalityTopic } from '../../models/VitalityModels'

@Component
export struct TopicEditorSheet {
  @Prop visible: boolean = false
  @Prop editingTopic: VitalityTopic | undefined = undefined
  onClose: () => void = () => {}
  onSave: (topic: VitalityTopic) => void = () => {}

  @State titleText: string = ''
  @State emojiText: string = ''

  aboutToAppear(): void {
    if (this.editingTopic !== undefined) {
      this.titleText = this.editingTopic.title
      this.emojiText = this.editingTopic.emoji
    }
  }

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)
          .onClick((): void => this.onClose())

        Column({ space: Theme.space.s4 }) {
          Text(this.editingTopic !== undefined ? '编辑专题' : '新建活力专题')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.emojiText, placeholder: '点缀符号（如 恢复周）' })
            .onChange((v: string): void => { this.emojiText = v })
          TextInput({ text: this.titleText, placeholder: '专题名称' })
            .onChange((v: string): void => { this.titleText = v })
          Text('创建后可在专题详情中添加打卡日与笔记')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          Column() {
            AppButton({
              label: '保存专题',
              variant: 'primary',
              onTap: (): void => {
                const t = this.editingTopic !== undefined ? this.editingTopic : new VitalityTopic()
                if (t.id.length === 0) {
                  t.id = `topic-${Date.now()}`
                  t.noteIds = ''
                  t.recordKeys = ''
                  t.createdAt = Date.now()
                }
                t.title = this.titleText.trim().length > 0 ? this.titleText.trim() : '我的专题'
                t.emoji = this.emojiText.trim().length > 0 ? this.emojiText.trim() : '专题'
                t.updatedAt = Date.now()
                this.onSave(t)
              }
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      }
      .width('100%')
      .height('100%')
      .zIndex(50)
    }
  }
}
