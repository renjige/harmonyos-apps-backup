import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { YdGoalItem, YdMilestoneItem } from '../models/YdModels'
import { YdLocalStore } from '../services/YdLocalStore'
import { YdDetailNav } from '../services/YdDetailNav'

enum GoalTab {
  Active = 0,
  Archived = 1
}

@Component
export struct GoalsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State tab: GoalTab = GoalTab.Active
  @State goals: YdGoalItem[] = []
  @State archived: YdGoalItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.goals = await YdLocalStore.loadActiveGoals()
    this.archived = await YdLocalStore.loadArchivedGoals()
  }

  private list(): YdGoalItem[] {
    return this.tab === GoalTab.Active ? this.goals : this.archived
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_ambient'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 180,
            colors: [['rgba(10,37,64,0.1)', 0], ['rgba(10,37,64,0.82)', 1]]
          })
        Row() {
          Column({ space: 4 }) {
            Text('目标看板')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(`${this.goals.length} 个进行中 · ${this.archived.length} 个已达成`)
              .fontSize(Theme.type.bodyS)
              .fontColor('rgba(255,255,255,0.88)')
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Text('新建')
            .fontSize(Theme.type.body)
            .fontColor('#FFFFFF')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('rgba(255,255,255,0.18)')
            .borderRadius(Theme.radius.pill)
            .onClick(() => YdDetailNav.openGoalCreate())
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
      }
      .width('100%')
      .height(120)

      Row({ space: Theme.space.s2 }) {
        this.TabChip('进行中', GoalTab.Active)
        this.TabChip('已达成', GoalTab.Archived)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s2 })

      if (this.list().length === 0) {
        AppEmpty({
          title: this.tab === GoalTab.Active ? '还没有长期目标' : '暂无已达成目标',
          description: this.tab === GoalTab.Active
            ? '创建目标并拆解里程碑，每完成一步进度即时更新'
            : '在目标详情里勾选全部里程碑后会自动归档到这里',
          actionLabel: this.tab === GoalTab.Active ? '新建目标' : '',
          onAction: (): void => {
            if (this.tab === GoalTab.Active) {
              YdDetailNav.openGoalCreate()
            }
          }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.list(), (g: YdGoalItem) => {
              this.GoalCard(g)
            }, (g: YdGoalItem) => g.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  TabChip(label: string, value: GoalTab) {
    Text(`${label} ${value === GoalTab.Active ? this.goals.length : this.archived.length}`)
      .fontSize(Theme.type.subhead)
      .fontColor(this.tab === value ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.tab === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.tab = value
        void this.reload()
      })
  }

  @Builder
  GoalCard(g: YdGoalItem) {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppIcon({
            name: g.archived ? 'check' : 'chart',
            iconSize: Theme.icon.md,
            color: Theme.colors().brandPrimary
          })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.md)
        Column({ space: Theme.space.s1 }) {
          Text(g.title)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(2)
          if (g.summary.length > 0) {
            Text(g.summary)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(2)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')

      Progress({ value: g.progressPercent(), total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .style({ strokeWidth: 6 })

      Row() {
        Text(`${g.doneCount()} / ${g.milestones.length} 里程碑`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Blank()
        Text(`${g.progressPercent()}%`)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')

      if (g.milestones.length > 0) {
        Row({ space: Theme.space.s2 }) {
          ForEach(g.milestones.slice(0, 3), (m: YdMilestoneItem) => {
            Text(m.done ? '✓' : '○')
              .fontSize(Theme.type.caption)
              .fontColor(m.done ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
          }, (m: YdMilestoneItem) => m.id)
          if (g.milestones.length > 3) {
            Text(`+${g.milestones.length - 3}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
        }
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 12, color: 'rgba(10,37,64,0.05)', offsetX: 0, offsetY: 2 })
    .onClick(() => YdDetailNav.openGoalDetail(g.id))
  }
}
