import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CatalogOptions } from '../../services/AnalyzeEngine'
import { PhotoPickService } from '../../services/PhotoPickService'
import { WrongMedia } from '../../services/WrongMedia'
import { CauseOption, SubjectOption, WrongEntry, WrongEntryWrite } from '../../models/WrongModels'

@Component
export struct CaptureOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = 'manual'
  @Prop @Watch('onEditChange') editEntry: WrongEntry = new WrongEntry()
  @State stem: string = ''
  @State correctAnswer: string = ''
  @State wrongAnswer: string = ''
  @State knowledgeTag: string = ''
  @State remark: string = ''
  @State subjectCode: string = 'math'
  @State causeCode: string = 'concept'
  @State photoUri: string = ''
  @State errorText: string = ''
  @State saving: boolean = false
  onClose: () => void = () => {}
  onSave: (write: WrongEntryWrite, editId: string) => void = (_w: WrongEntryWrite, _id: string) => {}

  aboutToAppear(): void {
    this.fillFromEntry()
    if (this.editEntry.id.length === 0 && this.mode === 'photo') {
      void this.pickPhoto(true)
    }
  }

  onEditChange(): void {
    this.fillFromEntry()
  }

  private fillFromEntry(): void {
    if (this.editEntry.id.length > 0) {
      this.stem = this.editEntry.stem
      this.correctAnswer = this.editEntry.correctAnswer
      this.wrongAnswer = this.editEntry.wrongAnswer
      this.knowledgeTag = this.editEntry.knowledgeTag
      this.remark = this.editEntry.remark
      this.subjectCode = this.editEntry.subjectCode.length > 0 ? this.editEntry.subjectCode : 'math'
      this.causeCode = this.editEntry.causeCode.length > 0 ? this.editEntry.causeCode : 'concept'
      this.photoUri = this.editEntry.photoUri
    }
  }

  private async pickPhoto(fromCamera: boolean): Promise<void> {
    const host = this.getUIContext().getHostContext()
    if (host === undefined) {
      return
    }
    const ctx = host as common.UIAbilityContext
    const uri = fromCamera ? await PhotoPickService.capture(ctx) : await PhotoPickService.pickAlbum(ctx)
    if (uri.length > 0) {
      this.photoUri = uri
    }
  }

  private submit(): void {
    if (this.saving) {
      return
    }
    if (this.stem.trim().length < 2) {
      this.errorText = '请至少填写一句题目内容'
      return
    }
    this.saving = true
    const write = new WrongEntryWrite()
    write.stem = this.stem.trim()
    write.correctAnswer = this.correctAnswer.trim()
    write.wrongAnswer = this.wrongAnswer.trim()
    write.knowledgeTag = this.knowledgeTag.trim()
    write.remark = this.remark.trim()
    write.subjectCode = this.subjectCode
    write.causeCode = this.causeCode
    write.photoUri = this.photoUri
    write.status = this.editEntry.status.length > 0 ? this.editEntry.status : 'pending'
    write.coverKey = WrongMedia.subjectCover(this.subjectCode)
    this.onSave(write, this.editEntry.id)
    this.saving = false
  }

  build() {
    Column() {
      Row() {
        Text(this.editEntry.id.length > 0 ? '编辑错题' : '录入错题')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.s2, top: Theme.space.s3 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '拍照', variant: 'secondary', onTap: () => { void this.pickPhoto(true) } })
              .layoutWeight(1)
            AppButton({ label: '相册', variant: 'ghost', onTap: () => { void this.pickPhoto(false) } })
              .layoutWeight(1)
          }
          if (this.photoUri.length > 0) {
            Image(this.photoUri)
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Contain)
              .borderRadius(Theme.radius.sm)
          }
          this.field('题目', this.stem, '写清题干或拍完后补一句摘要', (v: string) => { this.stem = v })
          this.field('我的答案', this.wrongAnswer, '当时怎么写的', (v: string) => { this.wrongAnswer = v })
          this.field('正确答案', this.correctAnswer, '订正后的答案', (v: string) => { this.correctAnswer = v })
          this.field('知识点标签', this.knowledgeTag, '如：二次函数顶点', (v: string) => { this.knowledgeTag = v })
          Text('学科')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(CatalogOptions.subjects(), (s: SubjectOption) => {
              Text(s.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.subjectCode === s.code ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.subjectCode === s.code ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.subjectCode = s.code })
            }, (s: SubjectOption) => s.code)
          }
          .width('100%')
          Text('错因')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(CatalogOptions.causes(), (c: CauseOption) => {
              Text(c.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.causeCode === c.code ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.causeCode === c.code ?
                  Theme.colors().brandAccent : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.causeCode = c.code })
            }, (c: CauseOption) => c.code)
          }
          .width('100%')
          this.field('备注（选填）', this.remark, '当时哪里卡住了', (v: string) => { this.remark = v })
          AppButton({
            label: this.saving ? '保存中…' : '保存到错题本',
            disabled: this.saving,
            onTap: () => this.submit()
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10,
          top: Theme.space.s2
        })
        .constraintSize({ maxWidth: 720 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  field(label: string, value: string, hint: string, onChange: (v: string) => void) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: value, placeholder: hint })
        .onChange((v: string) => onChange(v))
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
