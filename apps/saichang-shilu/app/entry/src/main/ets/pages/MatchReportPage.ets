import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecordCard } from '../components/sport/RecordCard'
import { SportRecord } from '../models/SportRecord'
import { RecordStore } from '../services/RecordStore'
import { MatchReportService } from '../services/MatchReportService'
import { ExportService } from '../services/ExportService'
import { common } from '@kit.AbilityKit'

@Component
export struct MatchReportPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop seedId: string = ''
  @State reportText: string = ''
  @State matches: SportRecord[] = []
  @State activeId: string = ''
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.init()
  }

  private async init(): Promise<void> {
    this.matches = await RecordStore.loadAll()
    if (this.seedId.length > 0) {
      this.activeId = this.seedId
      await this.buildReport(this.seedId)
    }
  }

  private async buildReport(id: string): Promise<void> {
    this.activeId = id
    this.reportText = await MatchReportService.build(id)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async exportReport(): Promise<void> {
    if (this.reportText.length === 0) {
      this.showToast('请先选择一场比赛')
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    const path = await ExportService.exportReportFile(ctx, this.reportText)
    this.showToast(`战报已导出：${path}`)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('比赛战报')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('自动汇总清单、预测、MVP、复盘与关联瞬间，生成可分享战报。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            if (this.matches.length === 0) {
              AppEmpty({
                title: '还没有赛事',
                description: '先记录一场比赛，再生成完整战报',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else if (this.reportText.length === 0) {
              Text('选择一场比赛生成战报')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              ForEach(this.matches, (m: SportRecord) => {
                RecordCard({
                  record: m,
                  onTap: (): void => { void this.buildReport(m.id) }
                })
              }, (m: SportRecord) => m.id)
            } else {
              Column({ space: Theme.space.s3 }) {
                Text(this.reportText)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(22)
                  .width('100%')
                AppButton({
                  label: '导出战报文本',
                  variant: 'primary',
                  onTap: (): void => { void this.exportReport() }
                })
                AppButton({
                  label: '换一场比赛',
                  variant: 'secondary',
                  onTap: (): void => { this.reportText = ''; this.activeId = '' }
                })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
