import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ChoiceChip } from './ChoiceChip'
import { RenoDates, RenoNote } from '../../models/RenoModels'
import { RenoService } from '../../services/RenoService'
import { PhotoPickService } from '../../services/PhotoPickService'

@Component
export struct NoteFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: RenoNote = new RenoNote()
  @State title: string = ''
  @State body: string = ''
  @State kind: string = '进度记录'
  @State date: string = ''
  @State stage: string = '水电'
  @State photoUri: string = ''
  @State remark: string = ''
  @State errorText: string = ''
  onSave: (draft: RenoNote) => void = (_d: RenoNote) => {}
  onClose: () => void = () => {}
  private kinds: string[] = RenoDates.recordKinds()
  private stages: string[] = RenoDates.names()

  aboutToAppear(): void {
    const current = RenoService.currentProject()
    if (this.isEdit && this.seed.title.length > 0) {
      this.title = this.seed.title
      this.body = this.seed.body
      this.kind = this.seed.kind
      this.date = this.seed.date
      this.stage = this.seed.stage
      this.photoUri = this.seed.photoUri
      this.remark = this.seed.remark
      return
    }
    this.date = RenoDates.today()
    this.stage = current !== null ? current.stage : '水电'
  }

  private async pickPhoto(): Promise<void> {
    const host = this.getUIContext().getHostContext()
    if (host === undefined) {
      return
    }
    const ctx = host as common.UIAbilityContext
    const uri = await PhotoPickService.pickOne(ctx)
    if (uri.length > 0) {
      this.photoUri = uri
    }
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写记录标题'
      return
    }
    const current = RenoService.currentProject()
    const draft = new RenoNote()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.body = this.body
    draft.kind = this.kind
    draft.date = this.date
    draft.stage = this.stage
    draft.photoUri = this.photoUri
    draft.remark = this.remark
    draft.projectId = this.seed.projectId.length > 0 ? this.seed.projectId : (current !== null ? current.id : '')
    this.onSave(draft)
  }

  build() {
    Column() {
      Row() {
        Text(this.isEdit ? '编辑记录' : '现场记录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('取消').fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 16, bottom: 12 })
      if (this.errorText.length > 0) {
        Text(this.errorText).fontSize(Theme.type.footnote).fontColor(Theme.colors().danger)
          .padding({ left: Theme.space.pageX, bottom: 8 })
      }
      Scroll() {
        Column({ space: 12 }) {
          TextInput({ text: this.title, placeholder: '标题，如厨房水电定位完成' })
            .onChange((v: string) => { this.title = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          TextArea({ text: this.body, placeholder: '记录内容' })
            .onChange((v: string) => { this.body = v })
            .height(120)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
          Text('记录类型').fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.kinds, (k: string) => {
              ChoiceChip({ label: k, active: this.kind === k, onPick: () => { this.kind = k } })
                .margin({ right: 8, bottom: 8 })
            }, (k: string) => k)
          }
          Text('所属阶段').fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.stages, (s: string) => {
              ChoiceChip({ label: s, active: this.stage === s, onPick: () => { this.stage = s } })
                .margin({ right: 8, bottom: 8 })
            }, (s: string) => s)
          }
          AppDatePickerField({
            label: '记录日期',
            value: this.date,
            minDaysFromToday: -60,
            maxDaysFromToday: 7,
            onChange: (v: string) => { this.date = v }
          })
          AppButton({
            label: this.photoUri.length > 0 ? '已添加照片，点击更换' : '添加照片',
            variant: 'secondary',
            onTap: () => { void this.pickPhoto() }
          })
          TextInput({ text: this.remark, placeholder: '备注（选填）' })
            .onChange((v: string) => { this.remark = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          AppButton({ label: '保存记录', onTap: () => this.submit() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
