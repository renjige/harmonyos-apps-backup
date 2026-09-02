import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CwDateUtil, CwHabit, CwHabitEntry, CwJournalEntry } from '../models/ChenwuModels'
import { ChenwuStore } from '../services/ChenwuStore'
import { ChenwuDetailNav } from '../services/ChenwuDetailNav'
import { ChenwuMedia } from '../services/ChenwuMedia'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwDataRev') @Watch('onDataRev') dataRev: number = 0
  @StorageLink('tabBarHidden') @Watch('onTabBarChange') tabBarHidden: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State habits: CwHabit[] = []
  @State todayJournal: CwJournalEntry | undefined = undefined
  @State todayKey: string = CwDateUtil.todayKey()
  @State listEpoch: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  onTabBarChange(): void {
    if (!this.tabBarHidden) {
      void this.reload()
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private isCheckedToday(h: CwHabit): boolean {
    return h.lastDateKey === this.todayKey
  }

  private async reload(): Promise<void> {
    this.todayKey = CwDateUtil.todayKey()
    this.habits = await ChenwuStore.loadHabits()
    this.todayJournal = await ChenwuStore.journalForDate(this.todayKey)
    this.listEpoch = this.listEpoch + 1
  }

  private async quickCheckIn(h: CwHabit): Promise<void> {
    if (this.isCheckedToday(h)) {
      ChenwuDetailNav.openHabitRecord(h.id)
      return
    }
    const entry = CwHabitEntry.createNew(h.id, this.todayKey)
    entry.done = true
    await ChenwuStore.saveHabitEntry(entry)
    await this.reload()
    this.showToast(`「${h.title}」打卡成功`)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('成长记录')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Text('习惯打卡')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.habits.length === 0) {
            AppEmpty({
              title: '还没有习惯',
              description: '添加一个小习惯，每天记录成长',
              actionLabel: '添加习惯',
              onAction: (): void => {
                const h = CwHabit.createNew('晨间阅读', 'health')
                void ChenwuStore.saveHabit(h).then(() => {
                  void this.reload()
                  ChenwuDetailNav.openHabitRecord(h.id)
                })
              }
            })
          } else {
            ForEach(this.habits, (h: CwHabit) => {
              Row({ space: 12 }) {
                Column() {
                  AppIcon({
                    name: 'check',
                    iconSize: Theme.icon.md,
                    color: this.isCheckedToday(h) ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary
                  })
                }
                .width(44)
                .height(44)
                .borderRadius(22)
                .backgroundColor(this.isCheckedToday(h) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .justifyContent(FlexAlign.Center)
                .onClick((): void => { void this.quickCheckIn(h) })
                Column({ space: 4 }) {
                  Text(h.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.isCheckedToday(h) ? `今日已打卡 · 连续 ${h.streakDays} 天` : `连续 ${h.streakDays} 天`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.isCheckedToday(h) ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                Text(this.isCheckedToday(h) ? '补记' : '打卡')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { ChenwuDetailNav.openHabitRecord(h.id) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { ChenwuDetailNav.openHabit(h.id) })
            }, (h: CwHabit) => `${h.id}_${h.lastDateKey}_${h.streakDays}`)
          }

          Text('今日晨记')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ChenwuMedia.ambientJournal())
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(60)
              .linearGradient({ angle: 180, colors: [['rgba(61,90,108,0)', 0], ['rgba(61,90,108,0.75)', 1]] })
            Text(CwDateUtil.displayDate(this.todayKey))
              .fontSize(Theme.type.caption)
              .fontColor('#F7F5F0')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s3 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.md)

          if (this.todayJournal === undefined) {
            Column({ space: Theme.space.s3 }) {
              Text('今天还没有写下成长札记')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Row() {
                Text('写今日晨记')
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.md)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { ChenwuDetailNav.openJournalEditor('') })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          } else {
            Column({ space: Theme.space.s3 }) {
              if (this.todayJournal.doneToday.length > 0) {
                Text(`今日完成：${this.todayJournal.doneToday}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
              }
              if (this.todayJournal.discovery.length > 0) {
                Text(`发现：${this.todayJournal.discovery}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              Row() {
                Text('编辑晨记')
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .borderRadius(Theme.radius.md)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { ChenwuDetailNav.openJournalEditor(this.todayJournal!.id) })
              Row() {
                Text('查看详情')
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { ChenwuDetailNav.openJournal(this.todayJournal!.id) })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }

          Column().height(this.bottomInset)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor(Theme.colors().surfacePage)
      .onAppear((): void => { void this.reload() })

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
          .position({ x: '50%', y: 48 })
          .markAnchor({ x: '50%', y: 0 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .key(`growth_${this.listEpoch}_${this.dataRev}_${this.refreshToken}`)
  }
}
