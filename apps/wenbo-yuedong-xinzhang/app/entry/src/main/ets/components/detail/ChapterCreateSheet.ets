import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'

@Component
export struct ChapterCreateSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onCreated: () => void = () => {}
  @State title: string = ''
  @State theme: string = 'career'
  @State days: number = 7
  @State toast: string = ''

  build() {
    DetailShell({
      title: '开启新章',
      onClose: (): void => { YdDetailNav.closeChapterCreate() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('给接下来这一段日子起一个篇章名。到期须写章末复盘才能收官——这不是系统日历里的普通日程。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(22)
          TextInput({ text: this.title, placeholder: '如：三月职场跃升 / 期末冲刺' })
            .onChange((v: string) => { this.title = v })
          Text('快速模板（点选自动填充）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Column({ space: Theme.space.s2 }) {
            this.TemplateRow('21天职场跃升', 'career', 21, '三月职场跃升')
            this.TemplateRow('14天期末冲刺', 'exam', 14, '期末冲刺周')
            this.TemplateRow('30天生活节律', 'health', 30, '生活节律重塑')
            this.TemplateRow('7天阅读新章', 'reading', 7, '一周阅读计划')
          }
          Text('篇章主题')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('职场跃升', 'career')
            this.ThemeChip('备考冲刺', 'exam')
          }
          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('生活节律', 'health')
            this.ThemeChip('阅读新章', 'reading')
          }
          Text('周期')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Row({ space: Theme.space.s2 }) {
            this.DayChip(7)
            this.DayChip(14)
            this.DayChip(21)
            this.DayChip(30)
          }
          AppButton({
            label: '开启这一章',
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
  TemplateRow(label: string, theme: string, days: number, title: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      Text(`${days}天`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.md)
    .onClick((): void => {
      this.theme = theme
      this.days = days
      this.title = title
    })
  }

  @Builder
  ThemeChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(this.theme === value ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.theme === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.theme = value })
  }

  @Builder
  DayChip(n: number) {
    Text(`${n} 天`)
      .fontSize(Theme.type.subhead)
      .fontColor(this.days === n ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.days === n ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.days = n })
  }

  private async submit(): Promise<void> {
    const err = await YdLocalStore.createChapter(this.title, this.theme, this.days)
    if (err.length > 0) {
      this.toast = err
      setTimeout((): void => { this.toast = '' }, 2400)
      return
    }
    this.onCreated()
    YdDetailNav.closeChapterCreate()
  }
}
