import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'

@Component
export struct GoalCreateSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onCreated: () => void = () => {}
  @State title: string = ''
  @State summary: string = ''
  @State m1: string = ''
  @State m2: string = ''
  @State m3: string = ''
  @State toast: string = ''

  build() {
    DetailShell({
      title: '新建目标',
      onClose: (): void => { YdDetailNav.closeGoalCreate() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.title, placeholder: '目标名称，如：三个月读完5本书' })
            .onChange((v: string) => { this.title = v })
          TextArea({ text: this.summary, placeholder: '简要描述（可选）' })
            .height(88)
            .onChange((v: string) => { this.summary = v })
          Text('里程碑（至少填一项）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          TextInput({ text: this.m1, placeholder: '里程碑 1' }).onChange((v: string) => { this.m1 = v })
          TextInput({ text: this.m2, placeholder: '里程碑 2' }).onChange((v: string) => { this.m2 = v })
          TextInput({ text: this.m3, placeholder: '里程碑 3' }).onChange((v: string) => { this.m3 = v })
          AppButton({
            label: '创建目标',
            variant: 'primary',
            onTap: (): void => { void this.submit() }
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }
    }
  }

  private async submit(): Promise<void> {
    const t = this.title.trim()
    if (t.length === 0) {
      this.toast = '请填写目标名称'
      setTimeout((): void => { this.toast = '' }, 2200)
      return
    }
    const ms: string[] = []
    if (this.m1.trim().length > 0) {
      ms.push(this.m1.trim())
    }
    if (this.m2.trim().length > 0) {
      ms.push(this.m2.trim())
    }
    if (this.m3.trim().length > 0) {
      ms.push(this.m3.trim())
    }
    if (ms.length === 0) {
      this.toast = '请至少填写一个里程碑'
      setTimeout((): void => { this.toast = '' }, 2200)
      return
    }
    await YdLocalStore.createGoal(t, this.summary.trim(), ms)
    this.onCreated()
    YdDetailNav.closeGoalCreate()
  }
}
