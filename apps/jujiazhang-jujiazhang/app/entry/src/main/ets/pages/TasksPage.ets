import { Theme } from '../components/design-system/Theme'
import { TaskRow } from '../components/family/TaskRow'
import { ChoiceChip } from '../components/family/ChoiceChip'
import { FamilyTaskItem } from '../models/FamilyTaskModels'
import { CategorySuggest } from '../services/CategorySuggest'
import { TaskService } from '../services/TaskService'
import { CalendarPage } from './CalendarPage'

@Component
export struct TasksPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: FamilyTaskItem[] = []
  @State filter: string = 'all'
  @State segment: string = 'list'
  @StorageLink('windowIsWide') isWide: boolean = false
  @Prop @Watch('onTick') refreshToken: number = 0
  @Prop compact: boolean = false
  onOpen: (item: FamilyTaskItem) => void = (_i: FamilyTaskItem) => {}
  onToggle: (item: FamilyTaskItem) => void = (_i: FamilyTaskItem) => {}
  onAdd: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.items = await TaskService.all()
  }

  private visible(): FamilyTaskItem[] {
    const out: FamilyTaskItem[] = []
    for (const row of this.items) {
      if (this.filter === 'open' && row.completed) {
        continue
      }
      if (this.filter === 'done' && !row.completed) {
        continue
      }
      if (this.filter === 'repeat' && row.repeatType === 'none') {
        continue
      }
      if (this.filter !== 'all' && this.filter !== 'open' && this.filter !== 'done' && this.filter !== 'repeat') {
        if (CategorySuggest.normalize(row.category) !== this.filter) {
          continue
        }
      }
      out.push(row)
    }
    return out
  }

  private handleToggle(row: FamilyTaskItem): void {
    const nextCompleted = !row.completed
    this.items = TaskService.mapToggleList(this.items, row.id, nextCompleted)
    this.onToggle(row)
  }

  build() {
    Column() {
      if (!this.compact) {
        Text('家庭计划')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
      }
      Row({ space: 8 }) {
        ChoiceChip({ label: '列表', active: this.segment === 'list', onPick: () => { this.segment = 'list' } })
        ChoiceChip({ label: '月历', active: this.segment === 'calendar', onPick: () => { this.segment = 'calendar' } })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      if (this.segment === 'calendar') {
        CalendarPage({
          refreshToken: this.refreshToken,
          onOpen: (it: FamilyTaskItem) => this.onOpen(it),
          onToggle: (it: FamilyTaskItem) => this.onToggle(it),
          onAdd: () => this.onAdd()
        }).layoutWeight(1)
      } else {
      Row({ space: 8 }) {
        ChoiceChip({ label: '全部', active: this.filter === 'all', onPick: () => { this.filter = 'all' } })
        ChoiceChip({ label: '未完成', active: this.filter === 'open', onPick: () => { this.filter = 'open' } })
        ChoiceChip({ label: '已完成', active: this.filter === 'done', onPick: () => { this.filter = 'done' } })
        ChoiceChip({ label: '重复', active: this.filter === 'repeat', onPick: () => { this.filter = 'repeat' } })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 4 })
      Scroll() {
        Row({ space: 8 }) {
          ForEach(CategorySuggest.categories(), (c: string) => {
            ChoiceChip({ label: c, active: this.filter === c, onPick: () => { this.filter = c } })
          }, (c: string) => c)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      if (this.visible().length === 0) {
        Column({ space: 10 }) {
          Image($r('app.media.empty_idle'))
            .width('100%')
            .height(140)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
          Text('还没有这类家庭事项')
            .fontSize(Theme.type.title3)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('家里的事，有条理地记下来。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text('添加事项')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.button)
            .onClick(() => this.onAdd())
        }
        .padding(20)
        .margin(Theme.space.pageX)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      } else {
        List() {
          ForEach(this.visible(), (it: FamilyTaskItem) => {
            ListItem() {
              TaskRow({
                item: it,
                showDate: true,
                onToggle: (row: FamilyTaskItem) => this.handleToggle(row),
                onOpen: (row: FamilyTaskItem) => this.onOpen(row)
              })
            }
            .padding({ bottom: 10 })
          }, (it: FamilyTaskItem) => `${it.id}_${it.completed ? '1' : '0'}`)
        }
        .layoutWeight(1)
        .padding({ left: this.isWide ? 32 : Theme.space.pageX, right: this.isWide ? 32 : Theme.space.pageX })
        .scrollBar(BarState.Off)
      }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
