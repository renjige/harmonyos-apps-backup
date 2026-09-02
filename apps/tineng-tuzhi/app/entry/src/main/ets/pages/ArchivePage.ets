import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ArchiveCollections } from '../components/fitness/ArchiveCollections'
import { ArchiveEditorSheet } from '../components/fitness/ArchiveEditorSheet'
import { MixBarChart } from '../components/fitness/MixBarChart'
import { ArchiveDraft, CyclePlan, GoalChallenge, InsightFav, LibraryAction, PrepList } from '../models/TrainingModels'
import { MixBar, WorkoutRecord, WorkoutTypeOption } from '../models/WorkoutModels'
import { DateHelper } from '../services/DateHelper'
import { StatsService } from '../services/StatsService'
import { TrainingStore } from '../services/TrainingStore'
import { WorkoutStore } from '../services/WorkoutStore'

@Component
export struct ArchivePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenDetail: (id: string) => void = () => {}
  onRecord: () => void = () => {}
  @State checkedToday: boolean = false
  @State checkinStreak: number = 0
  @State totalWorkouts: number = 0
  @State totalMinutes: number = 0
  @State challengeDone: number = 0
  @State planCount: number = 0
  @State mix: MixBar[] = []
  @State timeline: WorkoutRecord[] = []
  @State plans: CyclePlan[] = []
  @State actions: LibraryAction[] = []
  @State lists: PrepList[] = []
  @State favs: InsightFav[] = []
  @State challenges: GoalChallenge[] = []
  @State editorMode: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await TrainingStore.ensureTemplates()
    this.checkedToday = await TrainingStore.isCheckedToday()
    this.checkinStreak = await TrainingStore.checkinStreak()
    const stats = await StatsService.totals()
    this.totalWorkouts = stats.totalWorkouts
    this.totalMinutes = stats.totalMinutes
    this.plans = await TrainingStore.loadPlans()
    this.planCount = this.plans.length
    this.actions = await TrainingStore.loadActions()
    this.lists = await TrainingStore.loadLists()
    this.favs = await TrainingStore.loadFavs()
    this.challenges = await TrainingStore.loadChallenges()
    let done = 0
    for (const c of this.challenges) {
      if (c.done) {
        done++
      }
    }
    this.challengeDone = done
    const keys = DateHelper.weekDateKeys(DateHelper.todayKey())
    if (keys.length >= 7) {
      this.mix = await StatsService.sportMix(keys[0], keys[6])
    }
    const all = await WorkoutStore.loadAll()
    const cut: WorkoutRecord[] = []
    let n = 0
    for (const w of all) {
      if (n >= 8) {
        break
      }
      cut.push(w)
      n++
    }
    this.timeline = cut
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private openEditor(mode: string): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    this.editorMode = mode
  }

  private closeEditor(): void {
    this.editorMode = ''
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async handleCheckin(): Promise<void> {
    const on = await TrainingStore.toggleTodayCheckin()
    await this.reload()
    this.showToast(on ? '今日已打卡' : '已取消今日打卡')
  }

  private async handleSaveDraft(d: ArchiveDraft): Promise<void> {
    if (d.mode === 'plan') {
      const p = new CyclePlan()
      p.id = TrainingStore.newId()
      p.title = d.title
      p.goalText = d.extra
      p.periodDays = DateHelper.safeInt(d.extraNum, 30)
      p.startKey = DateHelper.todayKey()
      await TrainingStore.savePlan(p)
    } else if (d.mode === 'action') {
      const a = new LibraryAction()
      a.id = TrainingStore.newId()
      a.name = d.title
      a.desc = d.extra
      a.category = d.category
      await TrainingStore.saveAction(a)
    } else if (d.mode === 'list') {
      const p = new PrepList()
      p.id = TrainingStore.newId()
      p.title = d.title
      p.itemsText = d.extra.length > 0 ? d.extra : '准备开始'
      p.doneMask = ''
      p.rebuildLines()
      await TrainingStore.saveList(p)
    } else if (d.mode === 'fav') {
      const f = new InsightFav()
      f.id = TrainingStore.newId()
      f.title = d.title
      f.body = d.extra
      await TrainingStore.saveFav(f)
    } else {
      const c = new GoalChallenge()
      c.id = TrainingStore.newId()
      c.title = d.title
      c.kind = d.kind
      c.target = DateHelper.safeInt(d.extraNum, 21)
      await TrainingStore.saveChallenge(c)
    }
    this.closeEditor()
    await this.reload()
    this.showToast('已保存到体能档案')
  }

  private async toggleChallenge(id: string): Promise<void> {
    await TrainingStore.toggleChallenge(id)
    await this.reload()
  }

  private async toggleLine(listId: string, index: number): Promise<void> {
    await TrainingStore.toggleListItem(listId, index)
    this.lists = await TrainingStore.loadLists()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('体能档案')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text(this.checkedToday ? '今日已打卡' : '今日尚未打卡')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
            Text(`连续坚持 ${this.checkinStreak} 天`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            AppButton({
              label: this.checkedToday ? '取消今日打卡' : '完成今日打卡',
              variant: this.checkedToday ? 'secondary' : 'primary',
              onTap: (): void => { void this.handleCheckin() }
            })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s3 }) {
            this.NumCard(`${this.totalWorkouts}`, '累计训练')
            this.NumCard(`${this.totalMinutes}`, '累计分钟')
          }
          .width('100%')
          Row({ space: Theme.space.s3 }) {
            this.NumCard(`${this.challengeDone}`, '完成挑战')
            this.NumCard(`${this.planCount}`, '进行中计划')
          }
          .width('100%')

          MixBarChart({ items: this.mix })
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

          Row() {
            Text('成长时间轴')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('记录训练')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => this.onRecord())
          }
          .width('100%')

          if (this.timeline.length === 0) {
            Text('还没有训练记录，先记下第一笔。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.timeline, (w: WorkoutRecord) => {
              Row({ space: Theme.space.s3 }) {
                AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                Column({ space: 2 }) {
                  Text(`${w.dateKey} · ${WorkoutTypeOption.labelFor(w.typeKey)}`)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${w.durationMinutes} 分钟 · ${w.insight.length > 0 ? w.insight : w.note}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(1)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.onOpenDetail(w.id) })
            }, (w: WorkoutRecord) => w.id)
          }

          ArchiveCollections({
            plans: this.plans,
            actions: this.actions,
            lists: this.lists,
            challenges: this.challenges,
            favs: this.favs,
            onAddPlan: (): void => this.openEditor('plan'),
            onAddAction: (): void => this.openEditor('action'),
            onAddList: (): void => this.openEditor('list'),
            onAddChallenge: (): void => this.openEditor('challenge'),
            onAddFav: (): void => this.openEditor('fav'),
            onToggleChallenge: (id: string): void => { void this.toggleChallenge(id) },
            onToggleLine: (listId: string, index: number): void => { void this.toggleLine(listId, index) }
          })

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      if (this.editorMode.length > 0) {
        ArchiveEditorSheet({
          mode: this.editorMode,
          onClose: (): void => { this.closeEditor() },
          onSave: (d: ArchiveDraft): void => { void this.handleSaveDraft(d) }
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ top: 48 })
          .backgroundColor('#1A2332')
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  NumCard(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }
}
