import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateDiaryRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { AuthService } from '../services/AuthService'

class HabitRow {
  habit: JournalItem = new JournalItem()
  streak: number = 0
  doneToday: boolean = false
}

/** 习惯打卡：创建项目、当日勾选、连续天数 */
@Component
export struct HabitCheckinPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State rows: HabitRow[] = []
  @State newTitle: string = ''
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.rows = []
      return
    }
    const habits = await JournalBizService.loadByKind(this.currentUsername, 'habit')
    const checks = await JournalBizService.loadByKind(this.currentUsername, 'checkin')
    const today = this.todayIso()
    const out: HabitRow[] = []
    for (let i = 0; i < habits.length; i++) {
      const row = new HabitRow()
      row.habit = habits[i]
      row.streak = this.calcStreak(habits[i].id, checks)
      row.doneToday = this.hasCheck(habits[i].id, today, checks)
      out.push(row)
    }
    this.rows = out
  }

  private hasCheck(habitId: string, day: string, checks: JournalItem[]): boolean {
    for (let i = 0; i < checks.length; i++) {
      if (checks[i].sourceRefId === habitId && checks[i].recordDate === day) {
        return true
      }
    }
    return false
  }

  private calcStreak(habitId: string, checks: JournalItem[]): number {
    let streak = 0
    const cursor = new Date()
    for (let step = 0; step < 366; step++) {
      const y = cursor.getFullYear()
      const m = cursor.getMonth() + 1
      const d = cursor.getDate()
      const mm = m < 10 ? `0${m}` : `${m}`
      const dd = d < 10 ? `0${d}` : `${d}`
      const iso = `${y}-${mm}-${dd}`
      if (this.hasCheck(habitId, iso, checks)) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        if (step === 0) {
          cursor.setDate(cursor.getDate() - 1)
          continue
        }
        break
      }
    }
    return streak
  }

  private async addHabit(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.newTitle.trim().length === 0) {
      this.showToast('请填写习惯名称')
      return
    }
    const req = new CreateDiaryRequest()
    req.title = this.newTitle.trim()
    req.body = '每日打卡'
    req.kind = 'habit'
    req.userId = this.currentUsername
    req.tags = ['每日打卡']
    const created = await JournalBizService.createDiary(req)
    if (created !== undefined) {
      this.newTitle = ''
      this.showToast('习惯已创建')
      await this.reload()
    } else {
      this.showToast('创建失败')
    }
  }

  private async checkin(habit: JournalItem): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    for (let i = 0; i < this.rows.length; i++) {
      if (this.rows[i].habit.id === habit.id && this.rows[i].doneToday) {
        this.showToast('今日已完成打卡')
        return
      }
    }
    const req = new CreateDiaryRequest()
    req.title = `打卡 · ${habit.title}`
    req.body = '完成'
    req.kind = 'checkin'
    req.sourceRefId = habit.id
    req.recordDate = this.todayIso()
    req.userId = this.currentUsername
    req.tags = ['每日打卡']
    const created = await JournalBizService.createDiary(req)
    if (created !== undefined) {
      this.showToast('今日已打卡')
      this.applyCheckinLocal(habit.id)
      await this.reload()
    } else {
      this.showToast('打卡失败')
    }
  }

  private applyCheckinLocal(habitId: string): void {
    const next: HabitRow[] = []
    for (let i = 0; i < this.rows.length; i++) {
      const row = new HabitRow()
      row.habit = this.rows[i].habit
      row.streak = this.rows[i].streak
      row.doneToday = this.rows[i].doneToday
      if (row.habit.id === habitId) {
        row.doneToday = true
        row.streak = row.streak + 1
      }
      next.push(row)
    }
    this.rows = next
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('每日打卡')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.newTitle, placeholder: '例如：阅读 20 分钟 / 散步' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.newTitle = v })
            AppButton({
              label: '添加打卡项目',
              onTap: (): void => { void this.addHabit() }
            })
            if (this.rows.length === 0) {
              AppEmpty({
                title: '还没有习惯',
                description: '创建一个小目标，每天打卡看连续天数'
              })
            } else {
              ForEach(this.rows, (row: HabitRow) => {
                AppCard({ title: row.habit.title }) {
                  Column({ space: Theme.space.s3 }) {
                    Text(`连续 ${row.streak} 天`)
                      .fontSize(Theme.type.footnote)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    if (row.doneToday) {
                      Text('今日已完成')
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().success)
                        .fontWeight(FontWeight.Medium)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .backgroundColor(Theme.colors().successContainer)
                        .borderRadius(Theme.radius.pill)
                        .width('100%')
                    } else {
                      AppButton({
                        label: '今日打卡',
                        onTap: (): void => { void this.checkin(row.habit) }
                      })
                    }
                  }
                  .width('100%')
                }
              }, (row: HabitRow) => `${row.habit.id}_${row.doneToday}_${row.streak}`)
            }
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
      .width('100%')
      .height('100%')

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
