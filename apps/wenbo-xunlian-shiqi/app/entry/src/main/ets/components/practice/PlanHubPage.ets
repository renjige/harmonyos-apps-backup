import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { SolidButton } from '../design-system/SolidButton'
import { HubShell } from './HubShell'
import { PlanDetailPane } from '../detail/PlanDetailPane'
import { PlanFormOverlay } from './PlanFormOverlay'
import { PlanDraft, TrainPlan } from '../../models/TrainingModels'
import { PracticeHubStore } from '../../services/PracticeHubStore'
import { PlanService } from '../../services/PlanService'
import { VitalityService } from '../../services/VitalityService'
import { DataRefresh } from '../../services/DataRefresh'

@Component
export struct PlanHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @Prop embedded: boolean = false
  @State plans: TrainPlan[] = []
  @State detailId: string = ''
  @State showForm: boolean = false
  @State draft: PlanDraft = new PlanDraft()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onDataEpoch(): void {
    this.reload()
  }

  private reload(): void {
    this.plans = PracticeHubStore.listPlans()
  }

  private async addTemplate(key: string): Promise<void> {
    await PracticeHubStore.savePlan(PlanService.fromTemplate(key))
    await VitalityService.award(8)
    DataRefresh.bump()
    this.reload()
  }

  private async submitCustom(): Promise<void> {
    if (this.draft.title.trim().length === 0) {
      return
    }
    await PracticeHubStore.savePlan(PlanService.fromCustom(this.draft))
    this.showForm = false
    this.draft = new PlanDraft()
    DataRefresh.bump()
    this.reload()
  }

  build() {
    if (this.detailId.length > 0) {
      PlanDetailPane({
        planId: this.detailId,
        onClose: (): void => {
          this.detailId = ''
          this.reload()
        },
        onChanged: (): void => { this.reload() }
      })
    } else if (this.showForm) {
      PlanFormOverlay({
        draft: this.draft,
        onClose: (): void => { this.showForm = false },
        onSubmit: (): void => { void this.submitCustom() },
        onDraftChange: (d: PlanDraft): void => { this.draft = d }
      })
    } else {
      HubShell({
        title: '计划库',
        showBack: this.embedded ? false : true,
        padTab: this.embedded,
        onClose: (): void => { this.onClose() },
        body: (): void => { this.Body() }
      })
    }
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      Text('计划库 · 运动工坊模块之一')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('除计划外，还有动作图鉴、挑战馆、任务清单、训练笔记、阶段目标与成长报告，请切换底部 Tab 或回首页「训练生活能力」矩阵体验。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(20)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.LinkChip('发现·图鉴', (): void => { AppStorage.setOrCreate('mainTabIndex', 2) })
        this.LinkChip('成长报告', (): void => { AppStorage.setOrCreate('mainTabIndex', 3) })
        this.LinkChip('任务清单', (): void => { AppStorage.setOrCreate('practiceHubKind', 'check') })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.cardBg(this.themeEpoch))
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })

    Text('从模板复制到「我的计划」后，在详情里勾选任务。数据只存在本机。')
      .fontSize(Theme.type.footnote)
      .fontColor(Theme.colors().textSecondary)
      .width('100%')

    this.TplCard('活力7日计划', '基础 / 柔韧 / 恢复轮换', 'vitality7')
    this.TplCard('新手入门计划', '从热身和拉伸建立习惯', 'newbie')
    this.TplCard('周末运动计划', '周六日有氧 + 力量 + 放松', 'weekend')
    this.TplCard('自律挑战计划', '按里程碑推进，勾选即可', 'discipline')
    this.TplCard('我的晨练组合', '热身 → 拉伸 → 核心方案库', 'morning')

    Column() {
      SolidButton({
        label: '自定义计划',
        tone: 'secondary',
        onTap: (): void => { this.showForm = true }
      })
    }
    .width('100%')
    .onClick((): void => { this.showForm = true })

    Text('我的计划')
      .fontSize(Theme.type.subhead)
      .fontWeight(FontWeight.Medium)
      .fontColor(Theme.colors().textPrimary)
      .width('100%')

    if (this.plans.length === 0) {
      AppEmpty({
        title: '还没有计划',
        description: '点上方模板即可复制一份到本机，再按任务勾选'
      })
    } else {
      ForEach(this.plans, (p: TrainPlan) => {
        Row() {
          Column({ space: 4 }) {
            Text(p.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(`${PlanService.doneCount(p)}/${PlanService.totalCount(p)} 已完成 · ${p.status === 'done' ? '已完成' : '进行中'}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick((): void => { this.detailId = p.id })
      }, (p: TrainPlan) => p.id)
    }
  }

  @Builder
  LinkChip(label: string, action: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(Theme.colors().brandPrimary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { action() })
  }

  @Builder
  TplCard(title: string, sub: string, key: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text('加入')
        .fontSize(Theme.type.caption)
        .fontColor('#FFFFFF')
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(Theme.primaryButtonFill())
        .borderRadius(Theme.radius.pill)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { void this.addTemplate(key) })
  }
}
