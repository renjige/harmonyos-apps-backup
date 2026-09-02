import { Theme } from '../design-system/Theme'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { InspectCatalog, MaterialCategory } from '../../models/InspectModels'

@Component
export struct InspectFormInfoCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Link materialName: string
  @Link category: string
  @Link spec: string
  @Link quantity: string
  @Link unit: string
  @Link supplier: string
  @Link arrivalDate: string
  @Link projectName: string
  @Link batchNo: string

  build() {
    Column({ space: 10 }) {
      Text('材料信息')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('工点 / 工程')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.projectName, placeholder: '例如：1号楼 / 南区工点' })
        .height(44)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(12)
        .onChange((v: string) => { this.projectName = v })
      Text('批次 / 送货单号')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.batchNo, placeholder: '请输入批次或送货单号' })
        .height(44)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(12)
        .onChange((v: string) => { this.batchNo = v })
      Text('材料名称')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.materialName, placeholder: '请输入材料名称' })
        .height(44)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(12)
        .onChange((v: string) => { this.materialName = v })
      Text('材料类别')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(InspectCatalog.all(), (cat: MaterialCategory) => {
          Text(cat.title)
            .fontSize(Theme.type.caption)
            .fontColor(this.category === cat.title ? Theme.chipFg(true) : Theme.chipFg(false))
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.category === cat.title ? Theme.chipBg(true) : Theme.chipBg(false))
            .borderRadius(Theme.radius.pill)
            .border({
              width: 1,
              color: this.category === cat.title ? Theme.chipBg(true) : Theme.colors().strokeStrong
            })
            .onClick(() => { this.category = cat.title })
        }, (cat: MaterialCategory) => cat.id)
      }
      .width('100%')
      Text('规格型号')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.spec, placeholder: '请输入规格型号' })
        .height(44)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(12)
        .onChange((v: string) => { this.spec = v })
      Text('数量')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.quantity, placeholder: '请输入数量' })
        .height(44)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(12)
        .type(InputType.Number)
        .onChange((v: string) => { this.quantity = v })
      Text('单位')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(InspectCatalog.units(), (u: string) => {
          Text(u)
            .fontSize(Theme.type.caption)
            .fontColor(this.unit === u ? Theme.chipFg(true) : Theme.chipFg(false))
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.unit === u ? Theme.chipBg(true) : Theme.chipBg(false))
            .borderRadius(Theme.radius.pill)
            .border({
              width: 1,
              color: this.unit === u ? Theme.chipBg(true) : Theme.colors().strokeStrong
            })
            .onClick(() => { this.unit = u })
        }, (u: string) => u)
      }
      .width('100%')
      Text('供应商')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.supplier, placeholder: '请输入供应商' })
        .height(44)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(12)
        .onChange((v: string) => { this.supplier = v })
      AppDatePickerField({
        label: '进场日期',
        value: this.arrivalDate,
        placeholder: '请选择进场日期',
        minDaysFromToday: -365,
        maxDaysFromToday: 14,
        onChange: (v: string) => { this.arrivalDate = v }
      })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
