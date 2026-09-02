import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ObserveWorkflowCard {
  onOpenAtlas: () => void = () => {}
  onOpenRecords: () => void = () => {}
  onOpenInsight: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('观物闭环')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('分类记录 → 图鉴建档 → 成长时间轴 → 洞察报告，不止于单条日志')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(20)
        .width('100%')

      Row({ space: Theme.space.s2 }) {
        Column() {
          AppButton({ label: '物品图鉴', variant: 'primary', onTap: (): void => this.onOpenAtlas() })
        }.layoutWeight(1)
        Column() {
          AppButton({ label: '全部记录', variant: 'secondary', onTap: (): void => this.onOpenRecords() })
        }.layoutWeight(1)
      }
      .width('100%')

      AppButton({
        label: '查看洞察与本周回顾',
        variant: 'ghost',
        onTap: (): void => this.onOpenInsight()
      })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.md)
  }
}
