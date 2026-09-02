import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { Archive, ArchiveCategory, TimelineNode } from '../../models/ArchiveModels'
import { ArchiveStore } from '../../services/ArchiveStore'
import { ArchiveDetailNav } from '../../services/ArchiveDetailNav'
import { DateHelper } from '../../services/DateHelper'
import { CategoryChips } from '../archive/CategoryChips'

class DraftNode {
  title: string = ''
  dateKey: string = ''

  static make(title: string, dateKey: string): DraftNode {
    const d = new DraftNode()
    d.title = title
    d.dateKey = dateKey
    return d
  }
}

@Component
export struct CreateArchiveSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('editArchiveId') editArchiveId: string = ''
  onSaved: () => void = () => {}
  @State step: number = 0
  @State titleInput: string = ''
  @State categoryKey: string = 'growth'
  @State startDate: string = ''
  @State endDate: string = ''
  @State summaryInput: string = ''
  @State oneLineSummary: string = ''
  @State mood: string = ''
  @State tagInput: string = ''
  @State tags: string[] = []
  @State draftNodes: DraftNode[] = []
  @State nodeTitleInput: string = ''
  @State nodeDateInput: string = ''
  @State categories: ArchiveCategory[] = []
  @State catLabels: string[] = []
  @State catKeys: string[] = []
  @State toastText: string = ''
  @State saving: boolean = false
  @State isEditMode: boolean = false
  @State editingId: string = ''
  private moodOptions: string[] = ['平静', '喜悦', '感慨', '成长', '纪念']

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    await this.loadCategories()
    this.startDate = DateHelper.todayKey()
    this.nodeDateInput = DateHelper.todayKey()
    if (this.editArchiveId.length > 0) {
      this.isEditMode = true
      this.editingId = this.editArchiveId
      const found = await ArchiveStore.findArchive(this.editArchiveId)
      if (found !== undefined) {
        this.titleInput = found.title
        this.categoryKey = found.categoryKey
        this.startDate = found.startDate.length > 0 ? found.startDate : DateHelper.todayKey()
        this.endDate = found.endDate
        this.summaryInput = found.summary
        this.oneLineSummary = found.oneLineSummary
        this.mood = found.mood
        this.tags = found.tags
      }
    }
  }

  private async loadCategories(): Promise<void> {
    this.categories = await ArchiveStore.loadCategories()
    const labels: string[] = []
    const keys: string[] = []
    for (const c of this.categories) {
      labels.push(c.label)
      keys.push(c.key)
    }
    this.catLabels = labels
    this.catKeys = keys
    if (keys.length > 0 && this.categoryKey.length === 0) {
      this.categoryKey = keys[0]
    }
  }

  private sheetTitle(): string {
    return this.isEditMode ? '编辑档案' : '创建档案'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private stepTitle(): string {
    if (this.step === 0) {
      return '档案名称'
    }
    if (this.step === 1) {
      return '选择分类'
    }
    if (this.step === 2) {
      return '时间范围'
    }
    if (this.step === 3) {
      return '档案摘要'
    }
    if (this.step === 4) {
      return '标签'
    }
    return '初始节点（可选）'
  }

  private canNext(): boolean {
    if (this.step === 0) {
      return this.titleInput.trim().length >= 2
    }
    if (this.step === 1) {
      return this.categoryKey.length > 0
    }
    if (this.step === 2) {
      return this.startDate.length > 0
    }
    return true
  }

  private addTag(): void {
    const t = this.tagInput.trim()
    if (t.length === 0) {
      return
    }
    for (const existing of this.tags) {
      if (existing === t) {
        this.tagInput = ''
        return
      }
    }
    const next: string[] = []
    for (const existing of this.tags) {
      next.push(existing)
    }
    next.push(t)
    this.tags = next
    this.tagInput = ''
  }

  private addDraftNode(): void {
    const t = this.nodeTitleInput.trim()
    if (t.length === 0) {
      this.showToast('请输入节点标题')
      return
    }
    this.draftNodes.push(DraftNode.make(t, this.nodeDateInput))
    this.nodeTitleInput = ''
  }

  private async handleSave(): Promise<void> {
    if (this.saving) {
      return
    }
    const name = this.titleInput.trim()
    if (name.length < 2) {
      this.showToast('档案名称至少 2 个字')
      return
    }
    this.saving = true
    let archive: Archive
    if (this.isEditMode && this.editingId.length > 0) {
      const found = await ArchiveStore.findArchive(this.editingId)
      if (found === undefined) {
        this.saving = false
        this.showToast('档案不存在')
        return
      }
      archive = found
      archive.title = name
      archive.categoryKey = this.categoryKey
      archive.startDate = this.startDate
      archive.endDate = this.endDate
      archive.summary = this.summaryInput.trim()
      archive.oneLineSummary = this.oneLineSummary.trim()
      archive.mood = this.mood
      archive.tags = this.tags
    } else {
      archive = Archive.createNew(name, this.categoryKey)
      archive.startDate = this.startDate
      archive.endDate = this.endDate
      archive.summary = this.summaryInput.trim()
      archive.oneLineSummary = this.oneLineSummary.trim()
      archive.mood = this.mood
      archive.tags = this.tags
      archive.status = this.draftNodes.length > 0 ? 'organized' : 'pending'
    }
    await ArchiveStore.saveArchive(archive)
    for (const t of this.tags) {
      await ArchiveStore.addTag(t)
    }
    if (!this.isEditMode) {
      for (const d of this.draftNodes) {
        const node = TimelineNode.createNew(archive.id, d.dateKey, d.title)
        await ArchiveStore.saveNode(node)
      }
    }
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    this.saving = false
    this.onSaved()
    ArchiveDetailNav.closeCreateArchive()
    if (!this.isEditMode) {
      ArchiveDetailNav.openArchiveDetail(archive.id)
    }
    this.showToast(this.isEditMode ? '档案已更新' : '档案已创建')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { ArchiveDetailNav.closeCreateArchive() })
          Text(this.sheetTitle())
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(`${this.step + 1}/6`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(this.stepTitle())
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')

            if (this.step === 0) {
              TextInput({ text: this.titleInput, placeholder: '如：2020 大学时光' })
                .fontSize(Theme.type.body)
                .onChange((v: string): void => { this.titleInput = v })
            } else if (this.step === 1) {
              CategoryChips({
                labels: this.catLabels,
                keys: this.catKeys,
                selectedKey: this.categoryKey,
                showAll: false,
                onSelect: (key: string): void => { this.categoryKey = key }
              })
            } else if (this.step === 2) {
              AppDatePickerField({
                label: '开始日期',
                value: this.startDate,
                placeholder: '请选择开始日期',
                minDaysFromToday: -36500,
                maxDaysFromToday: 3650,
                onChange: (v: string): void => { this.startDate = v }
              })
              AppDatePickerField({
                label: '结束日期（可选）',
                value: this.endDate,
                placeholder: '请选择结束日期',
                minDaysFromToday: -36500,
                maxDaysFromToday: 3650,
                onChange: (v: string): void => { this.endDate = v }
              })
            } else if (this.step === 3) {
              TextInput({ text: this.oneLineSummary, placeholder: '时光卡片一句话（可选）' })
                .fontSize(Theme.type.body)
                .onChange((v: string): void => { this.oneLineSummary = v })
              TextArea({ text: this.summaryInput, placeholder: '简述这段经历的主题与意义…' })
                .fontSize(Theme.type.body)
                .height(100)
                .onChange((v: string): void => { this.summaryInput = v })
              Text('心情（可选）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.moodOptions, (m: string) => {
                  Text(m)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.mood === m ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.mood === m ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.mood = m })
                }, (m: string) => m)
              }
              .width('100%')
            } else if (this.step === 4) {
              Row({ space: Theme.space.s2 }) {
                TextInput({ text: this.tagInput, placeholder: '输入标签' })
                  .layoutWeight(1)
                  .height(48)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .placeholderColor(Theme.colors().textTertiary)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .padding({ left: 14, right: 14 })
                  .onChange((v: string): void => { this.tagInput = v })
                Text('添加')
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandOnPrimary)
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => { this.addTag() })
              }
              .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.tags, (tag: string, index: number) => {
                  Text(tag)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                }, (tag: string, index: number) => `${tag}_${index}`)
              }
              .width('100%')
            } else if (!this.isEditMode) {
              TextInput({ text: this.nodeTitleInput, placeholder: '节点标题' })
                .fontSize(Theme.type.body)
                .onChange((v: string): void => { this.nodeTitleInput = v })
              AppDatePickerField({
                label: '节点日期',
                value: this.nodeDateInput,
                placeholder: '请选择日期',
                minDaysFromToday: -36500,
                maxDaysFromToday: 3650,
                onChange: (v: string): void => { this.nodeDateInput = v }
              })
              AppButton({
                label: '添加节点',
                variant: 'secondary',
                onTap: (): void => { this.addDraftNode() }
              })
              ForEach(this.draftNodes, (d: DraftNode, idx: number) => {
                Text(`${d.dateKey} · ${d.title}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
              }, (d: DraftNode, idx: number) => `${idx}_${d.title}`)
            } else {
              Text('编辑模式下请在档案详情页管理节点')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)

        Row({ space: Theme.space.s3 }) {
          if (this.step > 0) {
            AppButton({
              label: '上一步',
              variant: 'secondary',
              onTap: (): void => { this.step-- }
            }).layoutWeight(1)
          }
          if (this.isEditMode && this.step >= 4) {
            AppButton({
              label: '保存修改',
              variant: 'primary',
              onTap: (): void => { void this.handleSave() }
            }).layoutWeight(1)
          } else if (this.step < 5) {
            AppButton({
              label: '下一步',
              variant: 'primary',
              disabled: !this.canNext(),
              onTap: (): void => { if (this.canNext()) { this.step++ } }
            }).layoutWeight(1)
          } else {
            AppButton({
              label: '完成创建',
              variant: 'primary',
              onTap: (): void => { void this.handleSave() }
            }).layoutWeight(1)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
