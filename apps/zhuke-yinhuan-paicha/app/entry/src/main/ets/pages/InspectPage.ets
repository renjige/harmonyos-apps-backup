import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { InspectionRecord, HazardItem } from '../models/HazardModels'
import { HazardBizService } from '../services/HazardBizService'
import { HazardLocalStore } from '../services/HazardLocalStore'

@Component
export struct InspectPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State records: InspectionRecord[] = []
  @State todayCount: number = 0
  onStart: () => void = () => {}
  onSelfCheck: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (HazardLocalStore.isRemoteSyncPaused()) {
      this.records = []
      this.todayCount = HazardLocalStore.todayInspect()
      return
    }
    const list = await HazardBizService.listInspections()
    this.records = list !== undefined ? list : []
    this.todayCount = HazardBizService.countTodayInspections(this.records)
    const localToday = HazardLocalStore.todayInspect()
    if (localToday > this.todayCount) {
      this.todayCount = localToday
    }
  }

  private hasRecords(): boolean {
    return this.records !== undefined && this.records.length > 0
  }

  private timeLabel(raw: string): string {
    return HazardItem.formatLocalTime(raw)
  }

  private rowTitle(row: InspectionRecord): string {
    if (row.title !== undefined && row.title.length > 0) {
      return row.title
    }
    return '现场安全检查'
  }

  private rowSummary(row: InspectionRecord): string {
    if (row.summary !== undefined && row.summary.length > 0) {
      return row.summary
    }
    return `异常 ${row.abnormalCount} · 正常 ${row.okCount}`
  }

  build() {
    Column() {
      Column({ space: 6 }) {
        Text('检查')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
        Text('简单安全检查清单，异常项可生成隐患记录')
          .fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 8 }) {
            Text('今日检查').fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            Text(`${this.todayCount} 次`)
              .fontSize(32).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).width('100%')
            AppButton({ label: '开始一次检查', onTap: (): void => { this.onStart() } })
          }
          .padding(18).width('100%').alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(18)

          AppCard({ title: '现场自检', onTap: (): void => { this.onSelfCheck() } }) {
            Text('用问卷快速判断今日风险关注点，生成模板摘要，不含生成式对话。')
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }

          Text('最近检查').fontSize(16).fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')

          if (!this.hasRecords()) {
            AppEmpty({
              title: '暂无检查',
              description: '按清单逐项确认正常或异常，异常项会进入隐患跟踪。',
              actionLabel: '开始一次检查',
              onAction: (): void => { this.onStart() }
            })
          } else {
            ForEach(this.records, (row: InspectionRecord) => {
              Column({ space: 4 }) {
                Text(this.rowTitle(row))
                  .fontSize(15).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
                Text(this.timeLabel(row.inspectedAt))
                  .fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
                Text(this.rowSummary(row))
                  .fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
              }
              .padding(14).width('100%').alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(16)
            }, (row: InspectionRecord) => row.id)
          }
        }
        .padding({ left: 16, right: 16, bottom: 32 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
