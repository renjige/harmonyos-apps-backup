import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { CwDateUtil, CwLookbackItem, CwStats, CwTimelineRow } from '../models/ChenwuModels'
import { ChenwuStore } from '../services/ChenwuStore'
import { ChenwuDetailNav } from '../services/ChenwuDetailNav'
import { ChenwuMedia } from '../services/ChenwuMedia'

export class CwTimelineLabels {
  static kindLabel(kind: string): string {
    if (kind === 'goal') {
      return '目标'
    }
    if (kind === 'plan') {
      return '计划'
    }
    if (kind === 'journal') {
      return '晨记'
    }
    if (kind === 'habit') {
      return '习惯'
    }
    return kind
  }
}

@Component
export struct LookbackPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('cwDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State rows: CwTimelineRow[] = []
  @State look: CwLookbackItem = new CwLookbackItem()
  @State stats: CwStats = new CwStats()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.rows = await ChenwuStore.buildTimeline()
    this.look = await ChenwuStore.buildLookback()
    this.stats = await ChenwuStore.computeStats()
  }

  private openRow(r: CwTimelineRow): void {
    if (r.kind === 'goal') {
      ChenwuDetailNav.openGoal(r.sourceId)
      return
    }
    if (r.kind === 'plan') {
      ChenwuDetailNav.openPlan(r.sourceId)
      return
    }
    if (r.kind === 'journal') {
      ChenwuDetailNav.openJournal(r.sourceId)
      return
    }
    if (r.kind === 'habit') {
      ChenwuDetailNav.openHabit(r.sourceId)
    }
  }

  build() {
    Column() {
      Text('智慧回望')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s3 })

      Row({ space: 8 }) {
        this.num('计划', `${this.stats.planCount}`)
        this.num('目标', `${this.stats.goalCount}`)
        this.num('完成', `${this.stats.taskDoneCount}`)
        this.num('连续', `${this.stats.streakMax}天`)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      .width('100%')

      Column({ space: 8 }) {
        Image(ChenwuMedia.coverReview())
          .width('100%')
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Text(this.look.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.look.body)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text('打开年度档案')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { ChenwuDetailNav.openAnnual() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      .width('100%')
      .onClick((): void => {
        if (this.look.sourceKind === 'goal') {
          ChenwuDetailNav.openGoal(this.look.sourceId)
        } else if (this.look.sourceKind === 'habit') {
          ChenwuDetailNav.openHabit(this.look.sourceId)
        } else if (this.look.sourceKind === 'journal') {
          ChenwuDetailNav.openJournal(this.look.sourceId)
        }
      })

      Text('成长时间线')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s4 })

      if (this.rows.length === 0) {
        AppEmpty({ title: '时间线还是空的', description: '创建目标、计划或写下晨记后会在这里展开' })
      } else {
        List() {
          ForEach(this.rows, (r: CwTimelineRow) => {
            ListItem() {
              Row({ space: 12 }) {
                Column() {
                  Text(r.dateKey.length >= 10 ? r.dateKey.substring(8) : r.dateKey)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandAccent)
                  Text(CwDateUtil.displayDate(r.dateKey))
                    .fontSize(10)
                    .fontColor(Theme.colors().textTertiary)
                    .maxLines(1)
                }
                .width(72)
                Column({ space: 4 }) {
                  Text(CwTimelineLabels.kindLabel(r.kind))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(r.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(2)
                    .width('100%')
                  if (r.subtitle.length > 0) {
                    Text(r.subtitle)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.colors().textSecondary)
                      .maxLines(1)
                      .width('100%')
                  }
                }
                .layoutWeight(1)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 10, bottom: 10 })
              .onClick((): void => { this.openRow(r) })
            }
          }, (r: CwTimelineRow) => `${r.kind}_${r.id}`)
        }
        .layoutWeight(1)
        .padding({ bottom: this.bottomInset })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  num(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
