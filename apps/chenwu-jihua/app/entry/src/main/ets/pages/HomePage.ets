import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CwDateUtil, CwLookbackItem, CwPhase, CwStats } from '../models/ChenwuModels'
import { ChenwuStore } from '../services/ChenwuStore'
import { ChenwuDetailNav } from '../services/ChenwuDetailNav'
import { StatTileCard } from '../components/chenwu/StatTileCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State stats: CwStats = new CwStats()
  @State todayPct: number = 0
  @State activePhases: CwPhase[] = []
  @State look: CwLookbackItem = new CwLookbackItem()
  @State statsEpoch: number = 0

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
    this.stats = await ChenwuStore.computeStats()
    this.todayPct = this.stats.todayPlanPct
    this.activePhases = await ChenwuStore.activePhasesForToday()
    this.look = await ChenwuStore.buildLookback()
    this.statsEpoch = this.statsEpoch + 1
  }

  private openLook(): void {
    if (this.look.sourceKind === 'goal' && this.look.sourceId.length > 0) {
      ChenwuDetailNav.openGoal(this.look.sourceId)
      return
    }
    if (this.look.sourceKind === 'habit' && this.look.sourceId.length > 0) {
      ChenwuDetailNav.openHabit(this.look.sourceId)
      return
    }
    if (this.look.sourceKind === 'journal' && this.look.sourceId.length > 0) {
      ChenwuDetailNav.openJournal(this.look.sourceId)
      return
    }
    AppStorage.setOrCreate('cwActiveTab', 3)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_mist_dawn'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(140)
            .linearGradient({ angle: 180, colors: [['rgba(61,90,108,0)', 0], ['rgba(61,90,108,0.88)', 1]] })
          Row({ space: Theme.space.s4 }) {
            Column({ space: 6 }) {
              Text('晨雾空间')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F7F5F0')
              Text('今日计划完成度')
                .fontSize(Theme.type.caption)
                .fontColor('#F7F5F0')
            }
            .layoutWeight(1)
            Stack() {
              Progress({ value: this.todayPct, total: 100, type: ProgressType.Ring })
                .width(72)
                .height(72)
                .color(Theme.colors().brandAccent)
                .backgroundColor('rgba(255,255,255,0.25)')
                .style({ strokeWidth: 6 })
                .key(`ring_${this.todayPct}_${this.dataRev}`)
              Text(`${this.todayPct}%`)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F7F5F0')
            }
            .key(`hero_ring_${this.todayPct}_${this.statsEpoch}`)
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
          .width('100%')
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.lg)

        Row({ space: Theme.space.s2 }) {
          StatTileCard({ label: '计划', value: this.stats.planCount })
          StatTileCard({ label: '今日完成', value: this.stats.todayTaskDone })
          StatTileCard({ label: '习惯', value: this.stats.habitCount })
          StatTileCard({ label: '连续', value: this.stats.streakMax })
        }
        .width('100%')
        .key(`stats_${this.statsEpoch}_${this.dataRev}_${this.todayPct}_${this.stats.todayTaskDone}`)

        Text('快捷操作')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.quickBtn('创建计划', (): void => { ChenwuDetailNav.openPlanEditor('') })
          this.quickBtn('添加目标', (): void => { ChenwuDetailNav.openGoalEditor('') })
        }
        .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.quickBtn('记录成长', (): void => { ChenwuDetailNav.openJournalEditor('') })
          this.quickBtn('查看复盘', (): void => { AppStorage.setOrCreate('cwActiveTab', 3) })
        }
        .width('100%')

        Text('今日阶段')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.activePhases.length === 0) {
          AppEmpty({
            title: '暂无进行中的阶段',
            description: '创建计划并激活阶段后，这里会显示今日任务',
            actionLabel: '去计划页',
            onAction: (): void => { AppStorage.setOrCreate('cwActiveTab', 1) }
          })
        } else {
          ForEach(this.activePhases, (ph: CwPhase) => {
            Row({ space: 12 }) {
              AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
              Column({ space: 4 }) {
                Text(ph.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                if (ph.targetNote.length > 0) {
                  Text(ph.targetNote)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
              }
              .layoutWeight(1)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => {
              ChenwuStore.findPlan(ph.planId).then((p) => {
                if (p !== undefined) {
                  ChenwuDetailNav.openPlan(p.id)
                }
              })
            })
          }, (ph: CwPhase) => ph.id)
        }

        Column({ space: 6 }) {
          Image($r('app.media.banner_plan_path'))
            .width('100%')
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.sm)
          Text('智慧回望')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
          Text(this.look.title)
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.look.body)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          if (this.look.dateKey.length > 0) {
            Text(CwDateUtil.displayDate(this.look.dateKey))
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { this.openLook() })

        Column().height(this.bottomInset + Theme.space.s4)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => { void this.reload() })
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  quickBtn(label: string, action: () => void) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.footnote)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { action() })
  }
}
