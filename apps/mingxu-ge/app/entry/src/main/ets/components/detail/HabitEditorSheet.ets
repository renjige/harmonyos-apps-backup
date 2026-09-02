import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { XuHabitItem } from '../../models/XuModels'
import { XuLocalStore } from '../../services/XuLocalStore'
import { XuBizService } from '../../services/XuBizService'

@Component
export struct HabitEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @State title: string = ''
  @State remark: string = ''
  @State errorText: string = ''
  onSaved: () => void = () => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const found = await XuLocalStore.findHabit(this.editId)
    if (found !== undefined) {
      this.title = found.title
      this.remark = found.remark
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写习惯名称'
      return
    }
    let item = XuHabitItem.create(this.title.trim(), this.remark)
    if (this.editId.length > 0) {
      const found = await XuLocalStore.findHabit(this.editId)
      if (found !== undefined) {
        item = found
        item.title = this.title.trim()
        item.remark = this.remark
      }
    }
    await XuLocalStore.saveHabit(item)
    XuLocalStore.publishHomeStats()
    void XuBizService.syncHabit(item)
    this.onSaved()
    this.onClose()
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text(this.editId.length > 0 ? '编辑习惯' : '添加习惯')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextInput({ text: this.title, placeholder: '如：晨读 30 分钟' })
        .onChange((v: string) => { this.title = v })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
      TextArea({ text: this.remark, placeholder: '说明（可选）' })
        .onChange((v: string) => { this.remark = v })
        .height(100)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
      if (this.errorText.length > 0) {
        Text(this.errorText).fontSize(Theme.type.footnote).fontColor(Theme.colors().danger).width('100%')
      }
      AppButton({ label: '保存', onTap: (): void => { void this.save() } })
      AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.onClose() } })
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
