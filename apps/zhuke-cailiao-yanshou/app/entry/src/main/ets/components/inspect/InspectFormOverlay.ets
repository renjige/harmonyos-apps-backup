import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { ChoicePair } from './ChoicePair'
import { ResultPicker } from './ResultPicker'
import { PhotoGrid } from './PhotoGrid'
import { InspectFormInfoCard } from './InspectFormInfoCard'
import { InspectRecord, PhotoList } from '../../models/InspectModels'
import { InspectGuide } from '../../models/InspectGuide'
import { InspectLocalStore } from '../../services/InspectLocalStore'
import { InspectService } from '../../services/InspectService'
import { InspectNav } from '../../services/InspectNav'
import { PhotoPickService } from '../../services/PhotoPickService'

@Component
export struct InspectFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordIdChange') recordId: string = ''
  @Prop isEdit: boolean = false
  @State materialName: string = ''
  @State category: string = '瓷砖'
  @State spec: string = ''
  @State quantity: string = ''
  @State unit: string = '箱'
  @State supplier: string = ''
  @State arrivalDate: string = ''
  @State projectName: string = ''
  @State batchNo: string = ''
  @State extraA: string = 'ok'
  @State extraB: string = 'ok'
  @State look: string = 'ok'
  @State pack: string = 'ok'
  @State qty: string = 'match'
  @State docs: string = 'complete'
  @State result: string = ''
  @State remark: string = ''
  @State photos: string[] = []
  @State errorText: string = ''
  @State toastText: string = ''
  @State saving: boolean = false
  @State previewUri: string = ''

  aboutToAppear(): void {
    this.hydrate()
  }

  onRecordIdChange(): void {
    this.hydrate()
  }

  private hydrate(): void {
    this.errorText = ''
    if (this.isEdit && this.recordId.length > 0) {
      const row = InspectService.find(this.recordId)
      if (row !== null) {
        this.materialName = row.materialName
        this.category = row.category
        this.spec = row.spec
        this.quantity = row.quantity
        this.unit = row.unit
        this.supplier = row.supplier
        this.arrivalDate = row.arrivalDate
        this.projectName = row.projectName
        this.batchNo = row.batchNo
        this.extraA = row.extraA.length > 0 ? row.extraA : 'ok'
        this.extraB = row.extraB.length > 0 ? row.extraB : 'ok'
        this.look = row.checkAppearance
        this.pack = row.checkPacking
        this.qty = row.checkQty
        this.docs = row.checkDocs
        this.result = row.result
        this.remark = row.remark
        this.photos = PhotoList.split(row.photosCsv)
        return
      }
    }
    const cat = AppStorage.get<string>('defaultCategory')
    const unitVal = AppStorage.get<string>('defaultUnit')
    const projectVal = AppStorage.get<string>('defaultProject')
    this.materialName = ''
    this.category = cat !== undefined && cat.length > 0 ? cat : '瓷砖'
    this.spec = ''
    this.quantity = ''
    this.unit = unitVal !== undefined && unitVal.length > 0 ? unitVal : '箱'
    this.supplier = ''
    this.arrivalDate = InspectLocalStore.today()
    this.projectName = projectVal !== undefined ? projectVal : ''
    this.batchNo = ''
    this.extraA = 'ok'
    this.extraB = 'ok'
    this.look = 'ok'
    this.pack = 'ok'
    this.qty = 'match'
    this.docs = 'complete'
    this.result = ''
    this.remark = ''
    this.photos = []
  }

  private qtyOk(): boolean {
    const n = Number(this.quantity.trim())
    return n > 0
  }

  private async addPhotos(): Promise<void> {
    const host = this.getUIContext().getHostContext()
    if (host === undefined) {
      return
    }
    const ctx = host as common.UIAbilityContext
    const remain = 6 - this.photos.length
    const added = await PhotoPickService.pickMany(ctx, remain)
    if (added.length === 0) {
      return
    }
    const next: string[] = []
    for (const uri of this.photos) {
      next.push(uri)
    }
    for (const uri of added) {
      next.push(uri)
    }
    this.photos = next
  }

  private removePhoto(index: number): void {
    const next: string[] = []
    let i = 0
    for (const uri of this.photos) {
      if (i !== index) {
        next.push(uri)
      }
      i += 1
    }
    this.photos = next
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.materialName.trim().length === 0) {
      this.errorText = '请输入材料名称'
      return
    }
    if (!this.qtyOk()) {
      this.errorText = '请输入有效数量'
      return
    }
    if (this.result.length === 0) {
      this.errorText = '请选择验收结果'
      return
    }
    if (this.result === 'fail' && this.remark.trim().length === 0) {
      this.errorText = '验收不通过须填写原因或处理说明'
      return
    }
    this.errorText = ''
    this.saving = true
    const dup = InspectService.batchExists(this.batchNo, this.recordId)
    const row = new InspectRecord()
    if (this.isEdit && this.recordId.length > 0) {
      row.id = this.recordId
      const old = InspectService.find(this.recordId)
      if (old !== null) {
        row.createdAt = old.createdAt
        row.parentId = old.parentId
        row.followUpNote = old.followUpNote
        row.followUpDone = old.followUpDone
      }
    }
    row.materialName = this.materialName.trim()
    row.category = this.category
    row.spec = this.spec.trim()
    row.quantity = this.quantity.trim()
    row.unit = this.unit
    row.supplier = this.supplier.trim()
    row.arrivalDate = this.arrivalDate
    row.projectName = this.projectName.trim()
    row.batchNo = this.batchNo.trim()
    row.extraA = this.extraA
    row.extraB = this.extraB
    row.checkAppearance = this.look
    row.checkPacking = this.pack
    row.checkQty = this.qty
    row.checkDocs = this.docs
    row.result = this.result
    row.remark = this.remark.trim()
    row.photosCsv = PhotoList.join(this.photos)
    if (row.projectName.length > 0) {
      void InspectLocalStore.setDefaultProject(row.projectName)
    }
    try {
      const saved = await InspectService.save(row)
      this.saving = false
      this.toastText = dup ? '已保存，该批次已有记录请核对' : '验收记录已保存'
      setTimeout(() => {
        this.toastText = ''
        InspectNav.openDetail(saved.id)
      }, 400)
    } catch {
      this.saving = false
      this.errorText = '保存失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
              .rotate({ angle: 180 })
            Text('返回')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .margin({ left: 2 })
          }
          .height(44)
          .onClick(() => InspectNav.close())
          Text(this.isEdit ? '编辑验收' : '新建验收')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(56)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            InspectFormInfoCard({
              materialName: $materialName,
              category: $category,
              spec: $spec,
              quantity: $quantity,
              unit: $unit,
              supplier: $supplier,
              arrivalDate: $arrivalDate,
              projectName: $projectName,
              batchNo: $batchNo
            })
            this.checkCard()
            ResultPicker({
              current: this.result,
              onChange: (v: string) => {
                this.result = v
                this.errorText = ''
              }
            })
            this.photoCard()
            this.remarkCard()
            if (this.errorText.length > 0) {
              Text(this.errorText)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().danger)
                .width('100%')
            }
            AppButton({
              label: this.saving ? '保存中…' : '保存验收记录',
              disabled: this.saving,
              onTap: (): void => { void this.save() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }

      if (this.previewUri.length > 0) {
        Column() {
          Image(this.previewUri)
            .width('100%')
            .layoutWeight(1)
            .objectFit(ImageFit.Contain)
          Text('关闭')
            .fontSize(Theme.type.body)
            .fontColor(Color.White)
            .padding({ top: 16, bottom: 24 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(26,31,38,0.92)')
        .onClick(() => { this.previewUri = '' })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  checkCard() {
    Column({ space: 12 }) {
      Text('验收检查')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ChoicePair({ title: '外观检查', current: this.look, onChange: (v: string) => { this.look = v } })
      ChoicePair({ title: '包装检查', current: this.pack, onChange: (v: string) => { this.pack = v } })
      ChoicePair({
        title: '数量检查',
        leftLabel: '一致',
        rightLabel: '不一致',
        leftValue: 'match',
        rightValue: 'mismatch',
        current: this.qty,
        onChange: (v: string) => { this.qty = v }
      })
      ChoicePair({
        title: '资料检查',
        leftLabel: '齐全',
        rightLabel: '缺失',
        leftValue: 'complete',
        rightValue: 'missing',
        current: this.docs,
        onChange: (v: string) => { this.docs = v }
      })
      ChoicePair({
        title: InspectGuide.of(this.category).extraA,
        current: this.extraA,
        onChange: (v: string) => { this.extraA = v }
      })
      ChoicePair({
        title: InspectGuide.of(this.category).extraB,
        current: this.extraB,
        onChange: (v: string) => { this.extraB = v }
      })
      Text('查看本类验收要点')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().brandOnPrimary)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 12 })
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(14)
        .onClick(() => InspectNav.openGuide(this.category))
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  photoCard() {
    Column({ space: 12 }) {
      Text('现场照片')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      PhotoGrid({
        uris: this.photos,
        editable: true,
        onAdd: (): void => { void this.addPhotos() },
        onRemove: (index: number) => this.removePhoto(index),
        onPreview: (uri: string) => { this.previewUri = uri }
      })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  remarkCard() {
    Column({ space: 12 }) {
      Text('验收备注')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextArea({ text: this.remark, placeholder: '包装完整，数量与送货单一致，外观检查正常。' })
        .height(96)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(12)
        .onChange((v: string) => { this.remark = v })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
