import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { TimelineNode } from '../../models/ArchiveModels'
import { ArchiveStore } from '../../services/ArchiveStore'
import { ArchiveDetailNav } from '../../services/ArchiveDetailNav'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NodeEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('nodeEditorArchiveId') archiveId: string = ''
  @StorageLink('nodeEditorNodeId') nodeId: string = ''
  onSaved: () => void = () => {}
  @State titleInput: string = ''
  @State dateInput: string = ''
  @State whatInput: string = ''
  @State whyInput: string = ''
  @State feelingInput: string = ''
  @State afterInput: string = ''
  @State tagInput: string = ''
  @State tags: string[] = []
  @State toastText: string = ''
  @State isEdit: boolean = false

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.dateInput = DateHelper.todayKey()
    if (this.nodeId.length > 0) {
      this.isEdit = true
      const found = await ArchiveStore.findNode(this.nodeId)
      if (found !== undefined) {
        this.titleInput = found.title
        this.dateInput = found.dateKey
        this.whatInput = found.whatHappened
        this.whyInput = found.whyImportant
        this.feelingInput = found.feeling
        this.afterInput = found.afterChange
        this.tags = []
        for (const t of found.tags) {
          this.tags.push(t)
        }
      }
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private addTag(): void {
    const t = this.tagInput.trim()
    if (t.length === 0) {
      this.showToast('请输入标签名称')
      return
    }
    for (const existing of this.tags) {
      if (existing === t) {
        this.showToast('标签已存在')
        return
      }
    }
    const next: string[] = []
    for (const existing of this.tags) {
      next.push(existing)
    }
    next.push(t)
    this.tags = next
    this.tagInput = ''
  }

  private removeTag(tag: string): void {
    const next: string[] = []
    for (const existing of this.tags) {
      if (existing !== tag) {
        next.push(existing)
      }
    }
    this.tags = next
  }

  private async handleSave(): Promise<void> {
    const title = this.titleInput.trim()
    if (title.length === 0) {
      this.showToast('请输入节点标题')
      return
    }
    if (this.archiveId.length === 0) {
      this.showToast('档案信息缺失')
      return
    }
    let node: TimelineNode
    if (this.isEdit && this.nodeId.length > 0) {
      const found = await ArchiveStore.findNode(this.nodeId)
      if (found === undefined) {
        this.showToast('节点不存在')
        return
      }
      node = found
    } else {
      node = TimelineNode.createNew(this.archiveId, this.dateInput, title)
    }
    node.title = title
    node.dateKey = this.dateInput
    node.whatHappened = this.whatInput.trim()
    node.whyImportant = this.whyInput.trim()
    node.feeling = this.feelingInput.trim()
    node.afterChange = this.afterInput.trim()
    node.tags = []
    for (const t of this.tags) {
      node.tags.push(t)
    }
    await ArchiveStore.saveNode(node)
    for (const t of this.tags) {
      await ArchiveStore.addTag(t)
    }
    this.onSaved()
    ArchiveDetailNav.closeNodeEditor()
    this.showToast(this.isEdit ? '节点已更新' : '节点已添加')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { ArchiveDetailNav.closeNodeEditor() })
          Text(this.isEdit ? '编辑节点' : '添加节点')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          this.FormBody()
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FormBody() {
    Column({ space: Theme.space.s4 }) {
      this.InputField('节点标题', this.titleInput, '输入节点标题', (v: string): void => { this.titleInput = v })
      this.InputField('日期 YYYY-MM-DD', this.dateInput, '2026-09-01', (v: string): void => { this.dateInput = v })
      this.TextAreaField('发生了什么', this.whatInput, (v: string): void => { this.whatInput = v })
      this.TextAreaField('为何重要', this.whyInput, (v: string): void => { this.whyInput = v })
      this.TextAreaField('当时的感受', this.feelingInput, (v: string): void => { this.feelingInput = v })
      this.TextAreaField('之后的改变', this.afterInput, (v: string): void => { this.afterInput = v })

      Text('节点标签')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.tagInput, placeholder: '输入标签，如 旅行、纪念' })
          .layoutWeight(1)
          .height(48)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding({ left: 14, right: 14 })
          .onChange((v: string): void => { this.tagInput = v })
        Text('添加')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.addTag() })
      }
      .width('100%')

      if (this.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.tags, (tag: string) => {
            Row({ space: 4 }) {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
              Text('×')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.removeTag(tag) })
          }, (tag: string, index: number) => `${tag}_${index}`)
        }
        .width('100%')
      } else {
        Text('还没有标签，输入后点「添加」')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }

      AppButton({
        label: '保存',
        variant: 'primary',
        onTap: (): void => { void this.handleSave() }
      })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
  }

  @Builder
  InputField(label: string, value: string, placeholder: string, onChange: (v: string) => void) {
    Column({ space: Theme.space.s1 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      TextInput({ text: value, placeholder: placeholder })
        .height(48)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textTertiary)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .padding({ left: 14, right: 14 })
        .onChange(onChange)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TextAreaField(label: string, value: string, onChange: (v: string) => void) {
    Column({ space: Theme.space.s1 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      TextArea({ text: value, placeholder: label })
        .height(80)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textTertiary)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .onChange(onChange)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
