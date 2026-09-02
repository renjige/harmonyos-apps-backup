import { Theme } from '../design-system/Theme'
import { SolidButton } from '../design-system/SolidButton'
import { StageGoal } from '../../models/TrainingModels'
import { PracticeService } from '../../services/PracticeService'

@Component
export struct GoalCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop goal: StageGoal = new StageGoal()
  @Prop pendingDelete: boolean = false
  @State shown: number = 0
  @State kind: string = 'sessions'
  onBump: (id: string, delta: number) => void = () => {}
  onAskDelete: (id: string) => void = () => {}
  onGoRecord: () => void = () => {}

  aboutToAppear(): void {
    this.refreshShown()
  }

  onEpoch(): void {
    this.refreshShown()
  }

  private refreshShown(): void {
    this.kind = PracticeService.normalizeSync(this.goal.syncKind, this.goal.unit)
    this.shown = PracticeService.liveCount(this.goal)
  }

  private isAuto(): boolean {
    return this.kind === 'sessions' || this.kind === 'minutes'
  }

  private hint(): string {
    if (this.kind === 'sessions') {
      return '进度跟随训练记录：每保存一条，这里立刻 +1'
    }
    if (this.kind === 'minutes') {
      return '进度跟随训练时长：保存记录后分钟数立刻更新'
    }
    return '手动计数，点 +1 / −1 即时更新'
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(this.goal.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(`${this.shown} / ${this.goal.targetCount} ${this.goal.unit}`)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
      Text(this.hint())
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      if (this.isAuto()) {
        Column() {
          SolidButton({
            label: '去记一条训练',
            tone: 'primary',
            onTap: (): void => { this.onGoRecord() }
          })
        }
        .width('100%')
        .onClick((): void => { this.onGoRecord() })
      } else {
        Row({ space: Theme.space.s3 }) {
          Column() {
            SolidButton({
              label: '−1',
              tone: 'secondary',
              onTap: (): void => { this.onBump(this.goal.id, -1) }
            })
          }
          .layoutWeight(1)
          .onClick((): void => { this.onBump(this.goal.id, -1) })
          Column() {
            SolidButton({
              label: '+1',
              tone: 'primary',
              onTap: (): void => { this.onBump(this.goal.id, 1) }
            })
          }
          .layoutWeight(1)
          .onClick((): void => { this.onBump(this.goal.id, 1) })
        }
        .width('100%')
      }

      Text(this.pendingDelete ? '再点一次确认删除' : '删除目标')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().danger)
        .width('100%')
        .textAlign(TextAlign.End)
        .padding({ top: 4, bottom: 4 })
        .onClick((): void => { this.onAskDelete(this.goal.id) })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
