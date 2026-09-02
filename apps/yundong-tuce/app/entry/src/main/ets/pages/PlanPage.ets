import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { PlanItem, ProgramItem } from '../models/TuceModels'
import { MoveLibrary } from '../services/MoveLibrary'
import { TuceStore } from '../services/TuceStore'
import { TuceNav } from '../services/TuceNav'
import { ProgramProgressCard } from '../components/tuce/ProgramProgressCard'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onToken') reloadToken: number = 0
  @State plans: PlanItem[] = []
  @State programs: ProgramItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.plans = await TuceStore.plans()
    this.programs = await TuceStore.programs()
  }

  private async startProgram(days: number): Promise<void> {
    let planId = ''
    if (this.plans.length > 0) {
      planId = this.plans[0].id
    }
    const p = new ProgramItem()
    p.id = TuceStore.newId('prog')
    p.name = `${days} 日进阶计划`
    p.days = days
    p.planId = planId
    p.startDate = TuceStore.today()
    p.doneDates = ''
    await TuceStore.saveProgram(p)
    await this.reload()
    TuceNav.bump()
  }

  build() {
    Column() {
      AppHeader({ title: '训练计划', subtitle: '编排方案，按周期推进并追踪完成度' })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.cat_strength'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text('周期训练')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('选择 7 / 14 / 21 / 30 日计划，每日打卡推进')
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.75)', 1]]
            })
          }
          .width('100%')
          .height(140)

          AppButton({
            label: '编排新方案',
            variant: 'primary',
            onTap: (): void => { TuceNav.open('combo', '') }
          })

          Text('快速开启周期')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            ForEach(['7日', '14日', '21日', '30日'], (label: string, idx: number) => {
              Text(label)
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .onClick((): void => {
                  const days: number[] = [7, 14, 21, 30]
                  void this.startProgram(days[idx])
                })
            }, (label: string) => label)
          }
          .width('100%')

          Text('进行中的计划')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.programs.length === 0) {
            Text('还没有进行中的周期计划，选上方天数即可开启')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          ForEach(this.programs, (p: ProgramItem) => {
            ProgramProgressCard({
              program: p,
              onTap: (): void => { TuceNav.open('program', p.id) }
            })
          }, (p: ProgramItem) => `${p.id}_${p.doneDates}_${this.reloadToken}`)

          Text('我的训练方案')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.plans.length === 0) {
            AppEmpty({
              title: '还没有训练方案',
              description: '从图鉴收藏动作，再编排成一套属于你的组合',
              actionLabel: '去编排',
              onAction: (): void => { TuceNav.open('combo', '') }
            })
          }
          ForEach(this.plans, (pl: PlanItem) => {
            Row({ space: Theme.space.s3 }) {
              Image($r('app.media.cat_core'))
                .width(64)
                .height(64)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 4 }) {
                Text(pl.name)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(MoveLibrary.namesOf(pl.moveIds))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .width('100%')
                Text(`${pl.minutes} 分钟 · 休息 ${pl.restSec} 秒`)
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { TuceNav.open('plan', pl.id) })
          }, (pl: PlanItem) => pl.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
