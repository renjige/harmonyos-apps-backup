import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { TaskBizService } from '../../services/TaskBizService'
import { CommitmentRules } from '../../services/CommitmentRules'

@Component
export struct WeeklyReviewOverlay {
  onClose: () => void = () => {}
  @State loading: boolean = true
  @State commitTotal: number = 0
  @State commitDone: number = 0
  @State focusMin: number = 0
  @State reasonText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private rate(): number {
    if (this.commitTotal <= 0) {
      return 0
    }
    return Math.round(this.commitDone * 100 / this.commitTotal)
  }

  private async reload(): Promise<void> {
    this.loading = true
    const all = await TaskBizService.loadTasks(this.currentUsername)
    let total = 0
    let done = 0
    let sec = 0
    const reasons: string[] = []
    for (const item of all) {
      if (!CommitmentRules.inLastDays(item.dueDate, 7)) {
        continue
      }
      if (item.lane === 'commitment') {
        total += 1
        if (item.isDone()) {
          done += 1
        }
      }
      sec += item.focusSeconds
      if (item.closeReason.length > 0 && reasons.indexOf(item.closeReason) < 0) {
        reasons.push(item.closeReason)
      }
    }
    this.commitTotal = total
    this.commitDone = done
    this.focusMin = Math.floor(sec / 60)
    this.reasonText = reasons.length > 0 ? reasons.join('、') : '本周暂无关帐原因'
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => this.onClose())
        Text('本周承诺复盘')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '汇总本周承诺…' })
      } else if (this.commitTotal === 0) {
        AppEmpty({
          title: '本周还没有承诺',
          description: '把事项锁定到上午/午后/晚间工位后，这里会统计兑现率'
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(`兑现率 ${this.rate()}%`)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            Text(`近 7 日承诺 ${this.commitDone}/${this.commitTotal} 件已收工`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`累计专注 ${this.focusMin} 分钟`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text(`关帐原因分布：${this.reasonText}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text('系统备忘录不会限制每天件数，也不会要求计时后才能完成。事项笺用限量承诺 + 时段工位统计真实执行。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .lineHeight(22)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
