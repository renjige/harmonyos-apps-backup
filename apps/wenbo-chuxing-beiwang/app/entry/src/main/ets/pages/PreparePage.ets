import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { ChoiceChip } from '../components/travel/TravelCards'
import { CountdownCard } from '../components/travel/CountdownCard'
import { ChecklistPage } from './ChecklistPage'
import { RemindersPage } from './RemindersPage'
import { NotesPage } from './NotesPage'
import { TripItem, ChecklistItem, ReminderItem, NoteItem } from '../models/TravelModels'
import { TravelService } from '../services/TravelService'

@Component
export struct PreparePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State segment: string = 'checklist'
  @State nearestTrip: TripItem = new TripItem()
  @State hasTrip: boolean = false
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  onCreateChecklist: () => void = () => {}
  onCreateReminder: () => void = () => {}
  onCreateNote: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  onEditChecklist: (item: ChecklistItem) => void = () => {}
  onEditReminder: (item: ReminderItem) => void = () => {}
  onEditNote: (item: NoteItem) => void = () => {}
  onDeleteReminder: (item: ReminderItem) => void = () => {}
  onDeleteNote: (item: NoteItem) => void = () => {}

  aboutToAppear(): void {
    void this.loadTrip()
  }

  onEpochChange(): void {
    void this.loadTrip(true)
  }

  private async loadTrip(silent: boolean = false): Promise<void> {
    if (!silent) {
      // no loading spinner needed
    }
    const trips = await TravelService.trips()
    const checklist = await TravelService.checklistItems()
    const enriched = TravelService.attachProgress(trips, checklist)
    const nearest = TravelService.nearestUpcomingTrip(enriched)
    if (nearest.id.length > 0) {
      this.nearestTrip = nearest
      this.hasTrip = true
      return
    }
    this.nearestTrip = new TripItem()
    this.hasTrip = false
  }

  private refreshProgress(_done: number, _total: number, percent: number): void {
    if (this.nearestTrip.id.length === 0) {
      return
    }
    const next = TravelService.mapTrip(this.nearestTrip)
    next.progress = percent
    this.nearestTrip = next
  }

  private scrollBottomPad(): number {
    return Theme.nav.tabHeight + Theme.space.s10
  }

  build() {
    Column() {
      Scroll() {
      Column({ space: Theme.space.s3 }) {
        AppHeader({ title: '准备中心', subtitle: '清单核对 · 出发提醒 · 旅途备忘' })

        if (this.hasTrip) {
          CountdownCard({ trip: this.nearestTrip })
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        } else {
          Row() {
            Column({ space: 4 }) {
              Text('暂无待出发行程')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('创建行程或在攻略页使用模板，即可开始准备')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Text('刷新')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.loadTrip() })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }

        Row({ space: Theme.space.s2 }) {
          ChoiceChip({ label: '打包清单', selected: this.segment === 'checklist',
            onTap: () => { this.segment = 'checklist' } })
          ChoiceChip({ label: '出发提醒', selected: this.segment === 'reminder',
            onTap: () => { this.segment = 'reminder' } })
          ChoiceChip({ label: '旅途备忘', selected: this.segment === 'note',
            onTap: () => { this.segment = 'note' } })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.segment === 'checklist') {
          ChecklistPage({
            dataEpoch: this.dataEpoch,
            embedded: true,
            onCreate: () => this.onCreateChecklist(),
            onRequireAuth: () => this.onRequireAuth(),
            onChanged: () => this.onChanged(),
            onEditItem: (item: ChecklistItem) => this.onEditChecklist(item),
            onProgressChange: (done: number, total: number, percent: number) => {
              this.refreshProgress(done, total, percent)
            }
          })
        } else if (this.segment === 'reminder') {
          RemindersPage({
            dataEpoch: this.dataEpoch,
            embedded: true,
            onCreate: () => this.onCreateReminder(),
            onRequireAuth: () => this.onRequireAuth(),
            onChanged: () => this.onChanged(),
            onEditItem: (item: ReminderItem) => this.onEditReminder(item),
            onDeleteItem: (item: ReminderItem) => this.onDeleteReminder(item)
          })
        } else {
          NotesPage({
            dataEpoch: this.dataEpoch,
            embedded: true,
            onCreate: () => this.onCreateNote(),
            onRequireAuth: () => this.onRequireAuth(),
            onChanged: () => this.onChanged(),
            onEditItem: (item: NoteItem) => this.onEditNote(item),
            onDeleteItem: (item: NoteItem) => this.onDeleteNote(item)
          })
        }
      }
      .width('100%')
      .padding({ bottom: this.scrollBottomPad() })
    }
    .layoutWeight(1)
    .width('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .backgroundColor(Theme.colors().surfacePage)
  }
}
