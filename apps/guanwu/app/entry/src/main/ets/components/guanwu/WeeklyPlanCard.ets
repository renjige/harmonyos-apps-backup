import { Theme } from '../design-system/Theme'
import { PlanItem } from '../../services/ObservePlanService'

@Component
export struct WeeklyPlanCard {
  @Prop @Watch('onItemsChange') items: PlanItem[] = []
  onToggle: (id: string) => void = () => {}

  onItemsChange(): void {
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('本周观察计划')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('长期任务：图鉴建档、成长对比与照片整理')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      ForEach(this.items, (item: PlanItem) => {
        Row({ space: Theme.space.s2 }) {
          Toggle({ type: ToggleType.Checkbox, isOn: item.done })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((): void => { this.onToggle(item.id) })
          Text(item.label)
            .fontSize(Theme.type.body)
            .fontColor(item.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
            .decoration({ type: item.done ? TextDecorationType.LineThrough : TextDecorationType.None })
            .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (item: PlanItem) => `${item.id}-${item.done}`)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
