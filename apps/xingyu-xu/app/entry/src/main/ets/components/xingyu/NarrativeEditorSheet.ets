import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { Narrative, TagItem } from '../../models/XingyuModels'
import { XingyuStore } from '../../services/XingyuStore'
import { XingyuNav } from '../../services/XingyuNav'
import { DateHelper } from '../../services/DateHelper'
import { DetailShell } from '../detail/DetailShell'
import { SelectChip } from './SelectChip'

@Component
export struct NarrativeEditorSheet {
  @Prop editorId: string = ''
  @State title: string = ''
  @State dateKey: string = ''
  @State templateKey: string = 'fragment'
  @State status: string = 'normal'
  @State fieldA: string = ''
  @State fieldB: string = ''
  @State fieldC: string = ''
  @State tags: string[] = []
  @State allTags: TagItem[] = []
  @State toastText: string = ''
  private existingId: string = ''

  aboutToAppear(): void {
    void this.boot()
  }

  private async boot(): Promise<void> {
    this.allTags = await XingyuStore.loadTags()
    this.dateKey = DateHelper.todayKey()
    if (this.editorId.length === 0) {
      const pending = XingyuNav.takePendingTheme()
      this.existingId = ''
      if (pending.length > 0) {
        this.tags = []
        AppStorage.setOrCreate('xingyuPendingThemeHold', pending)
      }
      return
    }
    const n = await XingyuStore.findNarrative(this.editorId)
    if (n === undefined) {
      return
    }
    this.existingId = n.id
    this.title = n.title
    this.dateKey = n.dateKey
    this.templateKey = n.templateKey
    this.status = n.status
    this.fieldA = n.fieldA
    this.fieldB = n.fieldB
    this.fieldC = n.fieldC
    this.tags = n.tags
  }

  private labelA(): string {
    if (this.templateKey === 'reading') {
      return '书名'
    }
    if (this.templateKey === 'travel') {
      return '地点'
    }
    if (this.templateKey === 'spark') {
      return '想法'
    }
    return '发生'
  }

  private labelB(): string {
    if (this.templateKey === 'reading') {
      return '收获'
    }
    if (this.templateKey === 'travel') {
      return '经历'
    }
    if (this.templateKey === 'spark') {
      return '来源'
    }
    return '感受'
  }

  private labelC(): string {
    if (this.templateKey === 'reading') {
      return '感悟'
    }
    if (this.templateKey === 'travel') {
      return '回忆'
    }
    if (this.templateKey === 'spark') {
      return '计划'
    }
    return '值得保存'
  }

  private toggleTag(name: string): void {
    const next: string[] = []
    let found = false
    for (const t of this.tags) {
      if (t === name) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(name)
    }
    this.tags = next
  }

  private tagOn(name: string): boolean {
    for (const t of this.tags) {
      if (t === name) {
        return true
      }
    }
    return false
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写标题'
      setTimeout(() => {
        this.toastText = ''
      }, 2000)
      return
    }
    let n = new Narrative()
    if (this.existingId.length > 0) {
      const old = await XingyuStore.findNarrative(this.existingId)
      if (old !== undefined) {
        n = old
      }
    } else {
      n = Narrative.createNew(this.dateKey, this.templateKey)
    }
    n.title = this.title.trim()
    n.dateKey = this.dateKey
    n.templateKey = this.templateKey
    n.status = this.status
    n.fieldA = this.fieldA
    n.fieldB = this.fieldB
    n.fieldC = this.fieldC
    n.tags = this.tags
    const hold = AppStorage.get<string>('xingyuPendingThemeHold') ?? ''
    if (hold.length > 0 && !this.hasTheme(n, hold)) {
      const ids = n.themeIds.slice()
      ids.push(hold)
      n.themeIds = ids
      AppStorage.setOrCreate('xingyuPendingThemeHold', '')
    }
    await XingyuStore.saveNarrative(n)
    XingyuNav.closeEditor()
    XingyuNav.openNarrative(n.id)
  }

  private hasTheme(n: Narrative, id: string): boolean {
    for (const t of n.themeIds) {
      if (t === id) {
        return true
      }
    }
    return false
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.existingId.length > 0 ? '编辑叙事' : '新建叙事',
        onBack: (): void => { XingyuNav.closeEditor() }
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '给这段档案起个标题' })
              .onChange((v: string) => {
                this.title = v
              })
              .height(48)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .padding({ left: 12, right: 12 })
            AppDatePickerField({
              label: '日期',
              value: this.dateKey,
              minDaysFromToday: -3650,
              maxDaysFromToday: 1,
              onChange: (v: string): void => {
                this.dateKey = v
              }
            })
            Text('记录模板')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              SelectChip({
                label: '今日片段',
                active: this.templateKey === 'fragment',
                onSelect: (): void => { this.templateKey = 'fragment' }
              })
              SelectChip({
                label: '灵感记录',
                active: this.templateKey === 'spark',
                onSelect: (): void => { this.templateKey = 'spark' }
              })
              SelectChip({
                label: '阅读记录',
                active: this.templateKey === 'reading',
                onSelect: (): void => { this.templateKey = 'reading' }
              })
              SelectChip({
                label: '旅行记录',
                active: this.templateKey === 'travel',
                onSelect: (): void => { this.templateKey = 'travel' }
              })
            }
            .width('100%')
            Text('状态')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              SelectChip({
                label: '普通',
                active: this.status === 'normal',
                onSelect: (): void => { this.status = 'normal' }
              })
              SelectChip({
                label: '珍藏',
                active: this.status === 'treasure',
                onSelect: (): void => { this.status = 'treasure' }
              })
              SelectChip({
                label: '重要',
                active: this.status === 'important',
                onSelect: (): void => { this.status = 'important' }
              })
              SelectChip({
                label: '回忆',
                active: this.status === 'memory',
                onSelect: (): void => { this.status = 'memory' }
              })
            }
            .width('100%')
            Text(this.labelA())
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.fieldA, placeholder: this.labelA() })
              .onChange((v: string) => {
                this.fieldA = v
              })
              .height(80)
            Text(this.labelB())
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.fieldB, placeholder: this.labelB() })
              .onChange((v: string) => {
                this.fieldB = v
              })
              .height(80)
            Text(this.labelC())
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.fieldC, placeholder: this.labelC() })
              .onChange((v: string) => {
                this.fieldC = v
              })
              .height(80)
            Text('标签')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.allTags, (t: TagItem) => {
                SelectChip({
                  label: t.name,
                  active: this.tagOn(t.name),
                  onSelect: (): void => { this.toggleTag(t.name) }
                })
              }, (t: TagItem): string => t.id)
            }
            .width('100%')
            AppButton({
              label: '保存进档案',
              onTap: (): void => {
                void this.save()
              }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .margin({ top: Theme.space.s8 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
