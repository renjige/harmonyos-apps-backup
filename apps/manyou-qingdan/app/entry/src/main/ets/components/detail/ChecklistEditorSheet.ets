import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { DetailShell } from './DetailShell'
import { RmCategory, RmDateUtil, RmChecklist, RmCheckItem, RmLabels } from '../../models/RmModels'
import { RmStore } from '../../services/RmStore'
import { RmDetailNav } from '../../services/RmDetailNav'

@Component
export struct ChecklistEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEditIdChange') editId: string = ''
  @Prop @Watch('onTemplateChange') templateKey: string = 'blank'
  onChanged: () => void = () => {}
  @State title: string = ''
  @State dateKey: string = RmDateUtil.todayKey()
  @State categoryKey: string = 'experience'
  @State tpl: string = 'blank'
  @State fieldA: string = ''
  @State fieldB: string = ''
  @State fieldC: string = ''
  @State body: string = ''
  @State cats: RmCategory[] = []
  @State tags: string[] = []
  @State tagCsv: string = ''
  @State status: string = 'inbox'
  @State toastText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onEditIdChange(): void {
    void this.bootstrap()
  }

  onTemplateChange(): void {
    if (this.editId.length === 0) {
      this.tpl = this.templateKey.length > 0 ? this.templateKey : 'blank'
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async bootstrap(): Promise<void> {
    this.cats = await RmStore.loadCategories()
    this.tags = await RmStore.loadTags()
    this.tpl = this.templateKey.length > 0 ? this.templateKey : 'blank'
    if (this.editId.length > 0) {
      const found = await RmStore.findChecklist(this.editId)
      if (found !== undefined) {
        this.title = found.title
        this.dateKey = found.dateKey
        this.categoryKey = found.categoryKey
        this.tpl = found.templateKey
        this.fieldA = found.fieldA
        this.fieldB = found.fieldB
        this.fieldC = found.fieldC
        this.body = found.body
        this.tagCsv = found.tagCsv
        this.status = found.status
      }
    }
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.title.trim().length === 0) {
      this.showToast('请填写标题')
      return
    }
    this.saving = true
    let e = new RmChecklist()
    let isNew = false
    if (this.editId.length > 0) {
      const found = await RmStore.findChecklist(this.editId)
      if (found !== undefined) {
        e = found
      }
    } else {
      e = RmChecklist.createNew(this.title.trim(), this.tpl)
      isNew = true
    }
    e.title = this.title.trim()
    e.dateKey = this.dateKey
    e.categoryKey = this.categoryKey
    e.templateKey = this.tpl
    e.fieldA = this.fieldA
    e.fieldB = this.fieldB
    e.fieldC = this.fieldC
    e.body = this.body
    e.tagCsv = this.tagCsv
    e.status = this.status
    await RmStore.saveChecklist(e)
    if (isNew) {
      const seed = RmCheckItem.createNew(e.id, this.title.trim())
      await RmStore.saveItem(seed)
    }
    this.saving = false
    this.onChanged()
    this.showToast('清单已保存')
    RmDetailNav.closeChecklistEditor()
    RmDetailNav.openChecklist(e.id)
  }

  build() {
    Stack() {
      DetailShell({ title: this.editId.length > 0 ? '编辑记录' : '新建记录', onClose: (): void => { RmDetailNav.closeChecklistEditor() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('选择模板')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              this.tplChip('blank')
              this.tplChip('today')
              this.tplChip('idea')
              this.tplChip('travel')
              this.tplChip('read')
            }
            TextInput({ text: this.title, placeholder: '标题' })
              .onChange((v: string): void => { this.title = v })
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
            AppDatePickerField({
              label: '日期',
              value: this.dateKey,
              minDaysFromToday: -3650,
              maxDaysFromToday: 1,
              onChange: (v: string): void => { this.dateKey = v }
            })
            Text('分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cats, (c: RmCategory) => {
                Text(c.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.categoryKey === c.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.categoryKey === c.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.categoryKey = c.key })
              }, (c: RmCategory) => c.key)
            }
            if (this.tpl !== 'blank') {
              TextInput({ text: this.fieldA, placeholder: RmLabels.fieldALabel(this.tpl) })
                .onChange((v: string): void => { this.fieldA = v })
                .height(44)
              TextInput({ text: this.fieldB, placeholder: RmLabels.fieldBLabel(this.tpl) })
                .onChange((v: string): void => { this.fieldB = v })
                .height(44)
              TextInput({ text: this.fieldC, placeholder: RmLabels.fieldCLabel(this.tpl) })
                .onChange((v: string): void => { this.fieldC = v })
                .height(44)
            }
            TextArea({ text: this.body, placeholder: '正文（可选）' })
              .onChange((v: string): void => { this.body = v })
              .height(120)
            Text('标签')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tags, (t: string) => {
                Text(t)
                  .fontSize(Theme.type.caption)
                  .fontColor(RmStore.csvHas(this.tagCsv, t) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(RmStore.csvHas(this.tagCsv, t) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.tagCsv = RmStore.toggleCsv(this.tagCsv, t) })
              }, (t: string) => t)
            }
            Row() {
              AppButton({
                label: this.saving ? '保存中…' : '保存',
                disabled: this.saving,
                onTap: (): void => { void this.save() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.save() })
            Column().height(Theme.space.s8)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .width('100%')
        .layoutWeight(1)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  tplChip(key: string) {
    Text(RmLabels.templateLabel(key))
      .fontSize(Theme.type.caption)
      .fontColor(this.tpl === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.tpl === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.tpl = key })
  }
}
