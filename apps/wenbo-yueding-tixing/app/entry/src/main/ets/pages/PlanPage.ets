import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { PlanSummaryCard } from '../components/appointment/WorkbenchCards'
import { CommitmentPlan } from '../models/GrowthModels'
import { GrowthService } from '../services/GrowthService'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State plans: CommitmentPlan[] = []
  @State tab: string = 'active'
  @State loading: boolean = true
  @Prop @Watch('onTick') refreshToken: number = 0
  onCreate: () => void = () => {}
  onOpenPlan: (id: string) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private filtered(): CommitmentPlan[] {
    const out: CommitmentPlan[] = []
    for (const row of this.plans) {
      if (this.tab === 'active' && row.status === 'active') {
        out.push(row)
      } else if (this.tab === 'done' && (row.status === 'done' || row.status === 'archived')) {
        out.push(row)
      }
    }
    return out
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.plans = await GrowthService.listPlans()
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '守约计划', subtitle: '设定目标 · 关联约定 · 跟踪进度' })
      Row({ space: 8 }) {
        Text('进行中')
          .fontSize(Theme.type.caption)
          .fontColor(this.tab === 'active' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(this.tab === 'active' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.tab = 'active' })
        Text('已完成')
          .fontSize(Theme.type.caption)
          .fontColor(this.tab === 'done' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(this.tab === 'done' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.tab = 'done' })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '加载计划…' }).layoutWeight(1)
      } else if (this.filtered().length === 0) {
        Column() {
          AppEmpty({
            title: this.tab === 'active' ? '还没有守约计划' : '暂无已完成计划',
            description: '设定目标次数，完成约定后自动累计进度',
            actionLabel: '创建第一个计划',
            onAction: (): void => { this.onCreate() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.filtered(), (plan: CommitmentPlan) => {
              PlanSummaryCard({
                title: plan.title,
                progressText: `${plan.doneCount}/${plan.targetCount} · ${plan.statusLabel()}`,
                percent: plan.progressPercent(),
                onTap: (): void => { this.onOpenPlan(plan.id) }
              })
            }, (plan: CommitmentPlan) => plan.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      Column() {
        AppButton({ label: '新建守约计划', onTap: (): void => { this.onCreate() } })
      }
      .width('100%')
      .padding(Theme.space.pageX)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
