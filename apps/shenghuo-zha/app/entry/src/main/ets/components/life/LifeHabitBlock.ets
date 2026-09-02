import { Theme } from '../design-system/Theme'
import { LifeHabitItem } from '../../models/LifeModels'
import { LifeDateHelper, LifeLocalStore } from '../../services/LifeLocalStore'

@Component
export struct LifeHabitBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onChanged: () => void = () => {}
  @State items: LifeHabitItem[] = []
  @State newHabitTitle: string = ''
  @State toast: string = ''
  @State todayKey: string = ''

  aboutToAppear(): void {
    this.todayKey = LifeDateHelper.todayKey()
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 1800)
  }

  private async reload(): Promise<void> {
    this.todayKey = LifeDateHelper.todayKey()
    this.items = await LifeLocalStore.loadHabits()
  }

  private rowKey(h: LifeHabitItem): string {
    return `${h.id}_${h.lastDate}_${h.streak}_${h.totalDays}`
  }

  private applyLocalCheckin(id: string): void {
    const today = this.todayKey
    const next: LifeHabitItem[] = []
    for (const h of this.items) {
      if (h.id !== id) {
        next.push(h)
        continue
      }
      const copy = LifeHabitItem.create(h.id, h.title)
      copy.createdAt = h.createdAt
      copy.totalDays = h.totalDays
      copy.streak = h.streak
      copy.lastDate = h.lastDate
      if (copy.lastDate !== today) {
        const yest = new Date()
        yest.setDate(yest.getDate() - 1)
        const yestKey = LifeDateHelper.keyFromDate(yest)
        copy.streak = copy.lastDate === yestKey ? copy.streak + 1 : 1
        copy.lastDate = today
        copy.totalDays = copy.totalDays + 1
      }
      next.push(copy)
    }
    this.items = next
  }

  private async checkin(id: string): Promise<void> {
    let already = false
    for (const h of this.items) {
      if (h.id === id && h.lastDate === this.todayKey) {
        already = true
        break
      }
    }
    if (already) {
      this.showToast('今天已经打过卡了')
      return
    }
    this.applyLocalCheckin(id)
    this.showToast('打卡成功')
    await LifeLocalStore.checkinHabit(id)
    await this.reload()
    this.onChanged()
  }

  private async addPreset(title: string): Promise<void> {
    const h = LifeHabitItem.create(LifeDateHelper.newId(), title)
    await LifeLocalStore.saveHabit(h)
    await this.reload()
    this.showToast(`已添加「${title}」`)
    this.onChanged()
  }

  private async addCustom(): Promise<void> {
    if (this.newHabitTitle.trim().length === 0) {
      this.showToast('请输入习惯名称')
      return
    }
    await this.addPreset(this.newHabitTitle.trim())
    this.newHabitTitle = ''
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s3 }) {
        Text('每日打卡')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandDeep)

        if (this.items.length === 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['阅读打卡', '运动打卡', '早睡打卡', '早起打卡', '整理打卡'], (name: string) => {
              Text(`+ ${name}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.addPreset(name) })
            }, (name: string) => name)
          }
          .width('100%')
        } else {
          ForEach(this.items, (h: LifeHabitItem) => {
            Row({ space: Theme.space.s3 }) {
              Text(h.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Text(`连续 ${h.streak} 天 · 累计 ${h.totalDays}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
              Text(h.lastDate === this.todayKey ? '已打卡' : '打卡')
                .fontSize(Theme.type.caption)
                .fontColor(h.lastDate === this.todayKey ?
                  Theme.colors().success : Theme.colors().brandOnPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(h.lastDate === this.todayKey ?
                  Theme.colors().successContainer : Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { void this.checkin(h.id) })
          }, (h: LifeHabitItem) => this.rowKey(h))
          Row({ space: Theme.space.s2 }) {
            TextInput({ text: this.newHabitTitle, placeholder: '新习惯名称' })
              .layoutWeight(1)
              .height(44)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandDeep)
              .backgroundColor('#FFFFFF')
              .borderRadius(Theme.radius.sm)
              .border({ width: 1, color: Theme.colors().strokeStrong })
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.newHabitTitle = v })
            Text('添加')
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .constraintSize({ minHeight: 44 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { void this.addCustom() })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
      }
      .width('100%')

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 0 })
      }
    }
    .width('100%')
  }
}
