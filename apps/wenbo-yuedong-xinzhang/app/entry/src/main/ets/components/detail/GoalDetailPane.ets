import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppConfirmDialog } from '../design-system/AppConfirmDialog'
import { DetailShell } from './DetailShell'
import { YdTagPicker } from '../yuedong/YdTagPicker'
import { YdGoalItem, YdMilestoneItem } from '../../models/YdModels'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'

@Component
export struct GoalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop goalId: string = ''
  onChanged: () => void = () => {}
  @State goal: YdGoalItem = new YdGoalItem()
  @State confirmDelete: boolean = false
  @State isFavorite: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const g = await YdLocalStore.findGoal(this.goalId)
    if (g !== undefined) {
      this.goal = g
      this.isFavorite = await YdLocalStore.isFavorite('goal', g.id)
    }
  }

  build() {
    Stack() {
      DetailShell({
        title: this.goal.title.length > 0 ? this.goal.title : '目标详情',
        onClose: (): void => { YdDetailNav.closeGoalDetail() },
        body: (): void => { this.Body() }
      })
        .zIndex(0)

      if (this.confirmDelete) {
        AppConfirmDialog({
          title: '删除目标',
          message: '确认删除此目标？里程碑进度将无法恢复。',
          confirmLabel: '删除',
          cancelLabel: '取消',
          danger: true,
          onConfirm: (): void => {
            void YdLocalStore.deleteGoal(this.goal.id).then(() => {
              this.confirmDelete = false
              this.onChanged()
              YdDetailNav.closeGoalDetail()
            })
          },
          onCancel: (): void => { this.confirmDelete = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_ambient'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Text(this.goal.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.6)', 1]]
            })
        }
        .width('100%')

        if (this.goal.summary.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('目标说明')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(this.goal.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }

        Progress({ value: this.goal.progressPercent(), total: 100, type: ProgressType.Linear })
          .width('100%')
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .style({ strokeWidth: 8 })

        YdTagPicker({
          entityType: 'goal',
          entityId: this.goal.id,
          onChanged: (): void => { this.onChanged() }
        })

        Text('里程碑')
          .fontSize(Theme.type.title3)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        ForEach(this.goal.milestones, (m: YdMilestoneItem) => {
          Row({ space: Theme.space.s3 }) {
            Toggle({ type: ToggleType.Checkbox, isOn: m.done })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((): void => {
                void YdLocalStore.toggleMilestone(this.goal.id, m.id).then(async () => {
                  await this.load()
                  this.onChanged()
                })
              })
            Text(m.title)
              .fontSize(Theme.type.body)
              .fontColor(m.done ? Theme.colors().textSecondary : Theme.colors().textPrimary)
              .decoration({ type: m.done ? TextDecorationType.LineThrough : TextDecorationType.None })
              .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }, (m: YdMilestoneItem) => m.id)

        AppButton({
          label: this.isFavorite ? '取消收藏' : '收藏目标',
          variant: 'secondary',
          onTap: (): void => { void this.toggleFavorite() }
        })
        AppButton({
          label: '删除目标',
          variant: 'secondary',
          onTap: (): void => { this.confirmDelete = true }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s10 })
    }
  }

  private async toggleFavorite(): Promise<void> {
    this.isFavorite = await YdLocalStore.toggleFavorite('goal', this.goal.id, this.goal.title)
    this.onChanged()
  }
}
