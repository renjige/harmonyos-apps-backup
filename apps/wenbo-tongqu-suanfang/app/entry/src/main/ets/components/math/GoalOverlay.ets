import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MathBizService } from '../../services/MathBizService'

@Component
export struct GoalOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State target: number = 50
  @State done: number = 0
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.target = MathBizService.goalTarget()
    this.done = MathBizService.weekAnswered()
  }

  private async cycle(): Promise<void> {
    if (this.target === 30) {
      this.target = 50
    } else if (this.target === 50) {
      this.target = 80
    } else if (this.target === 80) {
      this.target = 100
    } else {
      this.target = 30
    }
    await MathBizService.setWeekGoal(this.target)
  }

  private pct(): number {
    if (this.target <= 0) {
      return 0
    }
    const p = Math.floor((this.done / this.target) * 100)
    return p > 100 ? 100 : p
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('本周目标')
          .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%').padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      Column({ space: Theme.space.s4 }) {
        Text(`已完成 ${this.done} / ${this.target} 题`)
          .fontSize(Theme.type.title2).fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(`完成度 ${this.pct()}%`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Stack({ alignContent: Alignment.Start }) {
          Row().width('100%').height(10).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(99)
          Row().width(`${this.pct()}%`).height(10)
            .backgroundColor(Theme.colors().brandPrimary).borderRadius(99)
        }
        .width('100%').height(10)
        Text('目标按本周真实作答题数计算，点下面切换 30 / 50 / 80 / 100。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: `本周目标 ${this.target} 题`,
          onTap: (): void => { void this.cycle() }
        })
      }
      .padding(Theme.space.s6)
      .width('100%')
      Blank().layoutWeight(1)
    }
    .width('100%').height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
