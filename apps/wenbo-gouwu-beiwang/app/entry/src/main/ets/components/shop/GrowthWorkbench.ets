import { Theme } from '../design-system/Theme'
import { ProgressTrack, SectionTitle } from './ShoppingCards'
import { ActivityEvent, GrowthSnapshot, ProcurementPlan } from '../../models/ShoppingModels'

@Component
export struct GrowthWorkbench {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop growth: GrowthSnapshot = new GrowthSnapshot()
  @Prop plan: ProcurementPlan = new ProcurementPlan()
  @Prop hasPlan: boolean = false
  @Prop events: ActivityEvent[] = []
  onOpenGrowth: () => void = () => {}
  onOpenSearch: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenPlanEditor: () => void = () => {}
  onOpenTopics: () => void = () => {}

  build() {
    Column({ space: 12 }) {
      Row() {
        SectionTitle({ title: '采购工作台', action: '成长中心', onAction: () => this.onOpenGrowth() })
      }
      .width('100%')

      Row({ space: 8 }) {
        Text('搜索清单、物品、备忘、主题')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .layoutWeight(1)
          .padding({ left: 14, right: 14, top: 12, bottom: 12 })
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onOpenSearch())
      }
      .width('100%')

      Row({ space: 8 }) {
        this.Kpi('打卡', `${this.growth.checkInStreak}天`, () => this.onOpenGrowth())
        this.Kpi('收藏', `${this.growth.favoriteCount}`, () => this.onOpenFavorites())
        this.Kpi('成就', `${this.growth.achievementUnlocked}/${this.growth.achievementTotal}`, () => this.onOpenGrowth())
        this.Kpi('主题', `${this.growth.topicCount}`, () => this.onOpenTopics())
      }
      .width('100%')

      if (this.hasPlan) {
        Column({ space: 8 }) {
          Row() {
            Text(this.plan.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .layoutWeight(1)
            Text('编辑')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => this.onOpenPlanEditor())
          }
          .width('100%')
          ProgressTrack({
            done: this.growth.planDone,
            total: this.growth.planTarget > 0 ? this.growth.planTarget : 1
          })
          Text(`预算 ${this.growth.planBudgetUsed}/${this.growth.planBudgetTarget} 元`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onOpenPlanEditor())
      } else {
        Text('创建本周采购计划')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.xl)
          .onClick(() => this.onOpenPlanEditor())
      }

      if (this.events.length > 0) {
        Column({ space: 8 }) {
          Text('最近动态')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          ForEach(this.events, (e: ActivityEvent) => {
            Row() {
              Column({ space: 2 }) {
                Text(e.title)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(e.summary)
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
          }, (e: ActivityEvent) => e.id)
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onOpenGrowth())
      }
    }
    .width('100%')
  }

  @Builder
  Kpi(label: string, value: string, action: () => void) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.overline)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => action())
  }
}
