import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DailyWrap, MomentTodo, MoodPreset } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct DailyWrapSheet {
  onSaved: () => void = () => {}
  @State keep: string = ''
  @State mood: string = ''
  @State tomorrow: string = ''
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const w = await MomentStore.loadDailyWrap(DateHelper.todayKey())
    this.keep = w.keep
    this.mood = w.mood
    this.tomorrow = w.tomorrow
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  private async save(): Promise<void> {
    const w = new DailyWrap()
    w.dateKey = DateHelper.todayKey()
    w.keep = this.keep.trim()
    w.mood = this.mood.trim()
    w.tomorrow = this.tomorrow.trim()
    if (!w.filled()) {
      this.showToast('请至少选心情或写一句')
      return
    }
    await MomentStore.saveDailyWrap(w)
    if (w.tomorrow.length > 0) {
      await this.maybeTodo(w.tomorrow)
    }
    this.onSaved()
    MomentNav.close()
  }

  private async maybeTodo(text: string): Promise<void> {
    const todos = await MomentStore.loadTodos()
    for (const t of todos) {
      if (t.content === text && t.bucket === 'today' && !t.isCompleted) {
        return
      }
    }
    const item = MomentTodo.createNew()
    item.content = text.length > 80 ? `${text.substring(0, 80)}…` : text
    item.bucket = 'today'
    item.priority = 'medium'
    await MomentStore.saveTodo(item)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('取消')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .padding({ left: 4, right: 12, top: 8, bottom: 8 })
            .onClick((): void => MomentNav.close())
          Text('今日收束')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('保存')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 12, right: 4, top: 8, bottom: 8 })
            .onClick((): void => { void this.save() })
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s5 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('睡前三分钟：把今天收成一句，明天只带一件事走')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(20)
              .width('100%')

            Text('此刻心情')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Column({ space: 8 }) {
              Row({ space: 8 }) {
                ForEach(MoodPreset.firstRow(), (m: MoodPreset) => {
                  Text(m.label)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.mood === m.label ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.mood === m.label ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.mood = m.label })
                }, (m: MoodPreset) => m.key)
              }
              .width('100%')
              Row({ space: 8 }) {
                ForEach(MoodPreset.secondRow(), (m: MoodPreset) => {
                  Text(m.label)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.mood === m.label ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.mood === m.label ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.mood = m.label })
                }, (m: MoodPreset) => m.key)
              }
              .width('100%')
            }
            .width('100%')

            Text('今天最想记住的一件事？')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.keep, placeholder: '一句就够，不必写成日记…' })
              .height(80)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.keep = v })

            Text('明天只做一件事')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.tomorrow, placeholder: '保存后会放入今日待办，方便明天执行' })
              .height(72)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.tomorrow = v })

            AppButton({
              label: '保存今日收束',
              onTap: (): void => { void this.save() }
            })
            Row().height(Theme.space.s10)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 52 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
