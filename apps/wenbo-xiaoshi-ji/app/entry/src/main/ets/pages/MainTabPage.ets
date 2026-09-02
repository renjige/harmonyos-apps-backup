import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { NotesPage } from './NotesPage'
import { TodoPage } from './TodoPage'
import { GrowthPage } from './GrowthPage'
import { TimelinePage } from './TimelinePage'
import { MinePage } from './MinePage'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { TodoDetailPane } from '../components/detail/TodoDetailPane'
import { NoteEditorSheet } from '../components/moment/NoteEditorSheet'
import { TodoEditorSheet } from '../components/moment/TodoEditorSheet'
import { WeeklyReviewSheet } from '../components/moment/WeeklyReviewSheet'
import { DailyWrapSheet } from '../components/moment/DailyWrapSheet'
import { InsightPane } from '../components/moment/InsightPane'
import { CheckinBoardPane } from '../components/moment/CheckinBoardPane'
import { MoodTrendPane } from '../components/moment/MoodTrendPane'
import { MemorialListPane } from '../components/moment/MemorialListPane'
import { MemorialEditorSheet } from '../components/moment/MemorialEditorSheet'
import { PlanDetailPane, PlanEditorSheet } from '../components/moment/PlanSheets'
import { TopicListPane, TopicDetailPane, TopicEditorSheet } from '../components/moment/TopicSheets'
import { ReviewCenterPane } from '../components/moment/ReviewCenterPane'
import { GlobalSearchPane } from '../components/moment/GlobalSearchPane'
import { MomentNav } from '../services/MomentNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '今日'],
      ['1', 'edit', '记录'],
      ['2', 'check', '待办'],
      ['3', 'chart', '成长'],
      ['4', 'user', '我的']
    ]
    for (const d of defs) {
      const t = new TabItem()
      t.index = parseInt(d[0], 10)
      t.name = d[1] as AppIconName
      t.label = d[2]
      tabs.push(t)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @State showTimeline: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('momentNavKind') navKind: string = 'none'
  @StorageLink('momentNavId') navId: string = ''
  @StorageLink('momentNavToken') navToken: number = 0
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 16

  private bump(): void {
    this.refreshToken++
  }

  private inset(): number {
    return this.tabBarHeight + this.tabSafeBottom
  }

  private dismissOverlay(): void {
    MomentNav.close()
    this.bump()
  }

  private closeEditorToList(): void {
    this.dismissOverlay()
  }

  private finishNoteEditor(): void {
    const id = this.navId
    this.bump()
    if (id.length > 0) {
      MomentNav.openNote(id)
      return
    }
    MomentNav.close()
  }

  private finishTodoEditor(): void {
    const id = this.navId
    this.bump()
    if (id.length > 0) {
      MomentNav.openTodo(id)
      return
    }
    MomentNav.close()
  }

  private finishPlanEditor(): void {
    this.bump()
    MomentNav.close()
  }

  private vis(index: number): Visibility {
    return this.current === index ? Visibility.Visible : Visibility.None
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          HomePage({
            refreshToken: this.refreshToken,
            bottomInset: this.inset(),
            onSwitchTab: (index: number): void => { this.current = index },
            onOpenGrowth: (): void => { this.current = 3 }
          })
            .width('100%')
            .height('100%')
            .visibility(this.vis(0))
          NotesPage({
            refreshToken: this.refreshToken,
            bottomInset: this.inset()
          })
            .width('100%')
            .height('100%')
            .visibility(this.vis(1))
          TodoPage({
            refreshToken: this.refreshToken,
            bottomInset: this.inset()
          })
            .width('100%')
            .height('100%')
            .visibility(this.vis(2))
          GrowthPage({
            refreshToken: this.refreshToken,
            bottomInset: this.inset(),
            onOpenTimeline: (): void => {
              this.showTimeline = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.vis(3))
          MinePage({
            refreshToken: this.refreshToken,
            bottomInset: this.inset()
          })
            .width('100%')
            .height('100%')
            .visibility(this.vis(4))
        }
        .layoutWeight(1)
        .width('100%')
        .clip(true)

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(this.tabBarHeight)
          .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: this.tabSafeBottom })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(44,44,44,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .clip(true)
      .visibility(this.navKind === 'none' && !this.showTimeline ? Visibility.Visible : Visibility.Hidden)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showTimeline) {
        TimelinePage({
          refreshToken: this.refreshToken,
          bottomInset: this.inset(),
          onClose: (): void => {
            this.showTimeline = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.navKind === 'note') {
        NoteDetailPane({
          noteId: this.navId,
          onChanged: (): void => this.bump()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'todo') {
        TodoDetailPane({
          todoId: this.navId,
          onChanged: (): void => this.bump()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'editor') {
        NoteEditorSheet({
          noteId: this.navId,
          onSaved: (): void => this.finishNoteEditor(),
          onCancel: (): void => this.closeEditorToList()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'todoEditor') {
        TodoEditorSheet({
          todoId: this.navId,
          onSaved: (): void => this.finishTodoEditor(),
          onCancel: (): void => this.closeEditorToList()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'weeklyReview') {
        WeeklyReviewSheet({
          weekKey: this.navId,
          onSaved: (): void => this.bump()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'dailyWrap') {
        DailyWrapSheet({
          onSaved: (): void => this.bump()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'insight') {
        InsightPane({
          onChanged: (): void => this.bump()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'moodTrend') {
        MoodTrendPane()
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'checkin') {
        CheckinBoardPane()
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'memorials') {
        MemorialListPane()
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'memorialEditor') {
        MemorialEditorSheet({
          memorialId: this.navId,
          onDone: (): void => MomentNav.openMemorials()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'reviewCenter') {
        ReviewCenterPane()
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'search') {
        GlobalSearchPane()
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'plan') {
        PlanDetailPane({
          planId: this.navId,
          onChanged: (): void => this.bump()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'planEditor') {
        PlanEditorSheet({
          planId: this.navId,
          onSaved: (): void => this.finishPlanEditor(),
          onCancel: (): void => this.dismissOverlay()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'topics') {
        TopicListPane()
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'topic') {
        TopicDetailPane({ topicId: this.navId })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.navKind === 'topicEditor') {
        TopicEditorSheet({
          topicId: this.navId,
          onDone: (): void => MomentNav.openTopics()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onClick((): void => {
      if (this.showTimeline) {
        // no-op; timeline has own close
      }
    })
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 4 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandDeep : Theme.colors().textSecondary
        })
      }
      .width(44)
      .height(26)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().surfaceSubtle : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandDeep : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 6 })
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.showTimeline = false
      this.current = t.index
      this.refreshToken++
    })
  }
}
