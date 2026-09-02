import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { MomentTodo } from '../../models/MomentModels'
import { MomentStore } from '../../services/MomentStore'

@Component
export struct TodoEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop todoId: string = ''
  onSaved: () => void = () => {}
  onCancel: () => void = () => {}

  @State content: string = ''
  @State priority: string = 'medium'
  @State bucket: string = 'today'
  @State toast: string = ''
  private draftId: string = ''
  private createdAt: number = 0
  private isCompleted: boolean = false

  aboutToAppear(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    if (this.todoId.length > 0) {
      const found = await MomentStore.findTodo(this.todoId)
      if (found !== undefined) {
        this.draftId = found.id
        this.content = found.content
        this.priority = found.priority
        this.bucket = found.bucket
        this.createdAt = found.createdAt
        this.isCompleted = found.isCompleted
        return
      }
    }
    const t = MomentTodo.createNew()
    this.draftId = t.id
    this.createdAt = t.createdAt
  }

  private chipOn(cur: string, value: string): boolean {
    return cur === value
  }

  private async save(): Promise<void> {
    const t = new MomentTodo()
    t.id = this.draftId
    t.content = this.content
    t.priority = this.priority
    t.bucket = this.bucket
    t.isCompleted = this.isCompleted
    t.createdAt = this.createdAt > 0 ? this.createdAt : Date.now()
    const ok = await MomentStore.saveTodo(t)
    if (ok) {
      this.onSaved()
      return
    }
    this.toast = '请输入待办内容'
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  @Builder
  Chip(label: string, value: string, current: string, onPick: () => void) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.chipOn(current, value) ? '#FFFFFF' : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.chipOn(current, value) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => onPick())
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('取消')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .onClick((): void => this.onCancel())
          Text(this.todoId.length > 0 ? '编辑待办' : '添加待办')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('保存')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => { void this.save() })
        }
        .width('100%')
        .padding({ top: Theme.space.s5 })

        TextInput({ text: this.content, placeholder: '要做的一件小事' })
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .caretColor(Theme.colors().brandPrimary)
          .onChange((v: string): void => { this.content = v })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(16)
          .height(48)

        Text('分组')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.Chip('今日', 'today', this.bucket, (): void => { this.bucket = 'today' })
          this.Chip('本周', 'week', this.bucket, (): void => { this.bucket = 'week' })
          this.Chip('以后', 'later', this.bucket, (): void => { this.bucket = 'later' })
        }

        Text('优先级')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.Chip('高', 'high', this.priority, (): void => { this.priority = 'high' })
          this.Chip('中', 'medium', this.priority, (): void => { this.priority = 'medium' })
          this.Chip('低', 'low', this.priority, (): void => { this.priority = 'low' })
        }

        Blank()
        AppButton({
          label: '保存待办',
          onTap: (): void => { void this.save() }
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 52 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
