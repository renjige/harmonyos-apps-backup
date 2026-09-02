import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { OverlayShell } from './OverlayShell'
import { ReadingPlan } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct ReadingPlanListPane {
  @StorageLink('studyEpoch') @Watch('onChange') studyEpoch: number = 0
  @State plans: ReadingPlan[] = []
  onClose: () => void = () => {}
  onOpenPlan: (id: string) => void = (_id: string) => {}
  onCreatePlan: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.plans = await StudyStore.loadPlans()
  }

  build() {
    OverlayShell({
      title: '阅读计划',
      onClose: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      AppButton({
        label: '新建阅读计划',
        onTap: (): void => { this.onCreatePlan() }
      })
      if (this.plans.length === 0) {
        AppEmpty({
          title: '还没有阅读计划',
          description: '为某本书或本月阅读设一个摘录目标吧',
          actionLabel: '新建计划',
          onAction: (): void => { this.onCreatePlan() }
        })
      } else {
        ForEach(this.plans, (p: ReadingPlan) => {
          Column({ space: 6 }) {
            Row() {
              Text(p.title)
                .fontSize(Theme.type.bodyM)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Text(p.status === 'done' ? '已完成' : '进行中')
                .fontSize(Theme.type.caption)
                .fontColor(p.status === 'done' ? Theme.colors().brandAccent : Theme.colors().brandPrimary)
            }
            .width('100%')
            if (p.bookName.length > 0) {
              Text(`《${p.bookName}》`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            Text(`进度 ${p.doneCount}/${p.targetCount} · ${p.progressPercent()}%`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(12)
          .onClick((): void => { this.onOpenPlan(p.id) })
        }, (p: ReadingPlan) => `${p.id}_${p.updatedAt}`)
      }
    }
    .width('100%')
  }
}
