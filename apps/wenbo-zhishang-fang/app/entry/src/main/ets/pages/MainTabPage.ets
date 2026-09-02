import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { BookShelfPage } from './BookShelfPage'
import { CapturePage } from './CapturePage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { NoteDetailPane } from '../components/note/NoteDetailPane'
import { ReadingPlanListPane } from '../components/study/ReadingPlanListPane'
import { ReadingPlanEditorPane } from '../components/study/ReadingPlanEditorPane'
import { ReadingPlanDetailPane } from '../components/study/ReadingPlanDetailPane'
import { TopicListPane } from '../components/study/TopicListPane'
import { TopicEditorPane } from '../components/study/TopicEditorPane'
import { TopicDetailPane } from '../components/study/TopicDetailPane'
import { StatsCenterPane } from '../components/study/StatsCenterPane'
import { FullTimelinePane } from '../components/study/FullTimelinePane'
import { AchievementWallPane } from '../components/study/AchievementWallPane'
import { WeeklyRecapPane } from '../components/study/WeeklyRecapPane'
import { BookLibraryEditorPane } from '../components/study/BookLibraryEditorPane'
import { BookLibraryDetailPane } from '../components/study/BookLibraryDetailPane'
import { ReadingTimerPane } from '../components/study/ReadingTimerPane'
import { ReadingDiagnosisPane } from '../components/study/ReadingDiagnosisPane'
import { OnboardingGuidePane } from '../components/study/OnboardingGuidePane'
import { AuthService } from '../services/AuthService'
import { NoteStore } from '../services/NoteStore'
import { StudyStore } from '../services/StudyStore'
import { DetailNavStack } from '../services/DetailNavStack'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'book'
    t0.label = '书房'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'grid'
    t1.label = '书架'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'add'
    t2.label = '添加'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '成长'
    tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State reloadToken: number = 0
  @State showSettings: boolean = false
  @State detailId: string = ''
  @State editId: string = ''
  @State subPage: string = ''
  @State subId: string = ''
  @State captureBookName: string = ''
  @State timerBookId: string = ''
  @State timerBookTitle: string = ''
  @State showOnboarding: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '承德锐泓科技有限公司'
  @Prop appName: string = '纸上方'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    const host = this.getUIContext().getHostContext()
    if (host) {
      void NoteStore.init(host as common.UIAbilityContext)
      void StudyStore.init(host as common.UIAbilityContext).then((): void => {
        void StudyStore.isOnboardingDone().then((done: boolean): void => {
          if (!done) {
            this.showOnboarding = true
            this.syncBar()
          }
        })
      })
    }
  }

  private bump(): void {
    this.reloadToken++
    this.syncBar()
  }

  private hasOverlay(): boolean {
    return this.showSettings || this.showOnboarding || this.detailId.length > 0 ||
      this.editId.length > 0 || this.subPage.length > 0
  }

  private syncBar(): void {
    AppStorage.setOrCreate('tabBarHidden', this.hasOverlay())
  }

  private openDetail(id: string): void {
    this.editId = ''
    DetailNavStack.push(id)
    this.detailId = id
    this.syncBar()
  }

  private openRelatedDetail(id: string): void {
    DetailNavStack.push(id)
    this.detailId = id
    this.syncBar()
  }

  private closeDetail(): void {
    if (DetailNavStack.canBack()) {
      DetailNavStack.pop()
      this.detailId = DetailNavStack.current()
    } else {
      DetailNavStack.clear()
      this.detailId = ''
    }
    this.syncBar()
  }

  private openEdit(id: string): void {
    this.detailId = id
    this.editId = id
    this.syncBar()
  }

  private openSub(page: string, id: string = ''): void {
    this.subPage = page
    this.subId = id
    this.syncBar()
  }

  private closeSub(): void {
    this.subPage = ''
    this.subId = ''
    this.syncBar()
  }

  private goCapture(bookName: string = ''): void {
    this.captureBookName = bookName
    this.current = 2
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private switchTab(index: number): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.current = index
    this.bump()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            reloadToken: this.reloadToken,
            active: true,
            onOpenSettings: (): void => {
              this.showSettings = true
              this.syncBar()
            },
            onOpenDetail: (id: string): void => { this.openDetail(id) },
            onGoCapture: (): void => { this.goCapture() },
            onDataChanged: (): void => { this.bump() },
            onOpenPlans: (): void => { this.openSub('plans') },
            onOpenTopics: (): void => { this.openSub('topics') },
            onOpenStats: (): void => { this.openSub('stats') },
            onOpenPlan: (id: string): void => { this.openSub('planDetail', id) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          BookShelfPage({
            reloadToken: this.reloadToken,
            active: true,
            onOpenBook: (id: string): void => { this.openSub('bookDetail', id) },
            onCreateBook: (): void => { this.openSub('bookEdit', '') },
            onOpenTimer: (): void => { this.openSub('timer') },
            onOpenDiagnosis: (): void => { this.openSub('diagnosis') }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          CapturePage({
            recordId: '',
            defaultBookName: this.captureBookName,
            asOverlay: false,
            reloadToken: this.reloadToken,
            onSaved: (): void => {
              void StudyStore.syncFromNotes()
              this.captureBookName = ''
              this.bump()
              this.current = 0
            },
            onRequireAuth: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else {
          ReviewPage({
            reloadToken: this.reloadToken,
            active: true,
            onOpenDetail: (id: string): void => { this.openDetail(id) },
            onGoCapture: (): void => { this.goCapture() },
            onOpenTimeline: (): void => { this.openSub('timeline') },
            onOpenStats: (): void => { this.openSub('stats') },
            onOpenAchievements: (): void => { this.openSub('achievements') },
            onOpenWeekly: (): void => { this.openSub('weekly') },
            onOpenPlans: (): void => { this.openSub('plans') },
            onOpenDiagnosis: (): void => { this.openSub('diagnosis') },
            onOpenTimer: (): void => { this.openSub('timer') }
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
          .padding({ left: 8, right: 8, bottom: 6 })
          .margin({ left: 12, right: 12, bottom: 10 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({
            radius: 16,
            color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(44,62,107,0.12)',
            offsetX: 0,
            offsetY: 4
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSettings) {
        MinePage({
          appName: this.appName,
          reloadToken: this.reloadToken,
          onOpenLogin: (): void => { this.onOpenLogin() },
          onLogout: (): void => {
            void AuthService.logout()
            this.onLogout()
          },
          onClose: (): void => {
            this.showSettings = false
            this.syncBar()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'plans') {
        ReadingPlanListPane({
          onClose: (): void => { this.closeSub() },
          onCreatePlan: (): void => { this.openSub('planEdit', '') },
          onOpenPlan: (id: string): void => { this.openSub('planDetail', id) }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'planEdit') {
        ReadingPlanEditorPane({
          planId: this.subId,
          onClose: (): void => { this.closeSub() },
          onSaved: (): void => {
            void StudyStore.syncFromNotes()
            this.bump()
            this.closeSub()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'planDetail') {
        ReadingPlanDetailPane({
          planId: this.subId,
          onClose: (): void => { this.closeSub() },
          onEdit: (): void => { this.openSub('planEdit', this.subId) },
          onOpenDetail: (id: string): void => { this.openDetail(id) }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'topics') {
        TopicListPane({
          onClose: (): void => { this.closeSub() },
          onCreateTopic: (): void => { this.openSub('topicEdit', '') },
          onOpenTopic: (id: string): void => { this.openSub('topicDetail', id) }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'topicEdit') {
        TopicEditorPane({
          topicId: this.subId,
          onClose: (): void => { this.closeSub() },
          onSaved: (): void => {
            this.bump()
            if (this.subId.length > 0) {
              this.openSub('topicDetail', this.subId)
            } else {
              this.closeSub()
            }
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'topicDetail') {
        TopicDetailPane({
          topicId: this.subId,
          onClose: (): void => { this.closeSub() },
          onEdit: (): void => { this.openSub('topicEdit', this.subId) },
          onOpenDetail: (id: string): void => { this.openDetail(id) }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'stats') {
        StatsCenterPane({
          onClose: (): void => { this.closeSub() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'timeline') {
        FullTimelinePane({
          onClose: (): void => { this.closeSub() },
          onOpenDetail: (id: string): void => { this.openDetail(id) }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'achievements') {
        AchievementWallPane({
          onClose: (): void => { this.closeSub() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'weekly') {
        WeeklyRecapPane({
          onClose: (): void => { this.closeSub() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'bookEdit') {
        BookLibraryEditorPane({
          bookId: this.subId,
          onClose: (): void => { this.closeSub() },
          onSaved: (id: string): void => {
            void StudyStore.syncFromNotes()
            this.bump()
            this.openSub('bookDetail', id)
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'bookDetail') {
        BookLibraryDetailPane({
          bookId: this.subId,
          onClose: (): void => { this.closeSub() },
          onEdit: (): void => { this.openSub('bookEdit', this.subId) },
          onOpenDetail: (id: string): void => { this.openDetail(id) },
          onStartTimer: (bookId: string, title: string): void => {
            this.timerBookId = bookId
            this.timerBookTitle = title
            this.openSub('timer')
          },
          onAddExcerpt: (title: string): void => {
            this.closeSub()
            this.goCapture(title)
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'timer') {
        ReadingTimerPane({
          presetBookId: this.timerBookId,
          presetBookTitle: this.timerBookTitle,
          onClose: (): void => {
            this.timerBookId = ''
            this.timerBookTitle = ''
            this.closeSub()
          },
          onDone: (): void => {
            this.timerBookId = ''
            this.timerBookTitle = ''
            void StudyStore.syncFromNotes()
            this.bump()
            this.closeSub()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.subPage === 'diagnosis') {
        ReadingDiagnosisPane({
          onClose: (): void => { this.closeSub() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showOnboarding) {
        OnboardingGuidePane({
          onFinish: (): void => {
            this.showOnboarding = false
            this.syncBar()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.detailId.length > 0) {
        NoteDetailPane({
          noteId: this.detailId,
          reloadToken: this.reloadToken,
          onClose: (): void => { this.closeDetail() },
          onChanged: (): void => {
            void StudyStore.syncFromNotes()
            this.bump()
          },
          onEdit: (id: string): void => { this.openEdit(id) },
          onOpenRelated: (id: string): void => { this.openRelatedDetail(id) },
          onOpenTopics: (): void => { this.openSub('topics') }
        })
          .width('100%')
          .height('100%')
      }

      if (this.editId.length > 0) {
        CapturePage({
          recordId: this.editId,
          asOverlay: true,
          reloadToken: this.reloadToken,
          onClose: (): void => {
            this.editId = ''
            this.syncBar()
          },
          onSaved: (): void => {
            this.editId = ''
            void StudyStore.syncFromNotes()
            this.bump()
            this.syncBar()
          },
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
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
    .onClick((): void => { this.switchTab(t.index) })
  }
}
