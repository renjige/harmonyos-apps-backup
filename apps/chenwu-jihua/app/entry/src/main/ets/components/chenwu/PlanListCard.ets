import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CwPlan } from '../../models/ChenwuModels'
import { ChenwuMedia } from '../../services/ChenwuMedia'

export class CwHorizonLabels {
  static label(key: string): string {
    if (key === 'long') {
      return '长期'
    }
    if (key === 'short') {
      return '短期'
    }
    if (key === 'phase') {
      return '阶段'
    }
    return '计划'
  }

  static statusLabel(status: string): string {
    if (status === 'active') {
      return '进行中'
    }
    if (status === 'done') {
      return '已完成'
    }
    if (status === 'paused') {
      return '暂停'
    }
    return status
  }
}

@Component
export struct PlanListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop plan: CwPlan = new CwPlan()
  @Prop goalTitle: string = ''
  @Prop progressPct: number = 0
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(ChenwuMedia.bannerPlanPath())
        .width(56)
        .height(56)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)

      Column({ space: 4 }) {
        Text(this.plan.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${CwHorizonLabels.label(this.plan.horizonType)} · ${CwHorizonLabels.statusLabel(this.plan.status)} · ${this.progressPct}%`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
        if (this.goalTitle.length > 0) {
          Text(this.goalTitle)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(1)
            .width('100%')
        } else if (this.plan.summary.length > 0) {
          Text(this.plan.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onOpen() })
  }
}
