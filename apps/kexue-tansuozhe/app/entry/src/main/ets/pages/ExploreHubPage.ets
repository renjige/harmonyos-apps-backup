import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { ExploreTaskTemplate } from '../data/TaskBank'
import { ChallengeTrack, ChallengeDayStep } from '../data/ChallengeTrack'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { LayoutConstants } from '../components/design-system/LayoutConstants'
import { SectionHeader } from '../components/explore/SectionHeader'
import { ExploreToast } from '../services/ExploreToast'
import { DomainStat } from '../models/ExplorationModels'

@Component
export struct ExploreHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('progressRev') @Watch('onRev') progressRev: number = 0
  @State tasks: ExploreTaskTemplate[] = []
  @State tips: string[] = []
  @State domains: DomainStat[] = []
  @State challengeSteps: ChallengeDayStep[] = []
  @State completedDays: number[] = []
  @State doneTaskIds: string[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.tasks = ExplorationStore.dailyTasks()
    this.tips = ExplorationStore.wisdomTips()
    this.domains = ExplorationStore.domainStats()
    this.challengeSteps = ChallengeTrack.allSteps()
    this.completedDays = ExplorationStore.snapshot().challenge.completedDays
    const done: string[] = []
    for (const t of this.tasks) {
      if (ExplorationStore.isTaskDone(t.id)) {
        done.push(t.id)
      }
    }
    this.doneTaskIds = done
  }

  private isTaskDone(taskId: string): boolean {
    return this.doneTaskIds.indexOf(taskId) >= 0
  }

  private async handleCompleteTask(taskId: string): Promise<void> {
    if (this.isTaskDone(taskId)) {
      return
    }
    const next: string[] = []
    for (const id of this.doneTaskIds) {
      next.push(id)
    }
    next.push(taskId)
    this.doneTaskIds = next
    await ExplorationStore.completeTask(taskId)
    this.reload()
    ExploreToast.show('任务已标记完成')
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppHeader({ title: '探索中心', subtitle: '任务 · 挑战 · 领域' })

          SectionHeader({
            title: '7 日探索挑战',
            subtitle: ChallengeTrack.summary(),
            actionLabel: '详情 ›',
            onAction: (): void => { ExploreNav.openChallenge() }
          })
          Row() {
            Text(`进度 ${this.completedDays.length}/${ChallengeTrack.totalDays()} 天`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text('继续挑战')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .layoutWeight(1)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .padding(Theme.space.s5)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick((): void => { ExploreNav.openChallenge() })

          SectionHeader({ title: '今日探索任务', subtitle: '完成任意任务即可计入进度' })
          ForEach(this.tasks, (task: ExploreTaskTemplate) => {
            AppCard({ title: task.title, variant: 'outlined' }) {
              Row() {
                Text(task.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .layoutWeight(1)
                if (this.isTaskDone(task.id)) {
                  Text('已完成')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandAccent)
                } else {
                  Column() {
                    AppButton({
                      label: '标记完成',
                      variant: 'secondary',
                      onTap: (): void => { void this.handleCompleteTask(task.id) }
                    })
                  }
                  .onClick((): void => { void this.handleCompleteTask(task.id) })
                }
              }
              .width('100%')
            }
          }, (task: ExploreTaskTemplate) => `${task.id}_${this.isTaskDone(task.id)}`)

          SectionHeader({ title: '领域地图', subtitle: '五大领域探索进度' })
          ForEach(this.domains, (d: DomainStat) => {
            AppCard({
              title: d.label,
              variant: 'stat',
              pressable: true,
              onTap: (): void => { ExploreNav.openDomainMap() }
            }) {
              Row() {
                Text(`已探索 ${d.count} / ${d.total}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .layoutWeight(1)
                Text(`${Math.round(d.count * 100 / Math.max(d.total, 1))}%`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
            }
          }, (d: DomainStat) => `${d.category}_${d.count}_${this.progressRev}`)

          if (this.tips.length > 0) {
            AppCard({ title: '智慧探索', variant: 'outlined' }) {
              ForEach(this.tips, (tip: string) => {
                Text(`· ${tip}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                  .margin({ bottom: 6 })
              }, (tip: string) => tip)
            }
          }

          AppButton({
            label: '新建探索发现',
            onTap: (): void => { ExploreNav.openNewRecord() }
          })
          Row({ space: Theme.space.s2 }) {
            this.HubLink('我的收藏', (): void => { ExploreNav.openFavorites() })
            this.HubLink('探索专题', (): void => { ExploreNav.openTopics() })
            this.HubLink('探索日历', (): void => { ExploreNav.openCalendar() })
          }
          .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10 + LayoutConstants.tabBarInset()
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  HubLink(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick((): void => { onTap() })
  }
}
