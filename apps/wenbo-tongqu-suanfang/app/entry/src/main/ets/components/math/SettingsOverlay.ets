import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MathSettings } from '../../models/MathModels'
import { MathFeedbackService } from '../../services/MathFeedbackService'

@Component
export struct SettingsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onSettingsPropChange') settings: MathSettings = new MathSettings()
  @State daily: number = 10
  @State difficulty: string = 'easy'
  @State sound: boolean = true
  @State motion: boolean = true
  @State grade: string = 'age68'
  @State planPreset: string = 'balance'
  @State confirmClear: boolean = false
  @State toastText: string = ''
  @State previewStar: number = 1
  @State previewPulse: number = 1
  onClose: () => void = () => {}
  onChange: (next: MathSettings) => void = (_n: MathSettings) => {}
  onClear: () => void = () => {}

  aboutToAppear(): void {
    this.syncFromProp()
  }

  onSettingsPropChange(): void {
    this.syncFromProp()
  }

  private syncFromProp(): void {
    this.daily = this.settings.dailyCount
    this.difficulty = this.settings.difficulty
    this.sound = this.settings.sound
    this.motion = this.settings.motion
    this.grade = this.settings.grade.length > 0 ? this.settings.grade : 'age68'
    this.planPreset = this.settings.planPreset.length > 0 ? this.settings.planPreset : 'balance'
  }

  private emit(): void {
    const next = new MathSettings()
    next.dailyCount = this.daily
    next.difficulty = this.difficulty
    next.sound = this.sound
    next.motion = this.motion
    next.grade = this.grade
    next.planStart = this.settings.planStart
    next.planPreset = this.planPreset
    next.weekGoal = this.settings.weekGoal > 0 ? this.settings.weekGoal : 50
    this.onChange(next)
    this.toastText = '已更新'
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private diffLabel(): string {
    if (this.difficulty === 'hard') {
      return '进阶'
    }
    if (this.difficulty === 'medium') {
      return '熟练'
    }
    return '入门'
  }

  private cycleDaily(): void {
    if (this.daily === 5) {
      this.daily = 10
    } else if (this.daily === 10) {
      this.daily = 15
    } else if (this.daily === 15) {
      this.daily = 20
    } else {
      this.daily = 5
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

  private gradeLabel(): string {
    if (this.grade === 'age35') {
      return '3-5 岁启蒙'
    }
    if (this.grade === 'age912' || this.grade === 'g3') {
      return '9-12 岁提升'
    }
    return '6-8 岁基础'
  }

  private cycleGrade(): void {
    if (this.grade === 'age35') {
      this.grade = 'age68'
    } else if (this.grade === 'age68' || this.grade === 'g1' || this.grade === 'g2') {
      this.grade = 'age912'
    } else {
      this.grade = 'age35'
    }
    this.emit()
  }

  private planLabel(): string {
    if (this.planPreset === 'addsub') {
      return '加减为主'
    }
    if (this.planPreset === 'story') {
      return '应用题为主'
    }
    if (this.planPreset === 'sense') {
      return '数感为主'
    }
    return '均衡练习'
  }

  private cyclePlan(): void {
    if (this.planPreset === 'balance') {
      this.planPreset = 'addsub'
    } else if (this.planPreset === 'addsub') {
      this.planPreset = 'story'
    } else if (this.planPreset === 'story') {
      this.planPreset = 'sense'
    } else {
      this.planPreset = 'balance'
    }
    this.emit()
  }

  private previewMotion(): void {
    if (!this.motion) {
      this.previewStar = 1
      this.previewPulse = 1
      return
    }
    this.previewStar = 0.75
    this.previewPulse = 0.92
    animateTo({ duration: 260, curve: Curve.EaseOut }, () => {
      this.previewStar = 1.18
      this.previewPulse = 1.06
    })
    setTimeout(() => {
      animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
        this.previewStar = 1
        this.previewPulse = 1
      })
    }, 280)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
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
        Text('设置')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Column({ space: Theme.space.s1 }) {
              Text('每日练习数量')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('今日挑战与首页进度按此题量计算')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            Text(`${this.daily} 题`)
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.cycleDaily())

          Row() {
            Column({ space: Theme.space.s1 }) {
              Text('难度设置')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('入门 · 熟练 · 进阶，数字范围会随之变化')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            Text(this.diffLabel())
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.cycleDiff())

          Row() {
            Column({ space: Theme.space.s1 }) {
              Text('年龄阶段')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('幼儿启蒙 3-5 岁 · 基础计算 6-8 岁 · 思维提升 9-12 岁')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            Text(this.gradeLabel())
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.cycleGrade())

          Row() {
            Column({ space: Theme.space.s1 }) {
              Text('练习计划')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('七日计划按此主题出题，可随时更换')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            Text(this.planLabel())
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.cyclePlan())

          Row() {
            Column({ space: Theme.space.s1 }) {
              Text('声音')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('答题时播放轻提示音')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.sound })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean) => {
                this.sound = v
                this.emit()
                if (v) {
                  MathFeedbackService.playTap(true)
                }
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row() {
            Column({ space: Theme.space.s1 }) {
              Text('动效')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('答题时显示轻量动画')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              if (this.motion) {
                Row({ space: Theme.space.s2 }) {
                  Text('⭐')
                    .fontSize(20)
                    .scale({ x: this.previewStar, y: this.previewStar })
                  Column()
                    .width(48)
                    .height(6)
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.pill)
                    .scale({ x: this.previewPulse, y: 1 })
                }
                .margin({ top: Theme.space.s2 })
              }
            }
            .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.motion })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean) => {
                this.motion = v
                this.emit()
                this.previewMotion()
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row() {
            Column({ space: Theme.space.s1 }) {
              Text('数据管理')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().danger)
                .width('100%')
              Text('清除本地练习记录')
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
          .onClick(() => { this.confirmClear = true })
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
          Text('星星、错题和连续天数都会消失，此操作不能恢复。')
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

    if (this.toastText.length > 0) {
      Text(this.toastText)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
        .backgroundColor('#2563EB')
        .borderRadius(Theme.radius.pill)
        .margin({ top: 56 })
        .zIndex(30)
    }
    }
    .width('100%')
    .height('100%')
  }
}
