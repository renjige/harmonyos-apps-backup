import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { Journey, JourneyMilestone, SaituRecord } from '../../models/SaituModels'
import { CheckIn, JourneyPlan } from '../../models/SaituGrowthModels'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituTrackStore } from '../../services/SaituTrackStore'
import { SaituCheckInStore } from '../../services/SaituCheckInStore'
import { SaituPlanStore } from '../../services/SaituPlanStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct JourneyDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituJourneyEpoch') @Watch('onJourneyEpochChange') journeyEpoch: number = 0
  @StorageLink('saituTrackEpoch') @Watch('onTrackEpochChange') trackEpoch: number = 0
  @StorageLink('saituPlanEditorOpen') @Watch('onPlanEditorChange') planEditorOpen: boolean = false
  @StorageLink('saituJourneyDetailId') @Watch('onIdChange') journeyId: string = ''
  onChanged: () => void = () => {}
  @State journey: Journey | undefined = undefined
  @State records: SaituRecord[] = []
  @State milestones: JourneyMilestone[] = []
  @State plans: JourneyPlan[] = []
  @State checkins: CheckIn[] = []
  @State progressLabel: string = ''
  private planEditorWasOpen: boolean = false

  aboutToAppear(): void {
    this.planEditorWasOpen = this.planEditorOpen
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  onJourneyEpochChange(): void {
    void this.reload()
  }

  onTrackEpochChange(): void {
    void this.reload()
  }

  onPlanEditorChange(): void {
    if (this.planEditorWasOpen && !this.planEditorOpen) {
      void this.reload()
    }
    this.planEditorWasOpen = this.planEditorOpen
  }

  private async reload(): Promise<void> {
    if (this.journeyId.length === 0) {
      return
    }
    const j = await SaituLocalStore.findJourney(this.journeyId)
    this.journey = j
    const allRecords = await SaituLocalStore.loadRecords()
    const recs: SaituRecord[] = []
    for (const r of allRecords) {
      if (r.journeyId === this.journeyId) {
        recs.push(r)
      }
    }
    this.records = recs
    const allMs = await SaituTrackStore.loadMilestones()
    const ms: JourneyMilestone[] = []
    for (const m of allMs) {
      if (m.journeyId === this.journeyId) {
        ms.push(m)
      }
    }
    this.milestones = ms
    const allPlans = await SaituPlanStore.loadPlans()
    const pls: JourneyPlan[] = []
    for (const p of allPlans) {
      if (p.journeyId === this.journeyId) {
        pls.push(p)
      }
    }
    this.plans = pls
    const allChk = await SaituCheckInStore.loadCheckIns()
    const chks: CheckIn[] = []
    for (const c of allChk) {
      if (c.journeyId === this.journeyId) {
        chks.push(c)
      }
    }
    this.checkins = chks
    const prog = await SaituLocalStore.journeyProgress()
    this.progressLabel = ''
    for (const p of prog) {
      if (p.journeyId === this.journeyId) {
        this.progressLabel = p.progressLabel
        break
      }
    }
  }

  private openCheckIn(): void {
    SaituDetailNav.openCheckInEditor(this.journeyId)
  }

  private openNewPlan(): void {
    SaituDetailNav.openNewPlan(this.journeyId)
  }

  @Builder
  bodyContent() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        if (this.journey !== undefined) {
          Column({ space: Theme.space.s2 }) {
            Row({ space: Theme.space.s2 }) {
              Column()
                .width(6)
                .height(48)
                .backgroundColor(this.journey.color)
                .borderRadius(3)
              Column({ space: Theme.space.s2 }) {
                Text(this.journey.name)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textOnInverse)
                  .width('100%')
                if (this.progressLabel.length > 0) {
                  Text(this.progressLabel)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textOnInverse)
                }
                Text(this.journey.description.length > 0 ? this.journey.description :
                  '在此旅途下组织札记、节点与计划')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textOnInverse)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s5)
          .linearGradient({
            angle: 150,
            colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
          })
          .borderRadius(Theme.radius.lg)
        }

        Row({ space: Theme.space.s3 }) {
          Row() {
            AppButton({
              label: '今日打卡',
              variant: 'primary',
              onTap: (): void => { this.openCheckIn() }
            })
          }
          .layoutWeight(1)
          .onClick((): void => { this.openCheckIn() })
          Row() {
            AppButton({
              label: '新建计划',
              variant: 'secondary',
              onTap: (): void => { this.openNewPlan() }
            })
          }
          .layoutWeight(1)
          .onClick((): void => { this.openNewPlan() })
        }
        .width('100%')

        Text(`札记 ${this.records.length} · 节点 ${this.milestones.length} · 计划 ${this.plans.length} · 打卡 ${this.checkins.length}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        Text('最近札记')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.records.length === 0) {
          AppEmpty({ title: '暂无札记', description: '写札记时选择本旅途即可在此汇总' })
        } else {
          ForEach(this.records.slice(0, 5), (r: SaituRecord) => {
            Column({ space: 4 }) {
              Text(r.summaryLine(48))
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
              Text(r.dateKey())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => {
              SaituDetailNav.closeJourneyDetail()
              SaituDetailNav.openRecord(r.id)
            })
          }, (r: SaituRecord) => r.id)
        }

        Text('赛途节点')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.milestones.length === 0) {
          Text('添加阶段目标，达成后进度前进')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
        } else {
          ForEach(this.milestones, (m: JourneyMilestone) => {
            Row({ space: Theme.space.s3 }) {
              Column()
                .width(10)
                .height(10)
                .borderRadius(5)
                .backgroundColor(m.done ? Theme.colors().success : Theme.colors().brandPrimary)
              Text(m.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => {
              SaituDetailNav.closeJourneyDetail()
              SaituDetailNav.openMilestone(m.id)
            })
          }, (m: JourneyMilestone) => m.rowKey())
        }

        Text('进行中计划')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.plans.length === 0) {
          Text('为旅途设定周期目标')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
        } else {
          ForEach(this.plans, (p: JourneyPlan) => {
            Column({ space: 4 }) {
              Text(p.title.length > 0 ? p.title : '未命名计划')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
              Text(p.progressLabel())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => {
              SaituDetailNav.closeJourneyDetail()
              SaituDetailNav.openPlan(p.id)
            })
          }, (p: JourneyPlan) => p.rowKey())
        }

        Blank().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .scrollBar(BarState.Off)
  }

  build() {
    DetailShell({
      title: '旅途详情',
      onClose: (): void => SaituDetailNav.closeJourneyDetail(),
      body: (): void => this.bodyContent()
    })
  }
}
