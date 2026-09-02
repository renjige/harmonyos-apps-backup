import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { ChallengeTrack, ChallengeDayStep } from '../data/ChallengeTrack'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { ExploreToast } from '../services/ExploreToast'

@Component
export struct ChallengeOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State steps: ChallengeDayStep[] = []
  @State completed: number[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.steps = ChallengeTrack.allSteps()
    this.completed = ExplorationStore.snapshot().challenge.completedDays
  }

  private isDone(day: number): boolean {
    return this.completed.indexOf(day) >= 0
  }

  private async handleCompleteDay(day: number): Promise<void> {
    if (this.isDone(day)) {
      return
    }
    const next: number[] = []
    for (const d of this.completed) {
      next.push(d)
    }
    next.push(day)
    this.completed = next
    await ExplorationStore.completeChallengeDay(day)
    this.reload()
    ExploreToast.show(`第 ${day} 天已标记完成`)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: ChallengeTrack.title(),
        onClose: (): void => { ExploreNav.closeChallenge() }
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(ChallengeTrack.summary())
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')

            ForEach(this.steps, (step: ChallengeDayStep) => {
              Column({ space: Theme.space.s2 }) {
                Row() {
                  Text(`第 ${step.day} 天 · ${step.title}`)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text(this.isDone(step.day) ? '已完成' : '待完成')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.isDone(step.day) ?
                      Theme.colors().brandAccent : Theme.colors().textSecondary)
                }
                .width('100%')
                Text(step.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                if (!this.isDone(step.day)) {
                  Column() {
                    AppButton({
                      label: '标记今日完成',
                      variant: 'secondary',
                      onTap: (): void => { void this.handleCompleteDay(step.day) }
                    })
                  }
                  .width('100%')
                  .onClick((): void => { void this.handleCompleteDay(step.day) })
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (step: ChallengeDayStep) => `${step.day}_${this.isDone(step.day)}`)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
