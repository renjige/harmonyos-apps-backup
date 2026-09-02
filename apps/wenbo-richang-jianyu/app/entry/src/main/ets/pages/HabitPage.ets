import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LifePageShell } from '../components/life/LifePageShell'
import { HabitItem, LifeDates } from '../models/LifeHubModels'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'

@Component
export struct HabitPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @State items: HabitItem[] = []
  @State formTitle: string = ''
  @State confirmId: string = ''
  @State toastText: string = ''
  @State stampYear: number = 2026
  @State stampMonth: number = 1
  @State listEpoch: number = 0

  aboutToAppear(): void {
    const n = new Date()
    this.stampYear = n.getFullYear()
    this.stampMonth = n.getMonth() + 1
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await LifeHubStore.loadHabits()
    this.listEpoch += 1
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private cloneHabit(src: HabitItem, checkins: string[]): HabitItem {
    const item = new HabitItem()
    item.id = src.id
    item.title = src.title
    item.checkins = checkins
    return item
  }

  private async addHabit(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.showToast('请填写习惯名称')
      return
    }
    const item = new HabitItem()
    item.id = LifeHubStore.newId('habit')
    item.title = this.formTitle.trim()
    item.checkins = []
    await LifeHubStore.upsertHabit(item)
    this.formTitle = ''
    this.showToast('已创建习惯，点「今日打卡」即可')
    await this.reload()
  }

  private checkToday(id: string): void {
    const today = LifeDates.todayIso()
    const next: HabitItem[] = []
    let nowChecked = false
    let saved: HabitItem | undefined = undefined
    for (const row of this.items) {
      const dates: string[] = []
      for (const d of row.checkins) {
        dates.push(d)
      }
      if (row.id === id) {
        const kept: string[] = []
        let hadToday = false
        for (const d of dates) {
          if (d === today) {
            hadToday = true
          } else {
            kept.push(d)
          }
        }
        if (!hadToday) {
          kept.push(today)
          nowChecked = true
        } else {
          nowChecked = false
        }
        saved = this.cloneHabit(row, kept)
        next.push(saved)
      } else {
        next.push(this.cloneHabit(row, dates))
      }
    }
    this.items = next
    this.listEpoch += 1
    if (saved !== undefined) {
      void LifeHubStore.upsertHabit(saved)
    }
    this.showToast(nowChecked ? '今日已打卡' : '已取消今日打卡')
  }

  private async confirmDelete(): Promise<void> {
    await LifeHubStore.removeHabit(this.confirmId)
    this.confirmId = ''
    await this.reload()
  }

  build() {
    Stack() {
      LifePageShell({
        title: '每日打卡',
        subtitle: '习惯目标 · 连续天数 · 本月完成',
        refreshToken: this.listEpoch,
        onClose: (): void => { LifeHubNav.backOrClose() },
        body: () => { this.Body() }
      })
      if (this.confirmId.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这个习惯？打卡记录将一并清除。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          AppButton({
            label: '确认删除',
            variant: 'danger',
            onTap: (): void => { void this.confirmDelete() }
          })
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.confirmId = '' }
          })
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .zIndex(40)
      }
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
        .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      TextInput({ text: this.formTitle, placeholder: '新习惯，例如：早起、散步、阅读' })
        .width('100%')
        .height(44)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => { this.formTitle = v })
      AppButton({
        label: '创建习惯',
        onTap: (): void => { void this.addHabit() }
      })
      if (this.items.length === 0) {
        AppEmpty({ title: '还没有习惯目标', description: '创建一个习惯，每天点一次完成打卡' })
      } else {
        ForEach(this.items, (row: HabitItem) => {
          Column({ space: Theme.space.s3 }) {
            Text(row.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`连续 ${row.streak()} 天 · ${this.stampYear}年${this.stampMonth}月已打 ${row.monthCount(this.stampYear, this.stampMonth)} 次`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Column() {
              Text(row.checkedOn(LifeDates.todayIso()) ? '取消今日打卡' : '今日打卡')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(row.checkedOn(LifeDates.todayIso()) ?
                  Theme.colors().brandPrimary : Theme.colors().brandOnPrimary)
            }
            .width('100%')
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(row.checkedOn(LifeDates.todayIso()) ?
              Theme.colors().brandPrimaryContainer : Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => { this.checkToday(row.id) })
            Text('删除习惯')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().danger)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 4, bottom: 4 })
              .onClick((): void => { this.confirmId = row.id })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }, (row: HabitItem) => `${row.id}_${row.checkins.length}_${row.checkedOn(LifeDates.todayIso()) ? 'y' : 'n'}`)
      }
    }
    .width('100%')
  }
}
