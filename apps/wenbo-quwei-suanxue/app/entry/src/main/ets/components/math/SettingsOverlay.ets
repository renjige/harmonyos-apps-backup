import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MathSettings } from '../../models/MathModels'

@Component
export struct SettingsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop settings: MathSettings = new MathSettings()
  @State daily: number = 10
  @State practice: number = 10
  @State difficulty: string = 'easy'
  @State sound: boolean = true
  @State motion: boolean = true
  @State timedMode: boolean = false
  @State remindStudy: boolean = false
  @State confirmClear: boolean = false
  onClose: () => void = () => {}
  onChange: (next: MathSettings) => void = (_n: MathSettings) => {}
  onClear: () => void = () => {}

  aboutToAppear(): void {
    this.daily = this.settings.dailyCount
    this.practice = this.settings.practiceCount
    this.difficulty = this.settings.difficulty
    this.sound = this.settings.sound
    this.motion = this.settings.motion
    this.timedMode = this.settings.timedMode
    this.remindStudy = this.settings.remindStudy
  }

  private emit(): void {
    const next = new MathSettings()
    next.dailyCount = this.daily
    next.practiceCount = this.practice
    next.difficulty = this.difficulty
    next.sound = this.sound
    next.motion = this.motion
    next.timedMode = this.timedMode
    next.remindStudy = this.remindStudy
    this.onChange(next)
  }

  private diffLabel(): string {
    if (this.difficulty === 'hard') {
      return '高级（乘除混合）'
    }
    if (this.difficulty === 'medium') {
      return '中级（100 以内）'
    }
    return '初级（10 以内）'
  }

  private cycleDaily(): void {
    if (this.daily === 5) {
      this.daily = 10
    } else if (this.daily === 10) {
      this.daily = 20
    } else {
      this.daily = 5
    }
    this.emit()
  }

  private cyclePractice(): void {
    if (this.practice === 5) {
      this.practice = 10
    } else if (this.practice === 10) {
      this.practice = 20
    } else {
      this.practice = 5
    }
    this.emit()
  }

  private cycleDiff(): void {
    if (this.difficulty === 'easy') {
      this.difficulty = 'medium'
    } else if (this.difficulty === 'medium') {
      this.difficulty = 'hard'
    } else {
      this.difficulty = 'easy'
    }
    this.emit()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .rotate({ angle: 180 })
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('智慧设置')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Blank().width(44)
      }
      .padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          this.row('每日智慧挑战', `${this.daily} 题`, false, () => this.cycleDaily())
          this.row('训练题量', `${this.practice} 题`, false, () => this.cyclePractice())
          this.row('难度分级', this.diffLabel(), false, () => this.cycleDiff())
          this.toggleRow('计时模式', '训练时显示答题用时', this.timedMode, (v: boolean) => {
            this.timedMode = v
            this.emit()
          })
          this.toggleRow('学习提醒', '每日练习提醒（本地开关）', this.remindStudy, (v: boolean) => {
            this.remindStudy = v
            this.emit()
          })
          this.toggleRow('音效', '答题时播放轻提示音', this.sound, (v: boolean) => {
            this.sound = v
            this.emit()
          })
          this.toggleRow('动效', '答题时显示轻量动画', this.motion, (v: boolean) => {
            this.motion = v
            this.emit()
          })
          this.row('清除缓存', '清除本地练习记录', true, () => { this.confirmClear = true })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      if (this.confirmClear) {
        Column({ space: Theme.space.s4 }) {
          Text('清除本地练习记录？')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('积分、错题和连续天数都会消失，此操作不能恢复。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({ label: '确认清除', variant: 'danger', onTap: () => {
            this.confirmClear = false
            this.onClear()
          } })
          AppButton({ label: '取消', variant: 'secondary', onTap: () => { this.confirmClear = false } })
        }
        .padding(Theme.space.s5)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s7 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  row(title: string, value: string, danger: boolean, tap: () => void) {
    Row() {
      Column({ space: Theme.space.s1 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontColor(danger ? Theme.colors().danger : Theme.colors().textPrimary)
          .width('100%')
        Text(value)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(tap)
  }

  @Builder
  toggleRow(title: string, hint: string, on: boolean, tap: (v: boolean) => void) {
    Row() {
      Column({ space: Theme.space.s1 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(hint)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: on })
        .selectedColor(Theme.colors().brandPrimary)
        .onChange((v: boolean) => tap(v))
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
