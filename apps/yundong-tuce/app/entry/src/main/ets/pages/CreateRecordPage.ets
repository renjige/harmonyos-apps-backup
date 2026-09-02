import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { SportRecord, SportTypeOption } from '../models/SportRecord'
import { RecordStore } from '../services/RecordStore'
import { PhotoPickService } from '../services/PhotoPickService'
import { AuthService } from '../services/AuthService'

@Component
export struct CreateRecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  @Prop @Watch('onEditIdChange') editId: string = ''
  onRequireAuth: () => void = () => {}
  onSaved: () => void = () => {}
  @State sportType: string = 'running'
  @State customTag: string = ''
  @State durationText: string = ''
  @State distanceText: string = ''
  @State caloriesText: string = ''
  @State weightText: string = ''
  @State note: string = ''
  @State photos: string[] = []
  @State saving: boolean = false
  @State toastText: string = ''
  @State editingId: string = ''
  @State favorited: boolean = false
  @State createdAt: number = 0
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    void this.loadEdit()
  }

  onEditIdChange(): void {
    void this.loadEdit()
  }

  private async loadEdit(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const found = await RecordStore.findById(this.editId)
    if (found === undefined) {
      return
    }
    this.editingId = found.id
    this.sportType = found.sportType
    this.customTag = found.customTag
    this.durationText = found.duration > 0 ? `${found.duration}` : ''
    this.distanceText = found.distance > 0 ? `${found.distance}` : ''
    this.caloriesText = found.calories > 0 ? `${found.calories}` : ''
    this.weightText = found.weight > 0 ? `${found.weight}` : ''
    this.note = found.note
    this.photos = found.photos
    this.favorited = found.favorited
    this.createdAt = found.createdAt
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private parseNum(text: string): number {
    if (text.trim().length === 0) {
      return 0
    }
    const v = parseFloat(text)
    if (Number.isNaN(v)) {
      return 0
    }
    return v
  }

  private async pickPhotos(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    const remain = 9 - this.photos.length
    if (remain <= 0) {
      this.showToast('最多添加 9 张照片')
      return
    }
    const picked = await PhotoPickService.pickImages(this.uiContext, remain)
    if (picked.length === 0) {
      return
    }
    const next: string[] = []
    for (const p of this.photos) {
      next.push(p)
    }
    for (const p of picked) {
      next.push(p)
    }
    this.photos = next
  }

  private async save(): Promise<void> {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    if (this.photos.length === 0 && this.customTag.trim().length === 0 && this.note.trim().length === 0) {
      this.showToast('请至少添加照片、标签或备注')
      return
    }
    this.saving = true
    let record: SportRecord
    if (this.editingId.length > 0) {
      record = SportRecord.createNew()
      record.id = this.editingId
      record.createdAt = this.createdAt
      record.favorited = this.favorited
    } else {
      record = SportRecord.createNew()
    }
    record.sportType = this.sportType
    record.customTag = this.customTag.trim()
    record.duration = Math.round(this.parseNum(this.durationText))
    record.distance = this.parseNum(this.distanceText)
    record.calories = Math.round(this.parseNum(this.caloriesText))
    record.weight = this.parseNum(this.weightText)
    record.note = this.note.trim()
    record.photos = this.photos
    await RecordStore.saveRecord(record)
    this.saving = false
    if (this.editingId.length === 0) {
      this.resetForm()
    }
    this.onSaved()
    this.showToast(this.editingId.length > 0 ? '记录已更新' : '记录已保存')
  }

  private resetForm(): void {
    this.sportType = 'running'
    this.customTag = ''
    this.durationText = ''
    this.distanceText = ''
    this.caloriesText = ''
    this.weightText = ''
    this.note = ''
    this.photos = []
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.editingId.length > 0 ? '编辑运动记录' : '新建运动记录')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('照片 + 数据才会进入蜕变对照与报告，不是单纯存图。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Text('运动类型')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(SportTypeOption.all(), (opt: SportTypeOption) => {
              Text(opt.label)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.sportType === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.sportType === opt.id ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.sportType = opt.id })
            }, (opt: SportTypeOption) => opt.id)
          }

          this.InputField('自定义标签', '如：晨跑 5 公里', this.customTag, (v: string): void => { this.customTag = v })
          Text('按类型与数据填标签')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => {
              this.customTag = SportRecord.suggestTag(
                this.sportType,
                this.parseNum(this.distanceText),
                Math.round(this.parseNum(this.durationText))
              )
            })
          this.InputField('时长（分钟）', '可选', this.durationText, (v: string): void => { this.durationText = v })
          this.InputField('距离（公里）', '可选', this.distanceText, (v: string): void => { this.distanceText = v })
          this.InputField('卡路里', '可选', this.caloriesText, (v: string): void => { this.caloriesText = v })
          this.InputField('体重（kg）', '可选', this.weightText, (v: string): void => { this.weightText = v })

          Text('运动感受 / 备注')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.note, placeholder: '记录今天的状态与目标…' })
            .height(120)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onChange((v: string): void => { this.note = v })

          Row({ space: 8 }) {
            AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
            Text(`添加照片（${this.photos.length}/9）`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          .onClick((): void => { void this.pickPhotos() })

          if (this.photos.length > 0) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.photos, (path: string, idx: number) => {
                Image(path)
                  .width(96)
                  .height(96)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
                  .margin({ right: 8, bottom: 8 })
              }, (path: string, idx: number) => `${idx}_${path}`)
            }
          }

          AppButton({
            label: this.saving ? '保存中…' : (this.editingId.length > 0 ? '保存修改' : '保存记录'),
            variant: 'primary',
            onTap: (): void => { void this.save() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onAppear((): void => {
      this.uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext
    })
  }

  @Builder
  InputField(label: string, placeholder: string, value: string, onChange: (v: string) => void) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: value, placeholder: placeholder })
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onChange(onChange)
    }
    .width('100%')
  }
}
