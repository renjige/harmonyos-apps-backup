import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FormSheetHeader } from '../design-system/FormSheetHeader'
import { ChoiceChip } from '../family/ChoiceChip'
import { DiaryEntry } from '../../models/JujiaModels'

@Component
export struct DiaryFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: DiaryEntry = new DiaryEntry()
  @State title: string = ''
  @State body: string = ''
  @State mood: string = '平常'
  @State errorText: string = ''
  onSave: (draft: DiaryEntry) => void = (_d: DiaryEntry) => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    if (this.isEdit) {
      this.title = this.seed.title
      this.body = this.seed.body
      this.mood = this.seed.mood
    }
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写日记标题'
      return
    }
    const draft = new DiaryEntry()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.body = this.body.trim()
    draft.mood = this.mood
    this.onSave(draft)
  }

  build() {
    Column() {
      FormSheetHeader({ title: this.isEdit ? '编辑日记' : '写居家日记', onClose: () => this.onClose() })
      Scroll() {
        Column({ space: 16 }) {
          TextInput({ text: this.title, placeholder: '今天发生了什么？' })
            .onChange((v: string) => { this.title = v })
          Text('心情').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['开心', '平常', '忙碌', '温馨'], (m: string) => {
              ChoiceChip({ label: m, active: this.mood === m, onPick: () => { this.mood = m } })
            }, (m: string) => m)
          }
          TextArea({ text: this.body, placeholder: '记录家庭生活片段、成长瞬间或整理心得…' })
            .height(160).onChange((v: string) => { this.body = v })
          AppButton({ label: this.isEdit ? '保存' : '保存日记', variant: 'primary', onTap: () => this.submit() })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10, top: 8 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(Theme.colors().surfacePage)
  }
}
