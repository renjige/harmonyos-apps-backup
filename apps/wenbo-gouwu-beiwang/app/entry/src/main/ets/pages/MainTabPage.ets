import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ListsHubPage } from './ListsHubPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { AddItemSheet } from '../components/shop/AddItemSheet'
import { CreateListSheet } from '../components/shop/CreateListSheet'
import { ListDetailOverlay } from '../components/shop/ListDetailOverlay'
import { TemplateDetailOverlay } from '../components/shop/TemplateDetailOverlay'
import { MemoFormOverlay } from '../components/shop/MemoFormOverlay'
import { ReminderSheet } from '../components/shop/ReminderSheet'
import { ChecklistVerifyOverlay } from '../components/shop/ChecklistVerifyOverlay'
import { ShoppingHabitOverlay } from '../components/shop/ShoppingHabitOverlay'
import { AisleRouteOverlay } from '../components/shop/AisleRouteOverlay'
import { LibraryOverlay } from '../components/shop/LibraryOverlay'
import { HistoryOverlay } from '../components/shop/HistoryOverlay'
import { SpendStatsOverlay } from '../components/shop/SpendStatsOverlay'
import { SearchOverlay } from '../components/shop/SearchOverlay'
import { ItemDetailOverlay } from '../components/shop/ItemDetailOverlay'
import { PlanEditorOverlay } from '../components/shop/PlanEditorOverlay'
import { FavoritesOverlay } from '../components/shop/FavoritesOverlay'
import { TopicsOverlay } from '../components/shop/TopicsOverlay'
import { TopicDetailOverlay } from '../components/shop/TopicDetailOverlay'
import { CategoryInsightOverlay } from '../components/shop/CategoryInsightOverlay'
import { ProcurementCalendarOverlay } from '../components/shop/ProcurementCalendarOverlay'
import { MonthlyReviewOverlay } from '../components/shop/MonthlyReviewOverlay'
import { AssigneeBoardOverlay } from '../components/shop/AssigneeBoardOverlay'
import { MessagesPage } from './MessagesPage'
import { ShoppingMemoNote, ShoppingTemplate, FrequentItem } from '../models/ShoppingModels'
import { SceneCard } from '../components/shop/SceneWorkbench'
import { BrandIdentity } from '../config/BrandIdentity'
import { ShoppingService } from '../services/ShoppingService'
import { ShoppingLocalStore } from '../services/ShoppingLocalStore'
import { ShoppingNotifyService } from '../services/ShoppingNotifyService'
import { ShareHelper } from '../services/ShareHelper'
import { GrowthService } from '../services/GrowthService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '首页'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '采购'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'chart'; t2.label = '成长'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'user'; t3.label = '我的'; tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showDetail: boolean = false
  @State showAdd: boolean = false
  @State showCreate: boolean = false
  @State showTemplate: boolean = false
  @State showMemo: boolean = false
  @State showRemind: boolean = false
  @State showVerify: boolean = false
  @State showHabit: boolean = false
  @State showAisle: boolean = false
  @State showLibrary: boolean = false
  @State showHistory: boolean = false
  @State showSpend: boolean = false
  @State showMessages: boolean = false
  @State showSearch: boolean = false
  @State showItemDetail: boolean = false
  @State showPlanEditor: boolean = false
  @State showFavorites: boolean = false
  @State showTopics: boolean = false
  @State showTopicDetail: boolean = false
  @State showCategoryInsight: boolean = false
  @State showCalendar: boolean = false
  @State showMonthlyReview: boolean = false
  @State showAssigneeBoard: boolean = false
  @State unlockedBadgeCount: number = 0
  @State activeItemId: string = ''
  @State activeItemListId: string = ''
  @State activeTopicId: string = ''
  @State activeListId: string = ''
  @State remain: number = 0
  @State template: ShoppingTemplate = new ShoppingTemplate()
  @State memo: ShoppingMemoNote = new ShoppingMemoNote()
  @State memoIsNew: boolean = true
  @State toastText: string = ''
  @State homeTick: number = 0
  @State addSheetToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop appName: string = BrandIdentity.appName()
  @Prop @Watch('onSessionTick') sessionTick: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private bump(): void {
    this.homeTick += 1
  }

  private notifyDataChange(): void {
    let unlocked = 0
    for (const b of GrowthService.badges()) {
      if (b.unlockedAt.length > 0) {
        unlocked += 1
      }
    }
    if (unlocked > this.unlockedBadgeCount && this.unlockedBadgeCount > 0) {
      for (const b of GrowthService.badges()) {
        if (b.unlockedAt.length > 0 && b.progress >= b.target) {
          this.toast(`成就解锁：${b.title}`)
          break
        }
      }
    }
    this.unlockedBadgeCount = unlocked
    this.bump()
  }

  private async shareList(text: string): Promise<void> {
    const ok = await ShareHelper.copyText(text)
    if (ok) {
      this.toast('清单已复制到剪贴板，可直接粘贴分享')
      return
    }
    this.toast('复制失败，请稍后重试')
  }

  onSessionTick(): void {
    this.bump()
  }

  private openList(id: string): void {
    this.activeListId = id
    this.showDetail = true
    this.hideBar(true)
  }

  private openItem(itemId: string, listId: string): void {
    this.activeItemId = itemId
    this.activeItemListId = listId
    this.showItemDetail = true
    this.hideBar(true)
  }

  private openTopic(id: string): void {
    this.activeTopicId = id
    this.showTopicDetail = true
    this.showTopics = false
    this.hideBar(true)
  }

  private async startAdd(): Promise<void> {
    const list = await ShoppingService.ensureTodayList()
    this.activeListId = list.id
    this.addSheetToken += 1
    this.showAdd = true
    this.hideBar(true)
  }

  private async addFrequent(item: FrequentItem): Promise<void> {
    const list = await ShoppingService.ensureTodayList()
    this.activeListId = list.id
    await ShoppingService.addItem(list.id, item.title, item.category, item.qty, item.remark, item.estPrice, '')
    this.toast(`已加入：${item.title}`)
    this.bump()
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          HomePage({
            refreshToken: this.homeTick,
            onAddItem: () => { void this.startAdd() },
            onOpenList: (id: string) => this.openList(id),
            onCreateList: () => { this.showCreate = true; this.hideBar(true) },
            onOpenLists: () => { this.current = 1 },
            onAddFrequent: (item: FrequentItem): void => {
              void this.addFrequent(item)
            },
            onOpenVerify: (): void => {
              this.showVerify = true
              this.hideBar(true)
            },
            onOpenHabit: (): void => {
              this.showHabit = true
              this.hideBar(true)
            },
            onOpenAisle: (): void => {
              this.showAisle = true
              this.hideBar(true)
            },
            onOpenLibrary: (): void => {
              this.showLibrary = true
              this.hideBar(true)
            },
            onOpenHistory: (): void => {
              this.showHistory = true
              this.hideBar(true)
            },
            onOpenSpend: (): void => {
              this.showSpend = true
              this.hideBar(true)
            },
            onOpenTemplates: (): void => { this.current = 1 },
            onOpenSearch: (): void => {
              this.showSearch = true
              this.hideBar(true)
            },
            onOpenGrowth: (): void => {
              this.current = 2
              this.bump()
            },
            onOpenFavorites: (): void => {
              this.showFavorites = true
              this.hideBar(true)
            },
            onOpenTopics: (): void => {
              this.showTopics = true
              this.hideBar(true)
            },
            onOpenPlanEditor: (): void => {
              this.showPlanEditor = true
              this.hideBar(true)
            },
            onOpenCategoryInsight: (): void => {
              this.showCategoryInsight = true
              this.hideBar(true)
            },
            onOpenCalendar: (): void => {
              this.showCalendar = true
              this.hideBar(true)
            },
            onOpenMonthlyReview: (): void => {
              this.showMonthlyReview = true
              this.hideBar(true)
            },
            onOpenAssigneeBoard: (): void => {
              this.showAssigneeBoard = true
              this.hideBar(true)
            },
            onOpenItem: (itemId: string, listId: string): void => {
              this.openItem(itemId, listId)
            },
            onOpenTopic: (id: string): void => {
              this.openTopic(id)
            },
            onQuickScene: (card: SceneCard): void => {
              void ShoppingService.createList(card.title, ShoppingLocalStore.today(), card.coverKey, card.templateId, card.kind).then((row) => {
                this.openList(row.id)
                this.toast('情景清单已就绪')
                this.bump()
              })
            },
            onDataChange: (): void => { this.notifyDataChange() }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.Hidden)
          if (this.current === 1) {
            ListsHubPage({
              refreshToken: this.homeTick,
              onOpenList: (id: string) => this.openList(id),
              onCreateList: () => { this.showCreate = true; this.hideBar(true) },
              onOpenTemplate: (tpl: ShoppingTemplate) => {
                this.template = tpl
                this.showTemplate = true
                this.hideBar(true)
              },
              onCreateMemo: (): void => {
                this.memo = new ShoppingMemoNote()
                this.memoIsNew = true
                this.showMemo = true
                this.hideBar(true)
              },
              onOpenMemo: (note: ShoppingMemoNote): void => {
                this.memo = ShoppingService.cloneMemoForEdit(note)
                this.memoIsNew = false
                this.showMemo = true
                this.hideBar(true)
              },
              onQuickScene: (card: SceneCard): void => {
                void ShoppingService.createList(card.title, ShoppingLocalStore.today(), card.coverKey, card.templateId, card.kind).then((row) => {
                  this.openList(row.id)
                  this.toast('情景清单已就绪')
                  this.bump()
                })
              }
            })
              .width('100%')
              .height('100%')
          } else if (this.current === 2) {
            GrowthPage({
              refreshToken: this.homeTick,
              onOpenPlanEditor: (): void => {
                this.showPlanEditor = true
                this.hideBar(true)
              },
              onOpenTopics: (): void => {
                this.showTopics = true
                this.hideBar(true)
              },
              onOpenList: (id: string): void => { this.openList(id) },
              onOpenItem: (itemId: string, listId: string): void => { this.openItem(itemId, listId) },
              onOpenTopic: (id: string): void => { this.openTopic(id) },
              onOpenCalendar: (): void => {
                this.showCalendar = true
                this.hideBar(true)
              },
              onOpenMonthlyReview: (): void => {
                this.showMonthlyReview = true
                this.hideBar(true)
              }
            })
              .width('100%')
              .height('100%')
          } else if (this.current === 3) {
            MinePage({
              appName: this.appName,
              refreshToken: this.homeTick,
              onOpenLogin: () => this.onOpenLogin(),
              onLogout: () => this.onLogout(),
              onOpenLists: () => { this.current = 1 },
              onOpenTemplates: () => { this.current = 1 },
              onOpenVerify: (): void => {
                this.showVerify = true
                this.hideBar(true)
              },
              onOpenHabit: (): void => {
                this.showHabit = true
                this.hideBar(true)
              },
              onOpenAisle: (): void => {
                this.showAisle = true
                this.hideBar(true)
              },
              onOpenLibrary: (): void => {
                this.showLibrary = true
                this.hideBar(true)
              },
              onOpenHistory: (): void => {
                this.showHistory = true
                this.hideBar(true)
              },
              onOpenSpend: (): void => {
                this.showSpend = true
                this.hideBar(true)
              },
              onOpenMessages: (): void => {
                this.showMessages = true
                this.hideBar(true)
              }
            })
              .width('100%')
              .height('100%')
          }
        }
        .layoutWeight(1)
        .width('100%')

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => { this.TabBarItem(t) }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showDetail) {
        ListDetailOverlay({
          listId: this.activeListId,
          refreshToken: this.homeTick,
          onClose: () => { this.showDetail = false; this.hideBar(false); this.bump() },
          onAddItem: () => { this.addSheetToken += 1; this.showAdd = true },
          onRemind: (): void => {
            void ShoppingService.items(this.activeListId).then((items) => {
              this.remain = items.length - ShoppingService.doneCount(items)
              this.showRemind = true
            })
          },
          onAisle: (): void => {
            this.showAisle = true
          },
          onDeleted: () => { this.showDetail = false; this.hideBar(false); this.toast('清单已删除'); this.bump() },
          onShare: (text: string): void => { void this.shareList(text) },
          onDataChange: (): void => { this.notifyDataChange() },
          onDuplicated: (id: string): void => {
            this.toast('已复制一份新清单')
            this.openList(id)
            this.bump()
          },
          onOpenItem: (itemId: string): void => { this.openItem(itemId, this.activeListId) }
        }).width('100%').height('100%').zIndex(10)
      }
      if (this.showAdd) {
        AddItemSheet({
          openToken: this.addSheetToken,
          onClose: () => { this.showAdd = false; this.hideBar(this.showDetail) },
          onConfirm: (name: string, qty: string, remark: string, category: string, estPrice: string, tag: string): void => {
            void ShoppingService.addItem(this.activeListId, name, category, qty, remark, estPrice, tag).then(() => {
              this.showAdd = false
              this.hideBar(this.showDetail)
              this.toast('已记下')
              this.notifyDataChange()
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showCreate) {
        CreateListSheet({
          onClose: () => { this.showCreate = false; this.hideBar(false) },
          onConfirm: (title: string, kind: string): void => {
            void ShoppingService.createList(title, ShoppingLocalStore.today(), '', '', kind).then((row) => {
              this.showCreate = false
              this.bump()
              this.openList(row.id)
              this.toast('清单已创建')
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showTemplate) {
        TemplateDetailOverlay({
          template: this.template,
          onClose: () => { this.showTemplate = false; this.hideBar(false) },
          onCreate: (): void => {
            void ShoppingService.createList(this.template.title, ShoppingLocalStore.today(), this.template.coverKey, this.template.id, this.template.subtitle).then((row) => {
              this.showTemplate = false
              this.bump()
              this.openList(row.id)
              this.toast('已用模板创建清单')
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showMemo) {
        MemoFormOverlay({
          note: this.memo,
          isNew: this.memoIsNew,
          onClose: (): void => { this.showMemo = false; this.hideBar(false) },
          onSave: (note: ShoppingMemoNote): void => {
            void ShoppingService.saveMemo(note, this.memoIsNew).then((ok: boolean) => {
              if (!ok) {
                this.toast('保存失败，请填写标题后重试')
                return
              }
              this.showMemo = false
              this.hideBar(false)
              this.toast('备忘已保存')
              this.bump()
            })
          },
          onDelete: (): void => {
            void ShoppingService.deleteMemo(this.memo.id).then((ok: boolean) => {
              if (!ok) {
                this.toast('删除失败，请重试')
                return
              }
              this.showMemo = false
              this.hideBar(false)
              this.toast('备忘已删除')
              this.bump()
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showRemind) {
        ReminderSheet({
          remain: this.remain,
          onClose: () => { this.showRemind = false },
          onConfirm: (whenText: string, message: string, cycle: string): void => {
            void ShoppingService.createReminder(message, this.activeListId, whenText, cycle).then((ok: boolean) => {
              this.showRemind = false
              if (!ok) {
                const err = ShoppingService.lastNotifyError()
                this.toast(err.length > 0 ? err : '提醒未保存，请稍后重试')
                return
              }
              this.toast('提醒已设置，到点会通知你')
              this.bump()
            })
          },
          onTest: (): void => {
            void ShoppingNotifyService.testRing().then((ok: boolean) => {
              const err = ShoppingService.lastNotifyError()
              if (!ok) {
                this.toast(err.length > 0 ? err : '试响失败，请允许通知与发布提醒')
                return
              }
              this.toast('已立即通知，1 分钟后会再提醒一次')
            })
          }
        }).width('100%').height('100%').zIndex(18)
      }
      if (this.showVerify) {
        ChecklistVerifyOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showVerify = false
            this.hideBar(false)
            this.bump()
          },
          onDataChange: (): void => { this.notifyDataChange() }
        }).width('100%').height('100%').zIndex(14)
      }
      if (this.showHabit) {
        ShoppingHabitOverlay({
          onClose: (): void => {
            this.showHabit = false
            this.hideBar(false)
          }
        }).width('100%').height('100%').zIndex(14)
      }
      if (this.showAisle) {
        AisleRouteOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showAisle = false
            this.hideBar(this.showDetail)
            this.bump()
          }
        }).width('100%').height('100%').zIndex(14)
      }
      if (this.showLibrary) {
        LibraryOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showLibrary = false
            this.hideBar(false)
            this.bump()
          },
          onAdd: (item: FrequentItem): void => {
            void this.addFrequent(item)
            this.toast(`已加入：${item.title}`)
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showHistory) {
        HistoryOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showHistory = false
            this.hideBar(false)
            this.bump()
          },
          onOpen: (id: string): void => {
            this.showHistory = false
            this.openList(id)
          },
          onReuse: (id: string): void => {
            void ShoppingService.duplicateList(id).then((row) => {
              if (row !== undefined) {
                this.showHistory = false
                this.toast('已重新创建清单')
                this.openList(row.id)
                this.bump()
              }
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showSpend) {
        SpendStatsOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showSpend = false
            this.hideBar(false)
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showMessages) {
        MessagesPage({
          showBack: true,
          onClose: (): void => {
            this.showMessages = false
            this.hideBar(false)
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showSearch) {
        SearchOverlay({
          onClose: (): void => {
            this.showSearch = false
            this.hideBar(false)
          },
          onOpenList: (id: string): void => {
            this.showSearch = false
            this.openList(id)
          },
          onOpenMemo: (id: string): void => {
            void ShoppingService.findMemo(id).then((note) => {
              if (note === undefined) {
                return
              }
              this.showSearch = false
              this.memo = ShoppingService.cloneMemoForEdit(note)
              this.memoIsNew = false
              this.showMemo = true
              this.hideBar(true)
            })
          },
          onOpenItem: (itemId: string, listId: string): void => {
            this.showSearch = false
            this.openItem(itemId, listId)
          },
          onOpenTopic: (id: string): void => {
            this.showSearch = false
            this.openTopic(id)
          },
          onAddLibrary: (title: string): void => {
            const row = new FrequentItem()
            row.title = title
            void this.addFrequent(row)
            this.toast(`已加入今日清单：${title}`)
          }
        }).width('100%').height('100%').zIndex(17)
      }
      if (this.showItemDetail) {
        ItemDetailOverlay({
          itemId: this.activeItemId,
          listId: this.activeItemListId,
          onClose: (): void => {
            this.showItemDetail = false
            this.hideBar(false)
            this.bump()
          },
          onOpenList: (id: string): void => {
            this.showItemDetail = false
            this.openList(id)
          },
          onDataChange: (): void => { this.notifyDataChange() }
        }).width('100%').height('100%').zIndex(18)
      }
      if (this.showPlanEditor) {
        PlanEditorOverlay({
          onClose: (): void => {
            this.showPlanEditor = false
            this.hideBar(false)
          },
          onSaved: (): void => { this.bump() }
        }).width('100%').height('100%').zIndex(19)
      }
      if (this.showFavorites) {
        FavoritesOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showFavorites = false
            this.hideBar(false)
          },
          onOpenList: (id: string): void => {
            this.showFavorites = false
            this.openList(id)
          },
          onOpenItem: (itemId: string, listId: string): void => {
            this.showFavorites = false
            this.openItem(itemId, listId)
          },
          onOpenMemo: (id: string): void => {
            void ShoppingService.findMemo(id).then((note) => {
              if (note === undefined) {
                return
              }
              this.showFavorites = false
              this.memo = ShoppingService.cloneMemoForEdit(note)
              this.memoIsNew = false
              this.showMemo = true
              this.hideBar(true)
            })
          }
        }).width('100%').height('100%').zIndex(19)
      }
      if (this.showTopics) {
        TopicsOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showTopics = false
            this.hideBar(false)
          },
          onOpenTopic: (id: string): void => { this.openTopic(id) },
          onChanged: (): void => { this.bump() }
        }).width('100%').height('100%').zIndex(19)
      }
      if (this.showTopicDetail) {
        TopicDetailOverlay({
          topicId: this.activeTopicId,
          onClose: (): void => {
            this.showTopicDetail = false
            this.hideBar(false)
            this.bump()
          },
          onOpenList: (id: string): void => {
            this.showTopicDetail = false
            this.openList(id)
          },
          onDeleted: (): void => { this.bump() }
        }).width('100%').height('100%').zIndex(20)
      }
      if (this.showCategoryInsight) {
        CategoryInsightOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showCategoryInsight = false
            this.hideBar(false)
          }
        }).width('100%').height('100%').zIndex(19)
      }
      if (this.showCalendar) {
        ProcurementCalendarOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showCalendar = false
            this.hideBar(false)
          }
        }).width('100%').height('100%').zIndex(19)
      }
      if (this.showMonthlyReview) {
        MonthlyReviewOverlay({
          onClose: (): void => {
            this.showMonthlyReview = false
            this.hideBar(false)
          }
        }).width('100%').height('100%').zIndex(19)
      }
      if (this.showAssigneeBoard) {
        AssigneeBoardOverlay({
          refreshToken: this.homeTick,
          onClose: (): void => {
            this.showAssigneeBoard = false
            this.hideBar(false)
          },
          onOpenItem: (itemId: string, listId: string): void => {
            this.showAssigneeBoard = false
            this.openItem(itemId, listId)
          }
        }).width('100%').height('100%').zIndex(19)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: Theme.space.pageX, y: Theme.space.s6 })
          .zIndex(30)
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
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick((): void => {
      this.hideBar(false)
      this.current = t.index
      this.bump()
    })
  }
}
