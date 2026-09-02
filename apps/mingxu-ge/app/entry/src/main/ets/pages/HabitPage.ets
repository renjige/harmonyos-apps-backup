import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { XuDateHelper, XuHabitItem } from '../models/XuModels'
import { XuLocalStore } from '../services/XuLocalStore'
import { XuDetailNav } from '../services/XuDetailNav'
import { XuHabitCard } from '../components/xu/XuHabitCard'
import { XuMedia } from '../services/XuMedia'
import { XuBizService } from '../services/XuBizService'

@Component
export struct HabitPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: XuHabitItem[] = []
  @State todayKey: string = ''
  @State monthDone: number = 0
  @State monthTotal: number = 30
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.todayKey = XuDateHelper.todayKey()
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await XuLocalStore.ensureReady()
    this.todayKey = XuDateHelper.todayKey()
    this.items = await XuLocalStore.loadHabits()
    const now = new Date()
    this.monthTotal = XuDateHelper.daysInMonth(now.getFullYear(), now.getMonth() + 1)
    let days = 0
    for (const h of this.items) {
      if (h.checkedToday(this.todayKey)) {
        days++
      }
    }
    this.monthDone = days
  }

  private async toggle(id: string): Promise<void> {
    const next = await XuLocalStore.toggleHabit(id, this.todayKey)
    if (next === undefined) {
      return
    }
    // 先本地改列表，保证点击立刻可见；再落盘结果以 reload 校准
    const patched: XuHabitItem[] = []
    let doneCount = 0
    for (const it of this.items) {
      if (it.id === next.id) {
        patched.push(next)
      } else {
        patched.push(it)
      }
    }
    for (const h of patched) {
      if (h.checkedToday(this.todayKey)) {
        doneCount++
      }
    }
    this.items = patched
    this.monthDone = doneCount
    void XuBizService.syncHabit(next)
    this.onDataChanged()
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(XuMedia.habit())
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)
        Column({ space: 4 }) {
          Text('习惯')
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
          Text(`今日已打卡 ${this.monthDone} / ${this.items.length === 0 ? 0 : this.items.length}`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .linearGradient({
          angle: 180,
          colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.82)', 1]]
        })
      }
      .width('100%')
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      .borderRadius(Theme.radius.xl)
      .clip(true)

      if (this.items.length === 0) {
        AppEmpty({
          title: '尚未建立习惯',
          description: '从一件小事开始，例如晨读或早起',
          actionLabel: '添加习惯',
          onAction: (): void => { XuDetailNav.openHabitEditor('') }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.items, (h: XuHabitItem) => {
              Column() {
                XuHabitCard({
                  title: h.title,
                  done: h.checkedToday(this.todayKey),
                  streak: h.streak,
                  onToggle: () => { void this.toggle(h.id) },
                  onOpen: () => XuDetailNav.openHabit(h.id)
                })
              }
              .width('48%')
              .margin({ bottom: Theme.space.s3 })
            }, (h: XuHabitItem) => `${h.id}_${h.lastCheck}_${h.streak}`)
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
      }

      AppButton({
        label: '添加习惯',
        onTap: (): void => { XuDetailNav.openHabitEditor('') }
      })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
