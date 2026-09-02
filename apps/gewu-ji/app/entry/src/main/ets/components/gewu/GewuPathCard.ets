import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
struct PathStepCell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop shortLabel: string = ''
  @Prop done: boolean = false
  onTap: () => void = () => {}

  build() {
    Column({ space: 4 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(44)
          .height(44)
          .borderRadius(22)
          .backgroundColor(this.done ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        if (this.done) {
          AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
        } else {
          Text(this.shortLabel)
            .fontSize(Theme.type.bodyS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
      }
      Text(this.label)
        .fontSize(10)
        .fontColor(this.done ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
        .maxLines(1)
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct GewuPathCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('homeRefreshTick') pathEpoch: number = 0
  @Prop doneCount: number = 0
  @Prop total: number = 5
  @Prop stepRead: boolean = false
  @Prop stepInquiry: boolean = false
  @Prop stepQuiz: boolean = false
  @Prop stepObserve: boolean = false
  @Prop stepCheckin: boolean = false
  onRead: () => void = () => {}
  onInquiry: () => void = () => {}
  onQuiz: () => void = () => {}
  onObserve: () => void = () => {}
  onCheckin: () => void = () => {}

  private pct(): number {
    if (this.total <= 0) {
      return 0
    }
    const v = (this.doneCount / this.total) * 100
    if (v > 100) {
      return 100
    }
    return v
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: Theme.space.s1 }) {
          Text('今日格物路径')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('读 → 问 → 测 → 记 → 候 · 图鉴格物闭环，非通用记事')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(`${this.doneCount}/${this.total}`)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')

      Progress({ value: this.pct(), total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(6)
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.pill)

      Row({ space: Theme.space.s2 }) {
        // pathEpoch 绑定刷新，确保 homeRefreshTick 变化时本行重绘
        Text(`${this.pathEpoch}`)
          .width(0)
          .height(0)
          .opacity(0)
        PathStepCell({
          label: '读今日一物',
          shortLabel: '读',
          done: this.stepRead,
          onTap: (): void => { this.onRead() }
        })
        PathStepCell({
          label: '格物三问',
          shortLabel: '问',
          done: this.stepInquiry,
          onTap: (): void => { this.onInquiry() }
        })
        PathStepCell({
          label: '格物小测',
          shortLabel: '测',
          done: this.stepQuiz,
          onTap: (): void => { this.onQuiz() }
        })
        PathStepCell({
          label: '写观察札',
          shortLabel: '记',
          done: this.stepObserve,
          onTap: (): void => { this.onObserve() }
        })
        PathStepCell({
          label: '物候打卡',
          shortLabel: '候',
          done: this.stepCheckin,
          onTap: (): void => { this.onCheckin() }
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().brandPrimaryContainer })
  }
}
