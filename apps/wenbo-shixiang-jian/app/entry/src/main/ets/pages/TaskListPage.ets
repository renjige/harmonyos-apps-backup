import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { TaskListCard } from '../components/task/TaskListCard'
import { CategoryItem, TaskItem } from '../models/TaskModels'
import { TaskBizService } from '../services/TaskBizService'
import { TaskDetailNav } from '../services/TaskDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct TaskListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onCreateTask: () => void = () => {}
  @State categories: CategoryItem[] = []
  @State tasks: TaskItem[] = []
  @State filterCategory: string = ''
  @State laneFilter: string = 'all'
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.categories = await TaskBizService.loadCategories()
    if (AuthService.isLoggedIn()) {
      this.tasks = await TaskBizService.loadTasks(this.currentUsername, this.filterCategory)
    } else {
      this.tasks = []
    }
    this.loading = false
  }

  private visibleTasks(): TaskItem[] {
    const out: TaskItem[] = []
    for (const t of this.tasks) {
      if (this.laneFilter === 'commitment' && t.lane !== 'commitment') {
        continue
      }
      if (this.laneFilter === 'waitlist' && t.lane === 'commitment') {
        continue
      }
      out.push(t)
    }
    return out
  }

  private async applyFilter(catId: string): Promise<void> {
    this.filterCategory = this.filterCategory === catId ? '' : catId
    if (AuthService.isLoggedIn()) {
      this.tasks = await TaskBizService.loadTasks(this.currentUsername, this.filterCategory)
    }
  }

  build() {
    Column() {
      AppHeader({ title: '清单', subtitle: '承诺席位 · 候补池 · 分类' })
      Row({ space: Theme.space.s3 }) {
        AppButton({
          label: '新建事项',
          onTap: (): void => {
            if (!AuthService.requireAuth('create_task')) {
              this.onRequireAuth()
              return
            }
            this.onCreateTask()
          }
        })
          .layoutWeight(1)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Row({ space: 8 }) {
        Text('全部')
          .fontSize(Theme.type.caption)
          .fontColor(this.laneFilter === 'all' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.laneFilter === 'all' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.laneFilter = 'all' })
        Text('今日承诺')
          .fontSize(Theme.type.caption)
          .fontColor(this.laneFilter === 'commitment' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.laneFilter === 'commitment' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.laneFilter = 'commitment' })
        Text('候补池')
          .fontSize(Theme.type.caption)
          .fontColor(this.laneFilter === 'waitlist' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.laneFilter === 'waitlist' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.laneFilter = 'waitlist' })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.categories, (c: CategoryItem) => {
            Text(c.title)
              .fontSize(Theme.type.caption)
              .fontColor(this.filterCategory === c.id ?
                Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.filterCategory === c.id ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.applyFilter(c.id) })
          }, (c: CategoryItem) => c.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else if (this.visibleTasks().length === 0) {
            AppEmpty({
              title: '暂无事项',
              description: AuthService.isLoggedIn() ? '点击新建，锁定时段承诺或写入候补' : '登录后可创建个人事项',
              actionLabel: '新建事项',
              onAction: (): void => {
                if (!AuthService.requireAuth('create_task')) {
                  this.onRequireAuth()
                  return
                }
                this.onCreateTask()
              }
            })
          } else {
            ForEach(this.visibleTasks(), (item: TaskItem) => {
              TaskListCard({
                item: item,
                onTap: (): void => { TaskDetailNav.openTask(item.id, item) }
              })
            }, (item: TaskItem) => item.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
