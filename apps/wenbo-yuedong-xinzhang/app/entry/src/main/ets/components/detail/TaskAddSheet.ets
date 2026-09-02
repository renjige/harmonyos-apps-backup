import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'

@Component
export struct TaskAddSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onCreated: () => void = () => {}
  @State title: string = ''
  @State timeSlot: string = '09:00'
  @State priority: string = 'medium'
  @State domain: string = 'work'
  @State durationMin: number = 30
  @State toast: string = ''

  build() {
    DetailShell({
      title: '添加任务',
      onClose: (): void => { YdDetailNav.closeTaskAdd() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.title, placeholder: '这一步要完成什么' })
            .onChange((v: string) => { this.title = v })
          Text('计划时间（如 09:00）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          TextInput({ text: this.timeSlot, placeholder: '09:00' })
            .onChange((v: string) => { this.timeSlot = v })
          Text('领域（计入时间账）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Row({ space: Theme.space.s2 }) {
            this.Chip('工作', 'work', true)
            this.Chip('学习', 'study', true)
            this.Chip('生活', 'life', true)
          }
          Text('预计投入')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Row({ space: Theme.space.s2 }) {
            this.MinChip(15)
            this.MinChip(30)
            this.MinChip(60)
          }
          Text('优先级')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Row({ space: Theme.space.s2 }) {
            this.Chip('高', 'high', false)
            this.Chip('中', 'medium', false)
            this.Chip('低', 'low', false)
          }
          AppButton({
            label: '写入今日章',
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

  @Builder
  Chip(label: string, value: string, isDomain: boolean) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor((isDomain ? this.domain : this.priority) === value ?
        Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor((isDomain ? this.domain : this.priority) === value ?
        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        if (isDomain) {
          this.domain = value
        } else {
          this.priority = value
        }
      })
  }

  @Builder
  MinChip(n: number) {
    Text(`${n} 分钟`)
      .fontSize(Theme.type.subhead)
      .fontColor(this.durationMin === n ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.durationMin === n ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.durationMin = n })
  }

  private async submit(): Promise<void> {
    const t = this.title.trim()
    if (t.length === 0) {
      this.toast = '请填写任务标题'
      setTimeout((): void => { this.toast = '' }, 2200)
      return
    }
    await YdLocalStore.createTask(t, this.timeSlot, this.priority, this.domain, this.durationMin)
    this.onCreated()
    YdDetailNav.closeTaskAdd()
  }
}
