import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { WorkbenchSnapshot, PlanRef, BookNoteRef } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { AchievementDef } from '../../models/StudyModels'

@Component
export struct StudyWorkbench {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('noteEpoch') @Watch('onEpochChange') noteEpoch: number = 0
  @StorageLink('studyEpoch') @Watch('onEpochChange') studyEpoch: number = 0
  @StorageLink('statTotalNotes') statTotalNotes: number = 0
  @StorageLink('statBookCount') statBookCount: number = 0
  @StorageLink('statFavoriteCount') statFavoriteCount: number = 0
  @Prop reloadToken: number = 0
  @State snap: WorkbenchSnapshot = new WorkbenchSnapshot()
  @State moodNote: string = ''
  @State toastText: string = ''
  onOpenDetail: (id: string) => void = (_id: string) => {}
  onGoCapture: () => void = () => {}
  onOpenPlans: () => void = () => {}
  onOpenTopics: () => void = () => {}
  onOpenStats: () => void = () => {}
  onOpenPlan: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onEpochChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.snap = await StudyStore.workbenchSnapshot()
  }

  private goalLeft(): number {
    if (this.snap.monthGoalTarget <= 0) {
      return 1
    }
    const p = Math.floor((this.snap.monthGoalProgress * 100) / this.snap.monthGoalTarget)
    return p <= 0 ? 1 : (p > 100 ? 100 : p)
  }

  private goalRight(): number {
    const p = this.snap.monthGoalTarget <= 0 ? 0 :
      Math.floor((this.snap.monthGoalProgress * 100) / this.snap.monthGoalTarget)
    if (p >= 100) {
      return 1
    }
    return 100 - p
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async doCheckIn(): Promise<void> {
    if (this.snap.todayCheckedIn) {
      this.showToast('今日已打卡')
      return
    }
    await StudyStore.checkInToday(this.moodNote)
    const unlockId = StudyStore.lastUnlockedAchievement()
    await this.load()
    this.showToast('打卡成功，继续保持阅读习惯')
    if (unlockId.length > 0) {
      setTimeout((): void => {
        const def = AchievementDef.catalog()
        for (const d of def) {
          if (d.id === unlockId) {
            this.showToast(`成就解锁：${d.title}`)
          }
        }
        StudyStore.clearLastUnlock()
      }, 2400)
    }
  }

  build() {
    Stack() {
      Column({ space: Theme.space.s3 }) {
        Column({ space: Theme.space.s2 }) {
          Text('今日阅读')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`本月目标 ${this.snap.monthGoalProgress}/${this.snap.monthGoalTarget} 条`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row() {
            Column()
              .layoutWeight(this.goalLeft())
              .height(8)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius({ topLeft: 4, bottomLeft: 4 })
            Column()
              .layoutWeight(this.goalRight())
              .height(8)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius({ topRight: 4, bottomRight: 4 })
          }
          .width('100%')
          .clip(true)
          Row({ space: 8 }) {
            this.StatChip(`${this.statTotalNotes}`, '书摘')
            this.StatChip(`${this.statBookCount}`, '书籍')
            this.StatChip(`${this.statFavoriteCount}`, '收藏')
            this.StatChip(`${this.snap.checkInStreak}`, '连续天')
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(12)

        Row({ space: 8 }) {
          this.QuickBtn('添加', (): void => { this.onGoCapture() })
          this.QuickBtn('计划', (): void => { this.onOpenPlans() })
          this.QuickBtn('专题', (): void => { this.onOpenTopics() })
          this.QuickBtn('统计', (): void => { this.onOpenStats() })
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Row() {
            Text(this.snap.todayCheckedIn ? '今日已打卡 ✓' : '今日阅读打卡')
              .fontSize(Theme.type.bodyS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            if (!this.snap.todayCheckedIn) {
              Text('立即打卡')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { void this.doCheckIn() })
            }
          }
          .width('100%')
          if (!this.snap.todayCheckedIn) {
            TextInput({ text: this.moodNote, placeholder: '可选：写一句今日阅读心得' })
              .width('100%')
              .height(40)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string): void => { this.moodNote = v })
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(12)

        if (this.snap.activePlans.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Row() {
              Text('进行中的计划')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text('全部')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { this.onOpenPlans() })
            }
            .width('100%')
            ForEach(this.snap.activePlans, (p: PlanRef) => {
              Column({ space: 6 }) {
                Text(p.title)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(`${p.doneCount}/${p.targetCount} · ${p.progressPercent}%`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { this.onOpenPlan(p.id) })
            }, (p: PlanRef) => p.id)
          }
          .width('100%')
        }

        if (this.snap.recentNotes.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('最近书摘')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.snap.recentNotes, (n: BookNoteRef) => {
              Column({ space: 4 }) {
                Text(n.bookName)
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .width('100%')
                Text(n.excerptPreview)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { this.onOpenDetail(n.id) })
            }, (n: BookNoteRef) => n.id)
          }
          .width('100%')
        }
      }
      .width('100%')

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s2 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
  }

  @Builder
  StatChip(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.overline)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.sm)
  }

  @Builder
  QuickBtn(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontWeight(FontWeight.Medium)
      .fontColor(Theme.colors().brandPrimary)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding({ top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { onTap() })
  }
}
