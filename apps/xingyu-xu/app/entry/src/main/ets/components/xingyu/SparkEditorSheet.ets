import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { SparkItem } from '../../models/XingyuModels'
import { XingyuStore } from '../../services/XingyuStore'
import { XingyuNav } from '../../services/XingyuNav'
import { DateHelper } from '../../services/DateHelper'
import { DetailShell } from '../detail/DetailShell'
import { SelectChip } from './SelectChip'

@Component
export struct SparkEditorSheet {
  @Prop editorId: string = ''
  @State title: string = ''
  @State kind: string = 'idea'
  @State body: string = ''
  @State source: string = ''
  @State plan: string = ''
  @State toastText: string = ''
  private existingId: string = ''

  aboutToAppear(): void {
    void this.boot()
  }

  private async boot(): Promise<void> {
    if (this.editorId.length === 0) {
      this.existingId = ''
      return
    }
    const s = await XingyuStore.findSpark(this.editorId)
    if (s === undefined) {
      return
    }
    this.existingId = s.id
    this.title = s.title
    this.kind = s.kind
    this.body = s.body
    this.source = s.source
    this.plan = s.plan
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写标题'
      setTimeout(() => {
        this.toastText = ''
      }, 2000)
      return
    }
    let s = SparkItem.createNew(DateHelper.todayKey())
    if (this.existingId.length > 0) {
      const old = await XingyuStore.findSpark(this.existingId)
      if (old !== undefined) {
        s = old
      }
    }
    s.title = this.title.trim()
    s.kind = this.kind
    s.body = this.body
    s.source = this.source
    s.plan = this.plan
    const hold = AppStorage.get<string>('xingyuPendingThemeHold') ?? ''
    if (hold.length > 0) {
      const ids = s.themeIds.slice()
      ids.push(hold)
      s.themeIds = ids
      AppStorage.setOrCreate('xingyuPendingThemeHold', '')
    }
    await XingyuStore.saveSpark(s)
    XingyuNav.closeEditor()
    XingyuNav.openSpark(s.id)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.existingId.length > 0 ? '编辑灵感' : '收藏灵感',
        onBack: (): void => { XingyuNav.closeEditor() }
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '这颗灵感叫什么' })
              .onChange((v: string) => {
                this.title = v
              })
              .height(48)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .padding({ left: 12, right: 12 })
            Flex({ wrap: FlexWrap.Wrap }) {
              SelectChip({
                label: '灵感',
                active: this.kind === 'idea',
                onSelect: (): void => { this.kind = 'idea' }
              })
              SelectChip({
                label: '想法',
                active: this.kind === 'thought',
                onSelect: (): void => { this.kind = 'thought' }
              })
              SelectChip({
                label: '计划',
                active: this.kind === 'plan',
                onSelect: (): void => { this.kind = 'plan' }
              })
              SelectChip({
                label: '创意',
                active: this.kind === 'creative',
                onSelect: (): void => { this.kind = 'creative' }
              })
            }
            .width('100%')
            TextArea({ text: this.body, placeholder: '想法' })
              .onChange((v: string) => {
                this.body = v
              })
              .height(90)
            TextArea({ text: this.source, placeholder: '来源' })
              .onChange((v: string) => {
                this.source = v
              })
              .height(70)
            TextArea({ text: this.plan, placeholder: '计划' })
              .onChange((v: string) => {
                this.plan = v
              })
              .height(70)
            AppButton({
              label: '放入灵感星库',
              onTap: () => {
                void this.save()
              }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
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
