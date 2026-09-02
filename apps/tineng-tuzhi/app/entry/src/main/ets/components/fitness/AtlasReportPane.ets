import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextInputField } from '../design-system/AppTextInputField'
import { DetailShell } from '../detail/DetailShell'
import { MixBar } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'
import { AtlasService } from '../../services/AtlasService'
import { PlanStore } from '../../services/PlanStore'
import { MixBarChart } from './MixBarChart'
import { WeekCompareCard } from './WeekCompareCard'

@Component
export struct AtlasReportPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpenPlan: () => void = () => {}
  onRecord: () => void = () => {}
  @State titleText: string = '本周体能图志'
  @State rangeLabel: string = ''
  @State summaryText: string = ''
  @State adviceText: string = ''
  @State mottoInput: string = ''
  @State weekKey: string = ''
  @State peakDay: string = ''
  @State peakMinutes: number = 0
  @State mix: MixBar[] = []
  @State thisMinutes: number = 0
  @State lastMinutes: number = 0
  @State thisDays: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const report = await AtlasService.buildCurrentWeek()
    this.titleText = report.title
    this.rangeLabel = report.rangeLabel
    this.summaryText = report.summary
    this.adviceText = report.advice
    this.mottoInput = report.motto
    this.weekKey = report.weekKey
    this.peakDay = report.peakDay
    this.peakMinutes = report.peakMinutes
    this.mix = report.mix
    this.thisMinutes = report.compare.thisMinutes
    this.lastMinutes = report.compare.lastMinutes
    this.thisDays = report.compare.thisDays
  }

  private async saveMotto(): Promise<void> {
    const plan = await PlanStore.loadPlan(this.weekKey)
    plan.motto = this.mottoInput.trim()
    await PlanStore.savePlan(plan)
    this.toastText = '图志寄语已写入本周'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        DetailShell({
          title: '周图志报告',
          onClose: (): void => this.onClose()
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: Theme.space.s2 }) {
              Text(this.titleText)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.rangeLabel)
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s6)
            .backgroundColor('#FF6B35')
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)

            Column({ space: Theme.space.s2 }) {
              Text('摘要')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(this.summaryText)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(22)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            WeekCompareCard({
              thisMinutes: this.thisMinutes,
              lastMinutes: this.lastMinutes,
              thisDays: this.thisDays
            })
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)

            MixBarChart({ items: this.mix })
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)

            if (this.peakDay.length >= 8) {
              Text(`高峰日 ${DateHelper.displayDate(this.peakDay)} · ${this.peakMinutes} 分钟`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }

            Column({ space: Theme.space.s2 }) {
              Text('智慧建议')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(this.adviceText)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(22)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s2 }) {
              Text('图志寄语')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.mottoInput,
                placeholder: '给这周写一句对照语',
                onChange: (v: string): void => { this.mottoInput = v }
              })
              AppButton({
                label: '保存寄语',
                variant: 'secondary',
                onTap: (): void => { void this.saveMotto() }
              })
            }
            .width('100%')

            AppButton({
              label: '去排本周训练',
              variant: 'primary',
              onTap: (): void => this.onOpenPlan()
            })
            AppButton({
              label: '记录一笔运动',
              variant: 'secondary',
              onTap: (): void => this.onRecord()
            })
            Row().height(Theme.space.s10)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ top: 48 })
          .backgroundColor('#1A2332')
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
    .height('100%')
  }
}
