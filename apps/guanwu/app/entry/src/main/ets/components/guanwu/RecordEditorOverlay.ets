import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { KindSubtypePicker } from './KindSubtypePicker'
import { CategoryTagFields } from './CategoryTagFields'
import { ObserveRecord, SubtypeOption } from '../../models/ObserveModels'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AppContextService } from '../../services/AppContextService'
import { DateHelper } from '../../services/DateHelper'
import { ObserveStore } from '../../services/ObserveStore'
import { ObserveAtlasStore } from '../../services/ObserveAtlasStore'
import { ObserveImage } from './ObserveImage'

@Component
export struct RecordEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editingRecord: ObserveRecord = new ObserveRecord()
  @Prop isEdit: boolean = false
  onClose: () => void = () => {}
  onSaved: (recordId: string) => void = () => {}
  @State kind: string = 'thought'
  @State subtypeKey: string = ''
  @State content: string = ''
  @State imagePaths: string[] = []
  @State categoryKey: string = 'nature'
  @State tags: string = ''
  @State itemName: string = ''
  @State subjectId: string = ''
  @State toastText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    if (this.isEdit && this.editingRecord.id.length > 0) {
      this.kind = this.editingRecord.kind
      this.subtypeKey = this.editingRecord.subtypeKey
      this.content = this.editingRecord.content
      this.imagePaths = []
      for (const p of this.editingRecord.imagePaths) {
        this.imagePaths.push(p)
      }
      this.categoryKey = this.editingRecord.categoryKey.length > 0 ? this.editingRecord.categoryKey : 'nature'
      this.tags = this.editingRecord.tags
      this.itemName = this.editingRecord.itemName
      this.subjectId = this.editingRecord.subjectId
    } else {
      if (this.editingRecord.kind.length > 0) {
        this.kind = this.editingRecord.kind
      } else {
        this.kind = 'thought'
      }
      const subs = SubtypeOption.forKind(this.kind)
      this.subtypeKey = this.editingRecord.subtypeKey.length > 0 ? this.editingRecord.subtypeKey :
        (subs.length > 0 ? subs[0].key : '')
      this.content = this.editingRecord.content
      this.imagePaths = []
      for (const p of this.editingRecord.imagePaths) {
        this.imagePaths.push(p)
      }
      this.categoryKey = this.editingRecord.categoryKey.length > 0 ? this.editingRecord.categoryKey : 'nature'
      this.tags = this.editingRecord.tags
      this.itemName = this.editingRecord.itemName
      this.subjectId = this.editingRecord.subjectId
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private onKindChanged(key: string): void {
    this.kind = key
    const subs = SubtypeOption.forKind(key)
    this.subtypeKey = subs.length > 0 ? subs[0].key : ''
  }

  private async pickImages(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开相册')
      return
    }
    const remain = 3 - this.imagePaths.length
    if (remain <= 0) {
      this.showToast('最多添加 3 张图片')
      return
    }
    const picked = await PhotoPickService.pickImages(ctx, remain)
    if (picked.length === 0 && PhotoPickService.lastError.length > 0) {
      this.showToast(PhotoPickService.lastError)
      return
    }
    for (const p of picked) {
      if (this.imagePaths.length < 3) {
        this.imagePaths.push(p)
      }
    }
    this.imagePaths = this.imagePaths.slice()
  }

  private removeImage(index: number): void {
    const next: string[] = []
    for (let i = 0; i < this.imagePaths.length; i++) {
      if (i !== index) {
        next.push(this.imagePaths[i])
      }
    }
    this.imagePaths = next
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)

      Column() {
        Row() {
          Text(this.isEdit ? '编辑观察' : '快速记录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text('取消')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => this.onClose())
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            KindSubtypePicker({
              kind: this.kind,
              subtypeKey: this.subtypeKey,
              onKindSelect: (key: string): void => { this.onKindChanged(key) },
              onSubtypeSelect: (key: string): void => { this.subtypeKey = key }
            })

            CategoryTagFields({
              categoryKey: this.categoryKey,
              tags: this.tags,
              itemName: this.itemName,
              onCategory: (key: string): void => { this.categoryKey = key },
              onTags: (value: string): void => { this.tags = value },
              onItemName: (value: string): void => { this.itemName = value }
            })

            TextArea({ text: this.content, placeholder: '写下你此刻观察到的一物、一念或一处光线…' })
              .height(120)
              .maxLength(800)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => { this.content = v })

            Text(`${this.content.length}/800`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .textAlign(TextAlign.End)

            Column({ space: Theme.space.s2 }) {
              AppButton({
                label: '添加图片',
                variant: 'secondary',
                disabled: this.imagePaths.length >= 3,
                onTap: (): void => { void this.pickImages() }
              })
              Text(`已选 ${this.imagePaths.length}/3 张，支持相册多选`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')

            if (this.imagePaths.length > 0) {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.imagePaths, (path: string, idx: number) => {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      ObserveImage({ path: path, imgWidth: 96, imgHeight: 96 })
                      Text('×')
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                        .width(22)
                        .height(22)
                        .textAlign(TextAlign.Center)
                        .backgroundColor('rgba(0,0,0,0.45)')
                        .borderRadius(11)
                        .onClick((): void => this.removeImage(idx))
                    }
                  }, (path: string) => path)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .width('100%')
            }
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s6 })
        }
        .layoutWeight(1)

        AppButton({
          label: this.saving ? '保存中…' : '保存观察',
          variant: 'primary',
          disabled: this.saving || this.content.trim().length === 0,
          onTap: (): void => { void this.handleSave() }
        })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  private async handleSave(): Promise<void> {
    if (this.saving) {
      return
    }
    this.saving = true
    const record = this.isEdit && this.editingRecord.id.length > 0 ?
      this.editingRecord : ObserveRecord.createNew(DateHelper.todayKey())
    record.kind = this.kind
    record.subtypeKey = this.subtypeKey
    record.content = this.content
    record.categoryKey = this.categoryKey
    record.tags = this.tags
    record.itemName = this.itemName.trim()
    record.favorited = this.editingRecord.favorited
    record.imagePaths = []
    for (const p of this.imagePaths) {
      record.imagePaths.push(p)
    }
    if (record.itemName.length > 0) {
      const cover = record.imagePaths.length > 0 ? record.imagePaths[0] : ''
      record.subjectId = await ObserveAtlasStore.ensureNamed(record.itemName, this.categoryKey, cover)
    } else {
      record.subjectId = this.subjectId
    }
    const ok = this.isEdit ? await ObserveStore.updateRecord(record) : await ObserveStore.addRecord(record)
    this.saving = false
    if (!ok) {
      this.showToast('保存失败，请检查内容长度')
      return
    }
    this.onSaved(record.id)
  }
}
