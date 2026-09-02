import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct HomeWorkbenchHero {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop weekCapture: number = 0
  @Prop weekGoal: number = 5
  @Prop checkInToday: boolean = false
  @Prop loggedIn: boolean = false
  onContinue: () => void = () => {}
  onCheckIn: () => void = () => {}

  private ratio(): number {
    if (this.weekGoal <= 0) {
      return 0
    }
    const r = this.weekCapture / this.weekGoal
    if (r > 1) {
      return 1
    }
    return r
  }

  private percent(): number {
    return Math.round(this.ratio() * 100)
  }

  private barWidth(): string {
    const p = this.percent()
    if (p < 8 && this.weekCapture > 0) {
      return '8%'
    }
    return `${p}%`
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日进度')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Text(this.loggedIn ? `${this.percent()}%` : '—')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnInverse)
        Column({ space: 4 }) {
          Text(this.loggedIn
            ? (this.checkInToday ? '今天已留下创意痕迹' : '本周挑战进行中')
            : '登录后追踪本周节奏')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnInverse)
            .width('100%')
          Text(this.loggedIn
            ? `已完成 ${this.weekCapture} / ${this.weekGoal} 条捕捉`
            : '捕捉 → 钉板 → 计划，不是记完就结束')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnInverse)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(12)
          .backgroundColor('rgba(255,255,255,0.22)')
          .borderRadius(Theme.radius.pill)
        Row()
          .width(this.barWidth())
          .height(12)
          .backgroundColor(Theme.colors().brandAccent)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')

      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({
            label: this.loggedIn && this.weekCapture >= this.weekGoal ? '再记一条' : '继续捕捉 →',
            variant: 'secondary',
            onTap: (): void => { this.onContinue() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { this.onContinue() })
        if (this.loggedIn) {
          Column() {
            AppButton({
              label: this.checkInToday ? '已打卡' : '今日打卡',
              variant: 'ghost',
              onTap: (): void => { this.onCheckIn() }
            })
          }
          .layoutWeight(1)
          .onClick((): void => { this.onCheckIn() })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s5)
    .alignItems(HorizontalAlign.Start)
  }
}
