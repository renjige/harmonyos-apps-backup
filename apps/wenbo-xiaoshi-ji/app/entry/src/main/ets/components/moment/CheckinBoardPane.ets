import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { CheckinCell } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct CheckinBoardPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @State cells: CheckinCell[] = []
  @State streak: number = 0
  @State todayDone: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.cells = await MomentStore.loadCheckinCells(30)
    this.streak = await MomentStore.streakDays()
    this.todayDone = await MomentStore.todayCheckedIn()
  }

  build() {
    DetailShell({
      title: '打卡日历',
      onClose: (): void => MomentNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.todayDone ?
            `今天已记下小事，连续 ${this.streak} 天` :
            `今天还没打卡，当前连续 ${this.streak} 天`)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(22)
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(16)

          Text('近 30 日记录轨迹：有色圆点表示当天写过小事')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.cells, (c: CheckinCell) => {
              Column({ space: 4 }) {
                Column()
                  .width(18)
                  .height(18)
                  .borderRadius(9)
                  .backgroundColor(c.done ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                Text(`${c.day}`)
                  .fontSize(10)
                  .fontColor(c.dateKey === DateHelper.todayKey() ?
                    Theme.colors().brandPrimary : Theme.colors().textTertiary)
              }
              .width('14.2%')
              .padding({ top: 6, bottom: 6 })
              .alignItems(HorizontalAlign.Center)
            }, (c: CheckinCell) => c.dateKey)
          }
          .width('100%')

          AppButton({
            label: this.todayDone ? '再记一件小事' : '记下今天的小事',
            onTap: (): void => MomentNav.openEditor('')
          })
          AppButton({
            label: '去记今日心情',
            variant: 'secondary',
            onTap: (): void => MomentNav.openDailyWrap()
          })
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}
