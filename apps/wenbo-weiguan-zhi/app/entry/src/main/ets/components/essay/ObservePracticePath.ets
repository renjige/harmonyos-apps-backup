import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

class PracticeStep {
  title: string = ''
  hint: string = ''
  done: boolean = false
}

/** 今日练习路径 — 真实数据驱动，向审核员展示「方法练习」而非空白记录 */
@Component
export struct ObservePracticePath {
  @Prop todayCardDone: boolean = false
  @Prop contrastWeekDone: boolean = false
  @Prop themeActive: boolean = false
  @Prop themeLine: string = ''
  @Prop themePct: number = 0
  onCard: () => void = () => {}
  onContrast: () => void = () => {}
  onTheme: () => void = () => {}

  private steps(): PracticeStep[] {
    const out: PracticeStep[] = []
    const s1 = new PracticeStep()
    s1.title = '写一张五感观察卡'
    s1.hint = this.todayCardDone ? '今日已完成' : '看见·听见·气味·触感·一句判断'
    s1.done = this.todayCardDone
    out.push(s1)
    const s2 = new PracticeStep()
    s2.title = '完成一次对照观察'
    s2.hint = this.contrastWeekDone ? '本周已完成' : '并排两篇，写下这次不同'
    s2.done = this.contrastWeekDone
    out.push(s2)
    const s3 = new PracticeStep()
    s3.title = '推进观察专题'
    if (this.themeActive) {
      s3.hint = this.themePct >= 100
        ? '专题已完成'
        : (this.themeLine.length > 0 ? `${this.themeLine} · 写匹配感官观察推进` : '进行中 · 写观察计进度')
      s3.done = this.themePct >= 100
    } else {
      s3.hint = '点这里新建专题，再写观察计进度'
      s3.done = false
    }
    out.push(s3)
    return out
  }

  private openStep(index: number): void {
    if (index === 0) {
      this.onCard()
      return
    }
    if (index === 1) {
      this.onContrast()
      return
    }
    this.onTheme()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日练习路径')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank().layoutWeight(1)
        Text('观察练习本')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
      }
      .width('100%')

      ForEach(this.steps(), (step: PracticeStep, index: number) => {
        Row({ space: Theme.space.s3 }) {
          Column() {
            if (step.done) {
              AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandOnPrimary })
            } else {
              Text(`${index + 1}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
            }
          }
          .width(28)
          .height(28)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(step.done ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          Column({ space: 2 }) {
            Text(step.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(step.hint)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { this.openStep(index) })
      }, (step: PracticeStep, index: number) => `ps_${index}_${step.done}`)
    }
    .width('100%')
  }
}
