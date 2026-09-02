import { Theme } from '../design-system/Theme'
import { PlanItem } from '../../models/LifeGrowthModels'

@Component
export struct HomePlanStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop plans: PlanItem[] = []
  @Prop listEpoch: number = 0

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('进行中的计划')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('管理计划')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { AppStorage.setOrCreate('pendingTab', 2) })
      }
      .width('100%')
      if (this.plans.length === 0) {
        Text('创建本周计划，把想做的事拆成任务，完成度会显示在首页进度里。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text('去创建计划')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { AppStorage.setOrCreate('pendingTab', 2) })
      } else {
        ForEach(this.plans, (p: PlanItem) => {
          Column({ space: 6 }) {
            Text(p.title)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Row() {
              Column()
                .width(`${p.progressPct()}%`)
                .height(6)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
            }
            .width('100%')
            .height(6)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            Text(`已完成 ${p.doneCount()} / ${p.tasks.length} · ${p.progressPct()}%`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s3)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { AppStorage.setOrCreate('pendingTab', 2) })
        }, (p: PlanItem) => `${p.id}_${p.progressPct()}_${this.listEpoch}`)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
