import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { StudyPage } from './StudyPage'
import { InsightPage } from './InsightPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { FocusTimerPane } from '../components/study/FocusTimerPane'
import { NoteEditorSheet } from '../components/study/NoteEditorSheet'
import { CardEditorSheet } from '../components/study/CardEditorSheet'
import { NoteDetailPane } from '../components/study/NoteDetailPane'
import { CardDetailPane } from '../components/study/CardDetailPane'
import { CatalogDetailPane } from '../components/study/CatalogDetailPane'
import { ReviewPane } from '../components/study/ReviewPane'
import { TodayLogPane } from '../components/study/TodayLogPane'
import { TaskBoardPane } from '../components/study/TaskBoardPane'
import { DayStudyPane } from '../components/study/DayStudyPane'
import { CategoryDetailPane } from '../components/study/CategoryDetailPane'
import { WeeklyPlanPane } from '../components/study/WeeklyPlanPane'
import { MessageDetailPane } from '../components/study/MessageDetailPane'
import { AuthService } from '../services/AuthService'
import { StudyBizService } from '../services/StudyBizService'
import { CatalogItem } from '../models/StudyModels'

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
    t1.name = 'book'
    t1.label = '学习'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '洞察'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @State current: number = 0
  @State reloadToken: number = 0
  @State showFocus: boolean = false
  @State showNoteEdit: boolean = false
  @State noteEditId: string = ''
  @State noteDetailId: string = ''
  @State showCardEdit: boolean = false
  @State cardEditId: string = ''
  @State cardDetailId: string = ''
  @State showReview: boolean = false
  @State showMessages: boolean = false
  @State showDiagnose: boolean = false
  @State showTodayLog: boolean = false
  @State showTasks: boolean = false
  @State catalogOpen: boolean = false
  @State catalogTitle: string = ''
  @State catalogBody: string = ''
  @State catalogSummary: string = ''
  @State catalogCover: string = 'hero_desk'
  @State catalogCategory: string = '方法'
  @State catalogKind: string = '智慧推荐'
  @State showDayStudy: boolean = false
  @State dayStudyKey: string = ''
  @State showCategory: boolean = false
  @State categoryTitle: string = ''
  @State categoryBody: string = ''
  @State categorySummary: string = ''
  @State categoryCover: string = 'texture_paper'
  @State showWeeklyPlan: boolean = false
  @State showMessageDetail: boolean = false
  @State messageTitle: string = ''
  @State messageBody: string = ''
  @State messageTime: string = ''
  @State cardDefaultCategory: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '学见'
  @Prop appName: string = '学见'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.reloadToken++
    this.syncBar()
  }

  private overlayOpen(): boolean {
    return this.showFocus || this.showNoteEdit || this.noteDetailId.length > 0 ||
      this.showCardEdit || this.cardDetailId.length > 0 || this.showReview ||
      this.showMessages || this.showMessageDetail || this.showDiagnose || this.catalogOpen ||
      this.showTodayLog || this.showTasks || this.showDayStudy || this.showCategory ||
      this.showWeeklyPlan
  }

  private openDay(dateKey: string): void {
    this.dayStudyKey = dateKey
    this.showDayStudy = true
    this.syncBar()
  }

  private openCategory(item: CatalogItem): void {
    this.categoryTitle = item.title
    this.categoryBody = item.body
    this.categorySummary = item.summary
    this.categoryCover = item.coverKey.length > 0 ? item.coverKey : 'texture_paper'
    this.showCategory = true
    this.syncBar()
  }

  private openWeeklyPlan(): void {
    this.showWeeklyPlan = true
    this.syncBar()
  }

  private handleDiagnoseAction(action: string): void {
    this.showDiagnose = false
    if (action === 'note') {
      this.noteEditId = ''
      this.showNoteEdit = true
    } else if (action === 'review') {
      this.showReview = true
    } else if (action === 'insight') {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = 2
    } else {
      this.openFocus()
    }
    this.syncBar()
  }

  private syncBar(): void {
    AppStorage.setOrCreate('tabBarHidden', this.overlayOpen())
  }

  private openFocus(): void {
    this.showFocus = true
    this.syncBar()
  }

  private async openMethod(id: string): Promise<void> {
    const found: CatalogItem | undefined = await StudyBizService.findMethod(id)
    if (found === undefined) {
      return
    }
    this.catalogTitle = found.title
    this.catalogBody = found.body
    this.catalogSummary = found.summary
    this.catalogCover = found.coverKey
    this.catalogCategory = found.category.length > 0 ? found.category : '方法'
    this.catalogKind = '专注方法'
    this.catalogOpen = true
    this.syncBar()
  }

  private async openTip(id: string): Promise<void> {
    const found: CatalogItem | undefined = await StudyBizService.findTip(id)
    if (found === undefined) {
      return
    }
    this.catalogTitle = found.title
    this.catalogBody = found.body
    this.catalogSummary = found.summary
    this.catalogCover = found.coverKey
    this.catalogCategory = found.category.length > 0 ? found.category : '锦囊'
    this.catalogKind = '学习锦囊'
    this.catalogOpen = true
    this.syncBar()
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          HomePage({
            reloadToken: this.reloadToken,
            onOpenFocus: (): void => { this.openFocus() },
            onOpenNote: (): void => {
              this.noteEditId = ''
              this.showNoteEdit = true
              this.syncBar()
            },
            onOpenReview: (): void => {
              this.showReview = true
              this.syncBar()
            },
            onOpenMethod: (id: string): void => { void this.openMethod(id) },
            onOpenMessages: (): void => {
              this.showMessages = true
              this.syncBar()
            },
            onOpenTasks: (): void => {
              this.showTasks = true
              this.syncBar()
            },
            onOpenToday: (): void => {
              this.showTodayLog = true
              this.syncBar()
            },
            onOpenInsight: (): void => {
              AppStorage.setOrCreate('tabBarHidden', false)
              this.current = 2
            },
            onOpenDay: (dateKey: string): void => { this.openDay(dateKey) },
            onOpenWeekly: (): void => { this.openWeeklyPlan() }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.Hidden)
          StudyPage({
            reloadToken: this.reloadToken,
            onOpenFocus: (): void => { this.openFocus() },
            onOpenNote: (id: string): void => {
              this.noteDetailId = id
              this.syncBar()
            },
            onNewNote: (): void => {
              this.noteEditId = ''
              this.showNoteEdit = true
              this.syncBar()
            },
            onOpenCard: (id: string): void => {
              this.cardDetailId = id
              this.syncBar()
            },
            onNewCard: (): void => {
              this.cardEditId = ''
              this.showCardEdit = true
              this.syncBar()
            },
            onOpenReview: (): void => {
              this.showReview = true
              this.syncBar()
            },
            onOpenCategory: (item: CatalogItem): void => { this.openCategory(item) }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 1 ? Visibility.Visible : Visibility.Hidden)
          InsightPage({
            reloadToken: this.reloadToken,
            onOpenTip: (id: string): void => { void this.openTip(id) },
            onOpenDiagnose: (): void => {
              this.showDiagnose = true
              this.syncBar()
            },
            onOpenDay: (dateKey: string): void => { this.openDay(dateKey) }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 2 ? Visibility.Visible : Visibility.Hidden)
          MinePage({
            appName: this.appName,
            reloadToken: this.reloadToken,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
            },
            onOpenToday: (): void => {
              this.showTodayLog = true
              this.syncBar()
            },
            onNewNote: (): void => {
              this.noteEditId = ''
              this.showNoteEdit = true
              this.syncBar()
            },
            onNewCard: (): void => {
              this.cardEditId = ''
              this.showCardEdit = true
              this.syncBar()
            },
            onOpenTasks: (): void => {
              this.showTasks = true
              this.syncBar()
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 3 ? Visibility.Visible : Visibility.Hidden)
        }
        .width('100%')
        .layoutWeight(1)

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
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({
            radius: 16,
            color: 'rgba(26,42,74,0.08)',
            offsetY: -2,
            offsetX: 0
          })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showFocus) {
        FocusTimerPane({
          onClose: (): void => {
            this.showFocus = false
            this.bump()
          },
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.showNoteEdit) {
        NoteEditorSheet({
          noteId: this.noteEditId,
          onClose: (): void => {
            this.showNoteEdit = false
            this.syncBar()
          },
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.noteDetailId.length > 0) {
        NoteDetailPane({
          noteId: this.noteDetailId,
          onClose: (): void => {
            this.noteDetailId = ''
            this.syncBar()
          },
          onChanged: (): void => { this.bump() },
          onEdit: (id: string): void => {
            this.noteDetailId = ''
            this.noteEditId = id
            this.showNoteEdit = true
            this.syncBar()
          }
        })
      }
      if (this.showCardEdit) {
        CardEditorSheet({
          cardId: this.cardEditId,
          defaultCategory: this.cardDefaultCategory,
          onClose: (): void => {
            this.showCardEdit = false
            this.cardDefaultCategory = ''
            this.syncBar()
          },
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.cardDetailId.length > 0) {
        CardDetailPane({
          cardId: this.cardDetailId,
          onClose: (): void => {
            this.cardDetailId = ''
            this.syncBar()
          },
          onChanged: (): void => { this.bump() },
          onEdit: (id: string): void => {
            this.cardDetailId = ''
            this.cardEditId = id
            this.showCardEdit = true
            this.syncBar()
          }
        })
      }
      if (this.showReview) {
        ReviewPane({
          onClose: (): void => {
            this.showReview = false
            this.syncBar()
          },
          onChanged: (): void => { this.bump() },
          onOpenCard: (id: string): void => {
            this.showReview = false
            this.cardDetailId = id
            this.syncBar()
          }
        })
      }
      if (this.catalogOpen) {
        CatalogDetailPane({
          itemTitle: this.catalogTitle,
          itemBody: this.catalogBody,
          itemSummary: this.catalogSummary,
          itemCover: this.catalogCover,
          itemCategory: this.catalogCategory,
          kindLabel: this.catalogKind,
          onClose: (): void => {
            this.catalogOpen = false
            this.syncBar()
          },
          onStartFocus: (): void => {
            this.catalogOpen = false
            this.openFocus()
          },
          onNewCard: (): void => {
            this.catalogOpen = false
            this.cardEditId = ''
            this.cardDefaultCategory = ''
            this.showCardEdit = true
            this.syncBar()
          },
          onOpenReview: (): void => {
            this.catalogOpen = false
            this.showReview = true
            this.syncBar()
          }
        })
      }
      if (this.showDayStudy) {
        DayStudyPane({
          dateKey: this.dayStudyKey,
          onClose: (): void => {
            this.showDayStudy = false
            this.syncBar()
          },
          onOpenNote: (id: string): void => {
            this.showDayStudy = false
            this.noteDetailId = id
            this.syncBar()
          },
          onOpenCard: (id: string): void => {
            this.showDayStudy = false
            this.cardDetailId = id
            this.syncBar()
          },
          onOpenFocus: (): void => {
            this.showDayStudy = false
            this.openFocus()
          }
        })
      }
      if (this.showCategory) {
        CategoryDetailPane({
          categoryTitle: this.categoryTitle,
          categoryBody: this.categoryBody,
          categorySummary: this.categorySummary,
          categoryCover: this.categoryCover,
          onClose: (): void => {
            this.showCategory = false
            this.syncBar()
          },
          onNewCard: (cat: string): void => {
            this.showCategory = false
            this.cardEditId = ''
            this.cardDefaultCategory = cat
            this.showCardEdit = true
            this.syncBar()
          },
          onOpenCard: (id: string): void => {
            this.showCategory = false
            this.cardDetailId = id
            this.syncBar()
          },
          onOpenReview: (): void => {
            this.showCategory = false
            this.showReview = true
            this.syncBar()
          },
          onOpenFocus: (): void => {
            this.showCategory = false
            this.openFocus()
          }
        })
      }
      if (this.showWeeklyPlan) {
        WeeklyPlanPane({
          onClose: (): void => {
            this.showWeeklyPlan = false
            this.bump()
          }
        })
      }
      if (this.showTodayLog) {
        TodayLogPane({
          onClose: (): void => {
            this.showTodayLog = false
            this.bump()
          },
          onChanged: (): void => { this.bump() },
          onOpenFocus: (): void => {
            this.showTodayLog = false
            this.openFocus()
          }
        })
      }
      if (this.showTasks) {
        TaskBoardPane({
          onClose: (): void => {
            this.showTasks = false
            this.bump()
          },
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.showMessages) {
        Column() {
          MessagesPage({
            onClose: (): void => {
              this.showMessages = false
              this.syncBar()
            },
            onOpenDetail: (title: string, body: string, time: string): void => {
              this.messageTitle = title
              this.messageBody = body
              this.messageTime = time
              this.showMessageDetail = true
              this.syncBar()
            }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
      }
      if (this.showMessageDetail) {
        MessageDetailPane({
          itemTitle: this.messageTitle,
          itemBody: this.messageBody,
          itemTime: this.messageTime,
          onClose: (): void => {
            this.showMessageDetail = false
            this.syncBar()
          }
        })
      }
      if (this.showDiagnose) {
        Column() {
          AIAssistantPage({
            onRequireAuth: (): void => { this.onRequireAuth() },
            onClose: (): void => {
              this.showDiagnose = false
              this.syncBar()
            },
            onBookFromAi: (action: string): void => { this.handleDiagnoseAction(action) }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? '#FFFFFF' : Theme.tabInactiveFg()
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? '#1A2A4A' : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(this.themeEpoch >= 0 ? t.label : t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          (Theme.isDark() ? '#FFFFFF' : '#0F172A') : Theme.tabInactiveFg())
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
