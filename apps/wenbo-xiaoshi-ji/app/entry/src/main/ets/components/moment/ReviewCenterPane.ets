import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { DailyWrap } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct ReviewCenterPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @State wrap: DailyWrap = new DailyWrap()
  @State monthLine: string = ''
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.wrap = await MomentStore.loadDailyWrap(DateHelper.todayKey())
    const now = new Date()
    const count = await MomentStore.monthNoteCount(now.getFullYear(), now.getMonth())
    this.monthLine = `本月已记下 ${count} 件小事`
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  private async shareMonth(): Promise<void> {
    const now = new Date()
    const card = await MomentStore.buildMonthShare(now.getFullYear(), now.getMonth())
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, card.body)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('本月卡片已复制')
    } catch {
      this.showToast('复制失败')
    }
  }

  build() {
    Stack() {
      DetailShell({ title: '回顾中心', onClose: (): void => MomentNav.close() }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: Theme.space.s2 }) {
              Text('今日回顾')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.wrap.filled() ? this.wrap.preview() : '还没写今日收束')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              AppButton({ label: '写今日收束', variant: 'secondary', onTap: (): void => MomentNav.openDailyWrap() })
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(16)

            Column({ space: Theme.space.s2 }) {
              Text('本周回顾')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              AppButton({ label: '本周复盘三问', variant: 'secondary', onTap: (): void => MomentNav.openWeeklyReview() })
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(16)

            Column({ space: Theme.space.s2 }) {
              Text('本月回顾')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.monthLine)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              AppButton({ label: '复制本月卡片', variant: 'secondary', onTap: (): void => { void this.shareMonth() } })
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(16)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
  }
}
