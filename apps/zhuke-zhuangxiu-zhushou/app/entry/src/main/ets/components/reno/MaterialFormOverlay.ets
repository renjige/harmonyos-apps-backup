import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ChoiceChip } from './ChoiceChip'
import { RenoMaterial } from '../../models/RenoModels'
import { RenoService } from '../../services/RenoService'

@Component
export struct MaterialFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: RenoMaterial = new RenoMaterial()
  @State title: string = ''
  @State brand: string = ''
  @State model: string = ''
  @State spec: string = ''
  @State qty: string = ''
  @State room: string = ''
  @State status: string = 'pending'
  @State remark: string = ''
  @State errorText: string = ''
  onSave: (draft: RenoMaterial) => void = (_d: RenoMaterial) => {}
  onClose: () => void = () => {}
  private statuses: string[] = ['pending', 'confirmed', 'bought', 'onsite']

  aboutToAppear(): void {
    if (this.isEdit && this.seed.title.length > 0) {
      this.title = this.seed.title
      this.brand = this.seed.brand
      this.model = this.seed.model
      this.spec = this.seed.spec
      this.qty = this.seed.qty
      this.room = this.seed.room
      this.status = this.seed.status
      this.remark = this.seed.remark
    }
  }

  private labelOf(code: string): string {
    if (code === 'confirmed') {
      return '已确认'
    }
    if (code === 'bought') {
      return '已购买'
    }
    if (code === 'onsite') {
      return '已进场'
    }
    return '待确认'
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写材料名称'
      return
    }
    const current = RenoService.currentProject()
    const draft = new RenoMaterial()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.brand = this.brand
    draft.model = this.model
    draft.spec = this.spec
    draft.qty = this.qty
    draft.room = this.room
    draft.status = this.status
    draft.remark = this.remark
    draft.projectId = this.seed.projectId.length > 0 ? this.seed.projectId : (current !== null ? current.id : '')
    this.onSave(draft)
  }

  build() {
    Column() {
      Row() {
        Text(this.isEdit ? '编辑材料' : '记材料')
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
          TextInput({ text: this.title, placeholder: '材料名称' })
            .onChange((v: string) => { this.title = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          TextInput({ text: this.brand, placeholder: '品牌（选填）' })
            .onChange((v: string) => { this.brand = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          TextInput({ text: this.model, placeholder: '型号（选填）' })
            .onChange((v: string) => { this.model = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          TextInput({ text: this.spec, placeholder: '规格，如 20kg / 86型' })
            .onChange((v: string) => { this.spec = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          TextInput({ text: this.qty, placeholder: '数量（选填）' })
            .onChange((v: string) => { this.qty = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          TextInput({ text: this.room, placeholder: '使用房间，如卫生间' })
            .onChange((v: string) => { this.room = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          Text('状态').fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.statuses, (s: string) => {
              ChoiceChip({
                label: this.labelOf(s),
                active: this.status === s,
                onPick: () => { this.status = s }
              }).margin({ right: 8, bottom: 8 })
            }, (s: string) => s)
          }
          TextInput({ text: this.remark, placeholder: '备注（选填）' })
            .onChange((v: string) => { this.remark = v }).height(48)
            .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
          AppButton({ label: this.isEdit ? '保存材料' : '保存材料', onTap: () => this.submit() })
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
