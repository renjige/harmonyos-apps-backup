import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { CwDateUtil, CwGoal, CwGoalCategory } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'
import { ChenwuMedia } from '../../services/ChenwuMedia'
import { CwConfirmDialog } from '../chenwu/CwConfirmDialog'

@Component
export struct GoalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop goalId: string = ''
  onChanged: () => void = () => {}
  @State goal: CwGoal = new CwGoal()
  @State catLabel: string = ''
  @State coverKey: string = 'cover_goal_learn'
  @State confirmDel: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await ChenwuStore.syncGoalProgress(this.goalId)
    const found = await ChenwuStore.findGoal(this.goalId)
    if (found !== undefined) {
      this.goal = found
    }
    const cats = await ChenwuStore.loadCategories()
    this.catLabel = ChenwuStore.categoryLabel(this.goal.categoryKey, cats)
    for (const c of cats) {
      if (c.key === this.goal.categoryKey) {
        this.coverKey = c.coverKey
      }
    }
  }

  private async remove(): Promise<void> {
    await ChenwuStore.deleteGoal(this.goalId)
    this.confirmDel = false
    this.onChanged()
    ChenwuDetailNav.closeGoal()
  }

  private openAddPlan(): void {
    ChenwuDetailNav.openPlanEditorForGoal(this.goal.id)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ChenwuMedia.coverOf(this.coverKey))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({ angle: 180, colors: [['rgba(61,90,108,0)', 0], ['rgba(61,90,108,0.82)', 1]] })
            Text(this.goal.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F7F5F0')
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.md)

          Text(`${this.catLabel} · 进度 ${this.goal.progress}% · ${CwDateUtil.displayDate(this.goal.startDate)}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Progress({ value: this.goal.progress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(6)
            .color(Theme.colors().brandPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)

          AppCard({ title: '目标说明' }) {
            Text(this.goal.description.length > 0 ? this.goal.description : '暂无描述，可编辑补充')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          AppButton({ label: '编辑目标', onTap: (): void => { ChenwuDetailNav.openGoalEditor(this.goal.id) } })
          Row() {
            AppButton({ label: '添加计划', variant: 'primary', onTap: (): void => { this.openAddPlan() } })
          }
          .width('100%')
          .onClick((): void => { this.openAddPlan() })
          AppButton({ label: '删除目标', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)

      if (this.confirmDel) {
        CwConfirmDialog({
          title: '删除这个目标？',
          message: '删除后无法恢复，关联计划需手动清理。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
