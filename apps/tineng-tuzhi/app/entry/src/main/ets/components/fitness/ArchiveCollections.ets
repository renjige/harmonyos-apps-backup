import { Theme } from '../design-system/Theme'
import { CyclePlan, GoalChallenge, InsightFav, LibraryAction, PrepLine, PrepList } from '../../models/TrainingModels'
import { TrainingStore } from '../../services/TrainingStore'

@Component
export struct ArchiveCollections {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop plans: CyclePlan[] = []
  @Prop actions: LibraryAction[] = []
  @Prop lists: PrepList[] = []
  @Prop challenges: GoalChallenge[] = []
  @Prop favs: InsightFav[] = []
  onAddPlan: () => void = () => {}
  onAddAction: () => void = () => {}
  onAddList: () => void = () => {}
  onAddChallenge: () => void = () => {}
  onAddFav: () => void = () => {}
  onToggleChallenge: (id: string) => void = () => {}
  onToggleLine: (listId: string, index: number) => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      this.Head('训练计划', '新建', 'plan')
      ForEach(this.plans, (p: CyclePlan) => {
        Column({ space: 4 }) {
          Text(p.title)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Text(`${p.goalText} · ${p.periodDays} 天 · 自 ${p.startKey}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }, (p: CyclePlan) => p.id)

      this.Head('训练动作库', '新增', 'action')
      ForEach(this.actions, (a: LibraryAction) => {
        Column({ space: 4 }) {
          Text(`${TrainingStore.categoryLabel(a.category)} · ${a.name}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Text(a.desc)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }, (a: LibraryAction) => a.id)

      this.Head('训练清单', '新建', 'list')
      ForEach(this.lists, (p: PrepList) => {
        Column({ space: Theme.space.s2 }) {
          Text(p.title)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          ForEach(p.lines, (ln: PrepLine) => {
            Text(`${ln.done ? '[完成]' : '[待做]'}  ${ln.text}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
              .onClick((): void => { this.onToggleLine(ln.listId, ln.index) })
          }, (ln: PrepLine) => `${ln.listId}-${ln.index}`)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }, (p: PrepList) => p.id)

      this.Head('目标挑战', '新建', 'challenge')
      ForEach(this.challenges, (c: GoalChallenge) => {
        Text(`${c.done ? '已完成' : '进行中'} · ${c.title}（${c.target}）`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onToggleChallenge(c.id) })
      }, (c: GoalChallenge) => c.id)

      this.Head('运动心得收藏', '收藏', 'fav')
      ForEach(this.favs, (f: InsightFav) => {
        Column({ space: 4 }) {
          Text(f.title)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Text(f.body)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(3)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }, (f: InsightFav) => f.id)
    }
    .width('100%')
  }

  @Builder
  Head(title: string, action: string, kind: string) {
    Row() {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Blank()
      Text(action)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().brandPrimary)
        .onClick((): void => { this.runAdd(kind) })
    }
    .width('100%')
  }

  private runAdd(kind: string): void {
    if (kind === 'plan') {
      this.onAddPlan()
      return
    }
    if (kind === 'action') {
      this.onAddAction()
      return
    }
    if (kind === 'list') {
      this.onAddList()
      return
    }
    if (kind === 'challenge') {
      this.onAddChallenge()
      return
    }
    this.onAddFav()
  }
}
