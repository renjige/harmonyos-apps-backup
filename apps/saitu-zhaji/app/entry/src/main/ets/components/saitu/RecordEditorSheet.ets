import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppTextField } from '../design-system/AppTextField'
import { Journey, SaituRecord } from '../../models/SaituModels'
import { AppContextService } from '../../services/AppContextService'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { PhotoPickService } from '../../services/PhotoPickService'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct RecordEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituEditorRecordId') @Watch('onTargetChange') editorId: string = ''
  @Prop @Watch('onTargetChange') editorSession: number = 0
  onSaved: () => void = () => {}
  @State content: string = ''
  @State tagsInput: string = ''
  @State images: string[] = []
  @State journeys: Journey[] = []
  @State selectedJourneyId: string = ''
  @State toastText: string = ''
  @State isEdit: boolean = false
  private editing: SaituRecord = new SaituRecord()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onTargetChange(): void {
    void this.bootstrap()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async bootstrap(): Promise<void> {
    this.journeys = await SaituLocalStore.loadJourneys()
    const id = this.editorId
    if (id.length > 0) {
      const found = await SaituLocalStore.findRecord(id)
      if (found !== undefined) {
        this.editing = found
        this.content = found.content
        this.tagsInput = found.tags.join(' ')
        this.images = found.images.slice()
        this.selectedJourneyId = found.journeyId
        this.isEdit = true
        return
      }
    }
    this.editing = SaituRecord.createNew()
    this.content = ''
    this.tagsInput = ''
    this.images = []
    this.selectedJourneyId = ''
    this.isEdit = false
  }

  private parseTags(): string[] {
    const parts = this.tagsInput.split(/[\s,，]+/)
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0 && out.indexOf(t) < 0) {
        out.push(t)
      }
    }
    return out
  }

  private async pickPhotos(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开相册')
      return
    }
    const remain = 9 - this.images.length
    if (remain <= 0) {
      this.showToast('最多 9 张图片')
      return
    }
    const picked = await PhotoPickService.pickImages(ctx, remain)
    if (picked.length === 0) {
      if (PhotoPickService.lastError.length > 0) {
        this.showToast(PhotoPickService.lastError)
      }
      return
    }
    const next: string[] = []
    for (const u of this.images) {
      next.push(u)
    }
    for (const u of picked) {
      next.push(u)
    }
    this.images = next
    this.showToast(`已添加 ${picked.length} 张图片`)
  }

  private removeImage(idx: number): void {
    const next: string[] = []
    for (let i = 0; i < this.images.length; i++) {
      if (i !== idx) {
        next.push(this.images[i])
      }
    }
    this.images = next
  }

  private async save(): Promise<void> {
    const trimmed = this.content.trim()
    if (trimmed.length === 0) {
      this.showToast('请填写记录内容')
      return
    }
    if (this.isEdit) {
      if (this.editing.id.length === 0 || this.editing.id !== this.editorId) {
        this.showToast('记录加载中，请稍后再保存')
        return
      }
    }
    this.editing.content = trimmed
    this.editing.tags = this.parseTags()
    this.editing.images = this.images
    this.editing.journeyId = this.selectedJourneyId
    this.editing.location = null
    await SaituLocalStore.saveRecord(this.editing)
    SaituDetailNav.closeEditor()
    this.onSaved()
  }

  @Builder
  JourneyChip(j: Journey) {
    Text(j.name)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.selectedJourneyId === j.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.selectedJourneyId === j.id ? j.color : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.selectedJourneyId = this.selectedJourneyId === j.id ? '' : j.id
      })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: this.isEdit ? '编辑札记' : '新建札记',
          onBack: (): void => SaituDetailNav.closeEditor()
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextArea({ text: this.content, placeholder: '写下此刻的赛途心得…' })
              .height(160)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => { this.content = v })

            Text('标签')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            AppTextField({
              text: this.tagsInput,
              placeholder: '空格或逗号分隔，如 备赛 复盘',
              onChange: (v: string): void => { this.tagsInput = v }
            })

            Text('归属旅途')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.journeys, (j: Journey) => {
                this.JourneyChip(j)
              }, (j: Journey) => j.id)
            }

            AppButton({ label: '添加图片', variant: 'secondary', onTap: (): void => { void this.pickPhotos() } })
            Text('添加后立即在下方显示预览，点按可移除。使用系统相册选择器，不申请相册权限。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            if (this.images.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.images, (uri: string, idx: number) => {
                  Image(ImagePathUtil.toDisplayUri(uri))
                    .width(88)
                    .height(88)
                    .borderRadius(Theme.radius.sm)
                    .objectFit(ImageFit.Cover)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => this.removeImage(idx))
                }, (uri: string, idx: number) => `${idx}_${uri}`)
              }
            }

            AppButton({ label: this.isEdit ? '保存修改' : '保存', variant: 'primary', onTap: (): void => { void this.save() } })
            Blank().height(Theme.space.s10)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
