import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { KnowledgeObject } from '../../models/KnowledgeModels'
import { GewuTopic } from '../../models/FieldModels'
import { FieldStore } from '../../services/FieldStore'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { KnowledgeCatalog } from '../../services/KnowledgeCatalog'

@Component
export struct TopicEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('practiceFocusId') @Watch('onFocusChange') focusId: string = ''
  onSaved: () => void = () => {}
  @State title: string = ''
  @State picked: string[] = []
  @State pool: KnowledgeObject[] = []
  @State toastText: string = ''
  @State loadedId: string = ''

  aboutToAppear(): void {
    void this.hydrate()
  }

  onFocusChange(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    this.pool = KnowledgeCatalog.loadPool()
    if (this.focusId.length === 0 || this.focusId === 'new') {
      this.title = ''
      this.picked = []
      this.loadedId = ''
      return
    }
    const t = await FieldStore.findTopic(this.focusId)
    if (t === undefined) {
      this.loadedId = ''
      return
    }
    this.loadedId = t.id
    this.title = t.title
    this.picked = t.objectIds
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private toggle(id: string): void {
    const next: string[] = []
    let removed = false
    for (const item of this.picked) {
      if (item === id) {
        removed = true
      } else {
        next.push(item)
      }
    }
    if (!removed) {
      if (next.length >= 16) {
        this.showToast('一份专题最多收录 16 件')
        return
      }
      next.push(id)
    }
    this.picked = next
  }

  private isPicked(id: string): boolean {
    return this.picked.indexOf(id) >= 0
  }

  private async save(): Promise<void> {
    const topic = new GewuTopic()
    topic.id = this.loadedId
    topic.title = this.title
    topic.objectIds = this.picked
    const ok = await FieldStore.saveTopic(topic)
    if (!ok) {
      this.showToast('请填写专题名称')
      return
    }
    this.onSaved()
    this.showToast('专题册已保存')
    setTimeout((): void => { GewuDetailNav.closePractice() }, 400)
  }

  build() {
    Stack() {
      DetailShell({
        title: this.loadedId.length > 0 ? '编辑专题' : '新建专题册',
        onClose: (): void => { GewuDetailNav.closePractice() },
        body: (): void => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Body() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('给一组知识物起专题名，例如「庭院植物」「案头器物」。点选图鉴收录，形成你自己的集册。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.title, placeholder: '专题名称' })
            .width('100%')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .placeholderColor(Theme.colors().textTertiary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .padding(12)
            .onChange((v: string): void => { this.title = v })
          Text(`已选 ${this.picked.length} / 16`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
          ForEach(this.pool, (item: KnowledgeObject) => {
            Row() {
              Text(this.isPicked(item.id) ? '已收录' : '收录')
                .fontSize(Theme.type.caption)
                .fontColor(this.isPicked(item.id) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(this.isPicked(item.id) ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
              Column({ space: 2 }) {
                Text(item.title)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                Text(item.atlasKind)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .onClick((): void => { this.toggle(item.id) })
          }, (item: KnowledgeObject) => item.id)
          AppButton({
            label: '保存专题册',
            variant: 'primary',
            onTap: (): void => { void this.save() }
          })
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
  }
}
