import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { CwDateUtil, CwHabit, CwHabitEntry } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'
import { ChenwuMedia } from '../../services/ChenwuMedia'
import { CwConfirmDialog } from '../chenwu/CwConfirmDialog'

@Component
export struct HabitDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop habitId: string = ''
  onChanged: () => void = () => {}
  @State habit: CwHabit = new CwHabit()
  @State entries: CwHabitEntry[] = []
  @State confirmDel: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await ChenwuStore.findHabit(this.habitId)
    if (found !== undefined) {
      this.habit = found
    }
    this.entries = await ChenwuStore.entriesForHabit(this.habitId)
  }

  private async remove(): Promise<void> {
    await ChenwuStore.deleteHabit(this.habitId)
    this.confirmDel = false
    this.onChanged()
    ChenwuDetailNav.closeHabit()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ChenwuMedia.coverGoalHealth())
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({ angle: 180, colors: [['rgba(61,90,108,0)', 0], ['rgba(61,90,108,0.82)', 1]] })
            Text(this.habit.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F7F5F0')
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.md)

          Text(`连续 ${this.habit.streakDays} 天 · 最近 ${this.habit.lastDateKey.length > 0 ? CwDateUtil.displayDate(this.habit.lastDateKey) : '未打卡'}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          AppCard({ title: '习惯说明' }) {
            Text('坚持记录小习惯，在晨雾中看见累积的成长。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          Text('打卡记录')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.entries.length === 0) {
            Text('还没有打卡记录')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.entries.slice(0, 10), (e: CwHabitEntry) => {
              Column({ space: 4 }) {
                Text(CwDateUtil.displayDate(e.dateKey))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
                if (e.note.length > 0) {
                  Text(e.note)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                }
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
            }, (e: CwHabitEntry) => e.id)
          }

          AppButton({ label: '今日打卡', onTap: (): void => { ChenwuDetailNav.openHabitRecord(this.habit.id) } })
          AppButton({ label: '删除习惯', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)

      if (this.confirmDel) {
        CwConfirmDialog({
          title: '删除这个习惯？',
          message: '删除后打卡记录一并清除。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
