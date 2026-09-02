import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { GearBizService } from '../../services/GearBizService'
import { GearDetailNav } from '../../services/GearDetailNav'
import { GearWriteRequest } from '../../models/GearModels'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct GearFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @State title: string = ''
  @State brand: string = ''
  @State model: string = ''
  @State category: string = '徒步'
  @State weightText: string = ''
  @State boughtAt: string = ''
  @State condition: string = '完好'
  @State remark: string = ''
  @State errorText: string = ''
  @State saving: boolean = false
  private cats: string[] = ['露营', '徒步', '攀登', '水上']
  private conditions: string[] = ['完好', '可用', '待检', '退役']

  aboutToAppear(): void {
    void this.prefill()
  }

  private async prefill(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const row = await GearBizService.findMine('gear', this.editId)
    if (row === undefined) {
      return
    }
    this.title = row.title
    this.brand = row.brand
    this.model = row.model
    this.category = row.category.length > 0 ? row.category : '徒步'
    this.weightText = row.weightG > 0 ? `${row.weightG}` : ''
    this.boughtAt = row.boughtAt
    this.condition = row.condition.length > 0 ? row.condition : '完好'
    this.remark = row.remark.length > 0 ? row.remark : row.body
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写装备名称'
      return
    }
    const w = Number.parseInt(this.weightText, 10)
    if (Number.isNaN(w) || w < 0) {
      this.errorText = '请填写克重（整数克）'
      return
    }
    this.saving = true
    const body = new GearWriteRequest()
    body.title = this.title.trim()
    body.brand = this.brand.trim()
    body.model = this.model.trim()
    body.category = this.category
    body.weightG = w
    body.boughtAt = this.boughtAt
    body.condition = this.condition
    body.remark = this.remark.trim()
    body.body = this.remark.trim()
    body.summary = `${this.brand} · ${w}g`
    body.coverKey = GearFormPane.coverOf(this.category)
    let ok = false
    if (this.editId.length > 0) {
      ok = await GearBizService.update('gear', this.editId, body)
    } else {
      ok = await GearBizService.create('gear', body)
    }
    this.saving = false
    if (ok) {
      GearDetailNav.close()
      return
    }
    this.errorText = '保存失败，请稍后重试'
  }

  private async remove(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const ok = await GearBizService.remove('gear', this.editId)
    if (ok) {
      GearDetailNav.close()
    }
  }

  private static coverOf(cat: string): string {
    if (cat === '露营') {
      return 'gear_tent'
    }
    if (cat === '攀登') {
      return 'gear_harness'
    }
    if (cat === '水上') {
      return 'gear_pfd'
    }
    return 'gear_pack'
  }

  build() {
    DetailShell({ title: this.editId.length > 0 ? '编辑装备' : '录入装备', onClose: () => GearDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '装备名称' })
          .onChange((v: string) => { this.title = v })
        TextInput({ text: this.brand, placeholder: '品牌' })
          .onChange((v: string) => { this.brand = v })
        TextInput({ text: this.model, placeholder: '型号' })
          .onChange((v: string) => { this.model = v })
        Text('类别')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.cats, (c: string) => {
            Text(c)
              .fontSize(Theme.type.caption)
              .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.category = c })
          }, (c: string) => c)
        }
        TextInput({ text: this.weightText, placeholder: '克重（克）' })
          .type(InputType.Number)
          .onChange((v: string) => { this.weightText = v })
        AppDatePickerField({
          label: '购入日期',
          value: this.boughtAt,
          placeholder: '选择日期',
          minDaysFromToday: -3650,
          maxDaysFromToday: 0,
          onChange: (v: string) => { this.boughtAt = v }
        })
        Text('成色')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.conditions, (c: string) => {
            Text(c)
              .fontSize(Theme.type.caption)
              .fontColor(this.condition === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.condition === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.condition = c })
          }, (c: string) => c)
        }
        TextInput({ text: this.remark, placeholder: '备注' })
          .onChange((v: string) => { this.remark = v })
        AppButton({
          label: this.saving ? '保存中…' : '保存',
          disabled: this.saving,
          onTap: (): void => { void this.save() }
        })
        if (this.editId.length > 0) {
          AppButton({
            label: '删除这件装备',
            variant: 'ghost',
            onTap: (): void => { void this.remove() }
          })
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
