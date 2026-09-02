import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { GrowthSnapshot, PracticeSession, WeekMark } from '../models/KingdomModels'
import { KingdomBizService } from '../services/KingdomBizService'
import { KingdomLocalStore } from '../services/KingdomLocalStore'

@Component
export struct ReportPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @State growth: GrowthSnapshot = new GrowthSnapshot()
  @State week: WeekMark[] = []
  @State recent: PracticeSession[] = []
  onOpenDiagnose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.growth = KingdomBizService.growth()
    this.week = KingdomBizService.weekMarks()
    const all = KingdomLocalStore.snapshot().sessions
    const out: PracticeSession[] = []
    const start = all.length > 5 ? all.length - 5 : 0
    for (let i = start; i < all.length; i++) {
      out.push(all[i])
    }
    this.recent = out
  }

  private skillPct(n: number): number {
    const g = this.growth
    let max = g.observe
    if (g.logic > max) {
      max = g.logic
    }
    if (g.memory > max) {
      max = g.memory
    }
    if (g.create > max) {
      max = g.create
    }
    if (max <= 0) {
      return 8
    }
    const pct = Math.floor((n / max) * 100)
    return pct < 8 ? 8 : pct
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Text('成长报告')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ top: Theme.space.s2 })

        Column({ space: Theme.space.s2 }) {
          Text(this.currentUsername.length > 0 ? this.currentUsername : '小探索者')
            .fontSize(Theme.type.subtitleM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .textAlign(TextAlign.Center)
          Row({ space: Theme.space.s2 }) {
            AppIcon({ name: 'ai', iconSize: 28, color: Theme.colors().brandAccent })
            Text(`${this.growth.stars}`)
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          Text(`已完成 ${this.growth.levelsDone} 关 · 连续 ${this.growth.streak} 天`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(Theme.space.s5)
        .borderRadius(24)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        Column({ space: Theme.space.s3 }) {
          Text('练习次数（观察 / 逻辑 / 记忆 / 创造）')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          this.SkillRow('观察', this.growth.observe)
          this.SkillRow('逻辑', this.growth.logic)
          this.SkillRow('记忆', this.growth.memory)
          this.SkillRow('创造', this.growth.create)
          Text('这是练习次数，不是智力测评，也不承诺考试成绩。')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .borderRadius(24)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        Column({ space: Theme.space.s3 }) {
          Text('近七天')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row() {
            ForEach(this.week, (m: WeekMark) => {
              Column({ space: 6 }) {
                Column()
                  .width(28)
                  .height(28)
                  .borderRadius(14)
                  .backgroundColor(m.done ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                Text(m.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }, (m: WeekMark) => m.label)
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .borderRadius(24)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        Column({ space: Theme.space.s3 }) {
          Text('最近练习')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.recent.length === 0) {
            AppEmpty({
              title: '还没有练习记录',
              description: '新探索者从大厅踏上石阶后，这里才会出现自己的关卡。'
            })
          } else {
            ForEach(this.recent, (s: PracticeSession) => {
              Row() {
                Text(s.date)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                Blank()
                Text(`${s.kind === 'daily' ? '每日' : '闯关'} · ${s.correct}/${s.total} · ${s.stars} 星`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .width('100%')
              .height(44)
            }, (s: PracticeSession) => s.id)
          }
        }
        .width('100%')
        .padding(Theme.space.s5)
        .borderRadius(24)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        AppButton({
          label: '能力小测',
          variant: 'secondary',
          onTap: () => this.onOpenDiagnose()
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  SkillRow(label: string, value: number) {
    Column({ space: 6 }) {
      Row() {
        Text(label)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text(`${value}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
      Stack({ alignContent: Alignment.Start }) {
        Row().width('100%').height(8).borderRadius(99).backgroundColor(Theme.colors().surfaceSubtle)
        Row()
          .width(`${this.skillPct(value)}%`)
          .height(8)
          .borderRadius(99)
          .backgroundColor(Theme.colors().brandPrimary)
      }
      .width('100%')
      .height(8)
    }
    .width('100%')
  }
}
