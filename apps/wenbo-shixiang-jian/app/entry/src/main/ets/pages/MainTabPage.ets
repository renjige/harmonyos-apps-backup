import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { SchedulePage } from './SchedulePage'
import { TaskListPage } from './TaskListPage'
import { HabitPage } from './HabitPage'
import { MinePage } from './MinePage'
import { HistoryPage } from './HistoryPage'
import { OrganizePage } from './OrganizePage'
import { MessagesPage } from './MessagesPage'
import { TaskDetailPane } from '../components/detail/TaskDetailPane'
import { TipDetailPane } from '../components/detail/TipDetailPane'
import { CreateTaskOverlay } from '../components/task/CreateTaskOverlay'
import { CreateHabitOverlay } from '../components/task/CreateHabitOverlay'
import { EfficiencyDiagnoseOverlay } from '../components/task/EfficiencyDiagnoseOverlay'
import { FocusSessionOverlay } from '../components/task/FocusSessionOverlay'
import { CloseDayOverlay } from '../components/task/CloseDayOverlay'
import { WeeklyReviewOverlay } from '../components/task/WeeklyReviewOverlay'
import { HabitOverviewOverlay, HabitOverviewMode } from '../components/task/HabitOverviewOverlay'
import { AuthService } from '../services/AuthService'
import { TaskDetailNav } from '../services/TaskDetailNav'
import { TaskItem } from '../models/TaskModels'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'calendar'
    t1.label = '日程'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '清单'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'check'
    t3.label = '习惯'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：首页 | 日程 | 清单 | 习惯 | 我的；详情 Overlay 顶层 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State showCreateTask: boolean = false
  @State showCreateHabit: boolean = false
  @State editTaskItem: TaskItem | undefined = undefined
  @State showHistory: boolean = false
  @State showOrganize: boolean = false
  @State showMessages: boolean = false
  @State showHabitOverview: boolean = false
  @State showEfficiencyDiagnose: boolean = false
  @State showFocusSession: boolean = false
  @State showCloseDay: boolean = false
  @State showWeeklyReview: boolean = false
  @State focusTaskItem: TaskItem = new TaskItem()
  @State habitOverviewMode: HabitOverviewMode = 'all'
  @State historyRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @Prop company: string = '魏文波'
  @Prop appName: string = '事项笺'
  @Prop tagline: string = '每天 3 件承诺 · 时段工位 · 专注计时后收工'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
    this.detailRefresh += 1
  }

  private closeAllOverlays(): void {
    this.showCreateTask = false
    this.showCreateHabit = false
    this.editTaskItem = undefined
    this.showHistory = false
    this.showOrganize = false
    this.showMessages = false
    this.showHabitOverview = false
    this.showEfficiencyDiagnose = false
    this.showFocusSession = false
    this.showCloseDay = false
    this.showWeeklyReview = false
    if (TaskDetailNav.isOpen()) {
      TaskDetailNav.close()
    }
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private requireAuth(): void {
    this.closeAllOverlays()
    this.onRequireAuth()
  }

  private openCreateTask(): void {
    this.editTaskItem = undefined
    this.showCreateTask = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openFocus(item: TaskItem): void {
    this.focusTaskItem = item
    this.showFocusSession = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openEditTask(item: TaskItem): void {
    TaskDetailNav.close()
    this.editTaskItem = item
    this.showCreateTask = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.contentRefresh,
            onQuickAdd: (): void => { this.openCreateTask() },
            onOpenDiagnose: (): void => {
              this.showEfficiencyDiagnose = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenOrganize: (): void => {
              this.showOrganize = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenHabits: (): void => {
              this.current = 3
            },
            onStartFocus: (item: TaskItem): void => { this.openFocus(item) },
            onCloseDay: (): void => {
              this.showCloseDay = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          SchedulePage({
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else if (this.current === 2) {
          TaskListPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.requireAuth(),
            onCreateTask: (): void => { this.openCreateTask() }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          HabitPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.requireAuth(),
            onOpenCreate: (): void => {
              this.showCreateHabit = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onOpenHistory: (): void => {
              this.showHistory = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.historyRefresh += 1
            },
            onOpenOrganize: (): void => {
              this.showOrganize = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenMessages: (): void => {
              this.showMessages = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenHabitList: (): void => {
              this.habitOverviewMode = 'all'
              this.showHabitOverview = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenCheckInToday: (): void => {
              this.habitOverviewMode = 'today'
              this.showHabitOverview = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenWeeklyReview: (): void => {
              this.showWeeklyReview = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(37,99,235,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showHistory) {
        HistoryPage({
          refreshToken: this.historyRefresh,
          onClose: (): void => {
            this.showHistory = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showOrganize) {
        OrganizePage({
          onRequireAuth: (): void => this.requireAuth(),
          onClose: (): void => {
            this.showOrganize = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => {
            this.showMessages = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showWeeklyReview) {
        WeeklyReviewOverlay({
          onClose: (): void => {
            this.showWeeklyReview = false
            AppStorage.setOrCreate('tabBarHidden', TaskDetailNav.isOpen())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showCloseDay) {
        CloseDayOverlay({
          onRequireAuth: (): void => this.requireAuth(),
          onSaved: (): void => { this.bumpContentRefresh() },
          onClose: (): void => {
            this.showCloseDay = false
            AppStorage.setOrCreate('tabBarHidden', TaskDetailNav.isOpen())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(19)
      }

      if (this.showFocusSession) {
        FocusSessionOverlay({
          item: this.focusTaskItem,
          onRequireAuth: (): void => this.requireAuth(),
          onFinished: (): void => { this.bumpContentRefresh() },
          onClose: (): void => {
            this.showFocusSession = false
            AppStorage.setOrCreate('tabBarHidden', TaskDetailNav.isOpen() || this.showCreateTask)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(21)
      }

      if (this.showEfficiencyDiagnose) {
        EfficiencyDiagnoseOverlay({
          onClose: (): void => {
            this.showEfficiencyDiagnose = false
            AppStorage.setOrCreate('tabBarHidden', TaskDetailNav.isOpen())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showHabitOverview) {
        HabitOverviewOverlay({
          mode: this.habitOverviewMode,
          onClose: (): void => {
            this.showHabitOverview = false
            this.showEfficiencyDiagnose = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showCreateHabit) {
        CreateHabitOverlay({
          onRequireAuth: (): void => this.requireAuth(),
          onSaved: (): void => { this.bumpContentRefresh() },
          onClose: (): void => {
            this.showCreateHabit = false
            AppStorage.setOrCreate('tabBarHidden', TaskDetailNav.isOpen())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showCreateTask) {
        CreateTaskOverlay({
          editItem: this.editTaskItem,
          onRequireAuth: (): void => this.requireAuth(),
          onSaved: (): void => { this.bumpContentRefresh() },
          onClose: (): void => {
            this.showCreateTask = false
            this.editTaskItem = undefined
            AppStorage.setOrCreate('tabBarHidden', TaskDetailNav.isOpen())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.detailRoute.length > 0) {
        this.DetailOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailOverlay() {
    if (TaskDetailNav.parseKind() === 'task') {
      TaskDetailPane({
        itemId: TaskDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.requireAuth(),
        onEdit: (item: TaskItem): void => { this.openEditTask(item) },
        onCompleted: (): void => { this.bumpContentRefresh() },
        onDeleted: (): void => { this.bumpContentRefresh() },
        onStartFocus: (item: TaskItem): void => { this.openFocus(item) }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (TaskDetailNav.parseKind() === 'tip') {
      TipDetailPane({
        itemId: TaskDetailNav.parseId(),
        refreshToken: this.detailRefresh
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    }
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      if (TaskDetailNav.isOpen()) {
        TaskDetailNav.close()
      }
      this.showHistory = false
      this.showOrganize = false
      this.showMessages = false
      this.showHabitOverview = false
      this.showEfficiencyDiagnose = false
      this.showFocusSession = false
      this.showCloseDay = false
      this.showWeeklyReview = false
      this.showCreateTask = false
      this.showCreateHabit = false
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
