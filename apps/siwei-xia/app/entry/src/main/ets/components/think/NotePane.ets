import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { TagChipRow } from '../box/TagChipRow'
import { ThinkNote } from '../../models/ThinkModels'
import { ThinkStore } from '../../services/ThinkStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NotePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPaneReload') paneToken: number = 0
  @State items: ThinkNote[] = []
  @State editing: ThinkNote = new ThinkNote()
  @State editCat: string = '学习思考'
  @State showEdit: boolean = false
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onPaneReload(): void {
    this.showEdit = false
    this.confirmDelete = false
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ThinkStore.loadNotes()
  }

  private openNew(): void {
    const it = new ThinkNote()
    it.id = ThinkStore.newId('nt')
    it.category = '学习思考'
    it.createdAt = Date.now()
    it.updatedAt = it.createdAt
    this.editing = it
    this.editCat = it.category
    this.confirmDelete = false
    this.showEdit = true
  }

  private async save(): Promise<void> {
    if (this.editing.title.trim().length === 0 || this.editing.body.trim().length === 0) {
      this.toastText = '标题和正文都需要填写'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    this.editing.category = this.editCat
    await ThinkStore.saveNote(this.editing)
    this.showEdit = false
    await this.reload()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ThinkStore.removeNote(this.editing.id)
    this.showEdit = false
    await this.reload()
  }

  build() {
    Column() {
      Row() {
        Text('思维笔记')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('新建')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.openNew() })
      }
      .width('100%')
      if (this.showEdit) {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.editing.title, placeholder: '标题' })
              .height(44)
              .onChange((v: string) => { this.editing.title = v })
            TagChipRow({
              namesCsv: '学习思考,工作想法,创意记录,问题分析',
              selectedCsv: this.editCat,
              onToggle: (name: string): void => {
                this.editCat = name
                this.editing.category = name
              }
            })
            TextArea({ text: this.editing.body, placeholder: '记下观点、推理或尚未成形的理解' })
              .height(180)
              .onChange((v: string) => { this.editing.body = v })
            AppButton({ label: '保存笔记', onTap: (): void => { void this.save() } })
            AppButton({ label: '返回列表', variant: 'secondary', onTap: (): void => { this.showEdit = false } })
            AppButton({
              label: this.confirmDelete ? '再点一次删除' : '删除',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.items.length === 0) {
              AppEmpty({ title: '还没有思维笔记', description: '用标题 + 正文建立个人思考档案' })
            } else {
              ForEach(this.items, (it: ThinkNote) => {
                Column({ space: 6 }) {
                  Text(it.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${it.category} · ${DateHelper.formatShort(it.updatedAt)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  Text(it.body)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(3)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => {
                  this.editing = ThinkStore.cloneNote(it)
                  this.editCat = it.category
                  this.confirmDelete = false
                  this.showEdit = true
                })
              }, (it: ThinkNote) => `${it.id}|${it.updatedAt}`)
            }
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
        .edgeEffect(EdgeEffect.Spring)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.md)
      }
    }
    .width('100%')
    .height('100%')
  }
}
