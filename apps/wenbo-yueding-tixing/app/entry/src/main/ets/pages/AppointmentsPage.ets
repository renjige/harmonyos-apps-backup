import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppError } from '../components/design-system/AppError'
import { AppButton } from '../components/design-system/AppButton'
import { AppointmentCardUtil, AppointmentRow, SectionTitle } from '../components/appointment/AppointmentCards'
import { AppointmentItem } from '../models/AppointmentModels'
import { AppointmentService } from '../services/AppointmentService'
import { ScheduleEngine } from '../services/ScheduleEngine'

class ListTab {
  key: string = ''
  label: string = ''
}

@Component
export struct AppointmentsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State tab: string = 'today'
  @State scene: string = 'all'
  @State query: string = ''
  @State todayItems: AppointmentItem[] = []
  @State futureItems: AppointmentItem[] = []
  @State doneItems: AppointmentItem[] = []
  @State missedItems: AppointmentItem[] = []
  @State favoriteItems: AppointmentItem[] = []
  @State loading: boolean = true
  @State loadError: string = ''
  @Prop @Watch('onTick') refreshToken: number = 0
  onCreate: () => void = () => {}
  onOpenItem: (id: string) => void = () => {}
  onImport: () => void = () => {}
  onOpenCalendar: () => void = () => {}
  onOpenSearch: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private tabs(): ListTab[] {
    const a = new ListTab(); a.key = 'today'; a.label = '今日'
    const b = new ListTab(); b.key = 'future'; b.label = '未来'
    const c = new ListTab(); c.key = 'done'; c.label = '已完成'
    const d = new ListTab(); d.key = 'missed'; d.label = '逾期'
    const e = new ListTab(); e.key = 'favorite'; e.label = '收藏'
    return [a, b, c, d, e]
  }

  private scenes(): ListTab[] {
    const a = new ListTab(); a.key = 'all'; a.label = '全部'
    const b = new ListTab(); b.key = 'work'; b.label = '工作'
    const c = new ListTab(); c.key = 'life'; c.label = '生活'
    const d = new ListTab(); d.key = 'study'; d.label = '学习'
    const e = new ListTab(); e.key = 'health'; e.label = '健康'
    return [a, b, c, d, e]
  }

  private currentItems(): AppointmentItem[] {
    let source: AppointmentItem[] = this.todayItems
    if (this.tab === 'future') {
      source = this.futureItems
    } else if (this.tab === 'done') {
      source = this.doneItems
    } else if (this.tab === 'missed') {
      source = this.missedItems
    } else if (this.tab === 'favorite') {
      source = this.favoriteItems
    }
    const out: AppointmentItem[] = []
    for (const row of source) {
      if (this.scene !== 'all' && row.scene !== this.scene) {
        continue
      }
      if (!ScheduleEngine.matchesQuery(row, this.query.trim())) {
        continue
      }
      out.push(row)
    }
    return out
  }

  private emptyTitle(): string {
    if (this.query.length > 0 || this.scene !== 'all') {
      return '没有符合筛选的约定'
    }
    if (this.tab === 'future') {
      return '暂无未来约定'
    }
    if (this.tab === 'done') {
      return '还没有完成的约定'
    }
    if (this.tab === 'missed') {
      return '没有逾期约定'
    }
    if (this.tab === 'favorite') {
      return '还没有收藏'
    }
    return '今天还没有约定'
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadError = ''
    try {
      this.todayItems = await AppointmentService.listToday()
      this.futureItems = await AppointmentService.listFuture()
      this.doneItems = await AppointmentService.listDone()
      this.missedItems = await AppointmentService.listMissed()
      this.favoriteItems = await AppointmentService.listFavorites()
    } catch {
      this.todayItems = []
      this.futureItems = []
      this.doneItems = []
      this.missedItems = []
      this.favoriteItems = []
    }
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '约定中心', subtitle: '搜索 · 筛选 · 收藏 · 月历' })
      Row({ space: 8 }) {
        TextInput({ text: this.query, placeholder: '搜索标题、地点或备注' })
          .layoutWeight(1)
          .onChange((v: string) => { this.query = v })
        Text('搜索')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .onClick((): void => { this.onOpenSearch() })
        Text('月历')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .onClick((): void => { this.onOpenCalendar() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.tabs(), (t: ListTab) => {
            Text(t.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.tab === t.key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.tab === t.key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.tab = t.key })
          }, (t: ListTab) => t.key)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      if (this.tab !== 'favorite') {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.scenes(), (t: ListTab) => {
              Text(t.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.scene === t.key ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.scene === t.key ?
                  Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.scene = t.key })
            }, (t: ListTab) => `s_${t.key}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
      }

      if (this.loading) {
        AppLoading({ label: '加载中…' }).layoutWeight(1)
      } else if (this.loadError.length > 0) {
        AppError({
          message: this.loadError,
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else if (this.currentItems().length === 0) {
        Column() {
          AppEmpty({
            title: this.emptyTitle(),
            description: '可换筛选，或点下方按钮新建一件约定'
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 4 }) {
            SectionTitle({ title: `${this.currentItems().length} 条` })
            ForEach(this.currentItems(), (row: AppointmentItem) => {
              AppointmentRow({
                title: row.title,
                timeLabel: row.dateTimeLabel(),
                meta: AppointmentCardUtil.rowMeta(row),
                done: row.isDone(),
                onTap: (): void => { this.onOpenItem(row.id) }
              })
            }, (row: AppointmentItem) => row.id)
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

      Row({ space: 8 }) {
        Column() {
          AppButton({
            label: '粘贴导入',
            variant: 'secondary',
            onTap: (): void => { this.onImport() }
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: '新建约定',
            onTap: (): void => { this.onCreate() }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.space.pageX)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
