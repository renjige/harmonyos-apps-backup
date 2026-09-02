import { Theme } from '../components/design-system/Theme'
import { AppToast } from '../components/wanxiang/AppToast'
import { InfoDetailPane } from '../components/detail/InfoDetailPane'
import { UserKnowledgeDetailPane } from '../components/detail/UserKnowledgeDetailPane'
import { ContentEditorOverlay } from '../components/wanxiang/ContentEditorOverlay'
import { MainTabPage } from './MainTabPage'
import { SearchPage } from './SearchPage'
import { InfoItem } from '../models/InfoModels'
import { UserKnowledge } from '../models/UserKnowledgeModels'
import { InfoRepository } from '../services/InfoRepository'
import { UserDataStore } from '../services/UserDataStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { WanXiangDetailNav } from '../services/WanXiangDetailNav'
import { LocalPrefs } from '../services/LocalPrefs'
import { WanXiangNav } from '../services/WanXiangNav'
import { KnowledgeStore } from '../services/KnowledgeStore'
import { PlanStore } from '../services/PlanStore'
import { DailyTaskStore } from '../services/DailyTaskStore'
import { TopicProgressStore } from '../services/TopicProgressStore'
import { CheckInStore } from '../services/CheckInStore'
import { TimelineService } from '../services/TimelineService'
import { AchievementService } from '../services/AchievementService'
import { ReviewStore } from '../services/ReviewStore'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('wanxiangDetailId') @Watch('onDetailIdChange') detailId: string = ''
  @StorageLink('wanxiangKnowledgeId') @Watch('onKnowledgeIdChange') knowledgeId: string = ''
  @StorageLink('wanxiangSearchOpen') searchOpen: boolean = false
  @StorageLink('wanxiangEditorKind') editorKind: string = ''
  @StorageLink('wanxiangEditorId') editorId: string = ''
  @State refreshToken: number = 0
  @State detailItem: InfoItem | undefined = undefined
  @State knowledgeItem: UserKnowledge | undefined = undefined
  @State detailFavorited: boolean = false
  @State detailReadLater: boolean = false
  @State toastMessage: string = ''
  @State toastVisible: boolean = false
  @State toastSuccess: boolean = true

  aboutToAppear(): void {
    AppStorage.setOrCreate('wanxiangTabIndex', 0)
    AppStorage.setOrCreate('wanxiangSearchOpen', false)
    AppStorage.setOrCreate('wanxiangKnowledgeId', '')
    AppStorage.setOrCreate('wanxiangEditorKind', '')
    AppStorage.setOrCreate('wanxiangEditorId', '')
    AppStorage.setOrCreate('wanxiangStoreReady', false)
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      await UserDataStore.init(ctx)
      await LocalPrefs.init(ctx)
      await ReviewStore.ensureInitialQueue()
      const mode = await UserDataStore.getThemeMode()
      AppStorage.setOrCreate('colorMode', mode)
      ThemeAppearance.applyStored(ctx)
    }
    this.onDetailIdChange()
    this.onKnowledgeIdChange()
  }

  private bumpRefresh(): void {
    this.refreshToken++
  }

  private async afterUserAction(): Promise<void> {
    const unlocked = await AchievementService.checkAll()
    if (unlocked.length > 0) {
      const def = AchievementService.defById(unlocked[unlocked.length - 1])
      if (def !== undefined) {
        this.showToast(`解锁成就：${def.title}`)
      }
    }
    this.bumpRefresh()
  }

  private onDetailIdChange(): void {
    if (this.detailId.length === 0) {
      this.detailItem = undefined
      if (this.knowledgeId.length === 0 && !this.searchOpen && this.editorKind.length === 0) {
        AppStorage.setOrCreate('tabBarHidden', false)
      }
      return
    }
    const item = InfoRepository.findById(this.detailId)
    this.detailItem = item
    AppStorage.setOrCreate('tabBarHidden', item !== undefined)
    if (item !== undefined) {
      void this.onArticleOpened(item)
      void UserDataStore.isFavorite(item.id).then((fav: boolean) => {
        this.detailFavorited = fav
      })
      void UserDataStore.isReadLater(item.id).then((later: boolean) => {
        this.detailReadLater = later
      })
    }
  }

  private async onArticleOpened(item: InfoItem): Promise<void> {
    await UserDataStore.recordRead(item.id)
    await CheckInStore.recordTodayRead()
    await PlanStore.markRead(item.id)
    await DailyTaskStore.markRead()
    const topics = InfoRepository.topicCollections()
    for (const t of topics) {
      if (t.itemIds.indexOf(item.id) >= 0) {
        await TopicProgressStore.markRead(t.id, item.id)
      }
    }
    await TimelineService.log('read', `阅读「${item.title}」`, item.id)
    await this.afterUserAction()
  }

  private onKnowledgeIdChange(): void {
    if (this.knowledgeId.length === 0) {
      this.knowledgeItem = undefined
      return
    }
    void KnowledgeStore.findById(this.knowledgeId).then((k: UserKnowledge | undefined) => {
      this.knowledgeItem = k
      AppStorage.setOrCreate('tabBarHidden', k !== undefined)
    })
  }

  private showToast(message: string, success: boolean = true): void {
    this.toastMessage = message
    this.toastSuccess = success
    this.toastVisible = true
    setTimeout((): void => {
      this.toastVisible = false
    }, 2600)
  }

  private async toggleFavorite(): Promise<void> {
    if (this.detailItem === undefined) {
      return
    }
    const added = await UserDataStore.toggleFavorite(this.detailItem.id)
    this.detailFavorited = added
    if (added) {
      await TimelineService.log('favorite', `收藏「${this.detailItem.title}」`, this.detailItem.id)
      this.showToast('已加入收藏')
    } else {
      this.showToast('已取消收藏')
    }
    await this.afterUserAction()
  }

  private async toggleReadLater(): Promise<void> {
    if (this.detailItem === undefined) {
      return
    }
    const added = await UserDataStore.toggleReadLater(this.detailItem.id)
    this.detailReadLater = added
    if (added) {
      await ReviewStore.addInfo(this.detailItem.id)
      this.showToast('已加入稍后再读与复习队列')
    } else {
      this.showToast('已从稍后再读移除')
    }
    await this.afterUserAction()
  }

  private async convertToKnowledge(): Promise<void> {
    if (this.detailItem === undefined) {
      return
    }
    const k = await KnowledgeStore.fromFeatured(
      this.detailItem.id,
      this.detailItem.title,
      this.detailItem.summary,
      this.detailItem.body
    )
    await DailyTaskStore.markRecord()
    this.showToast('已转为我的知识')
    await this.afterUserAction()
    WanXiangNav.openKnowledge(k.id)
  }

  private async addToReview(): Promise<void> {
    if (this.detailItem === undefined) {
      return
    }
    const added = await ReviewStore.addInfo(this.detailItem.id)
    if (added) {
      this.showToast('已加入复习队列')
    } else {
      this.showToast('已在复习队列中')
    }
    await this.afterUserAction()
  }

  build() {
    Stack() {
      MainTabPage({
        refreshToken: this.refreshToken,
        onDataChanged: (): void => {
          this.bumpRefresh()
        }
      })
        .width('100%')
        .height('100%')

      if (this.searchOpen) {
        Column() {
          Row() {
            Blank()
            Text('关闭')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .padding(Theme.space.pageX)
              .onClick((): void => WanXiangNav.closeSearch())
          }
          .width('100%')
          SearchPage({
            refreshToken: this.refreshToken,
            bottomInset: Theme.space.s8
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
        .zIndex(28)
      }

      if (this.detailItem !== undefined && this.detailItem.id.length > 0) {
        InfoDetailPane({
          item: this.detailItem,
          favorited: this.detailFavorited,
          readLater: this.detailReadLater,
          onClose: (): void => {
            WanXiangDetailNav.close()
          },
          onToggleFavorite: (): void => { void this.toggleFavorite() },
          onToggleReadLater: (): void => { void this.toggleReadLater() },
          onShowToast: (msg: string): void => this.showToast(msg),
          onOpenRelated: (id: string): void => {
            WanXiangDetailNav.open(id)
          },
          onConvertKnowledge: (): void => { void this.convertToKnowledge() },
          onAddReview: (): void => { void this.addToReview() }
        })
          .width('100%')
          .height('100%')
          .zIndex(30)
      }

      if (this.knowledgeItem !== undefined && this.knowledgeItem.id.length > 0) {
        UserKnowledgeDetailPane({
          item: this.knowledgeItem,
          onClose: (): void => WanXiangNav.closeKnowledge(),
          onDataChanged: (): void => { void this.afterUserAction() },
          onShowToast: (msg: string): void => this.showToast(msg)
        })
          .width('100%')
          .height('100%')
          .zIndex(31)
      }

      if (this.editorKind.length > 0) {
        ContentEditorOverlay({
          editorKind: this.editorKind,
          editId: this.editorId,
          onSaved: (): void => { void this.afterUserAction() },
          onShowToast: (msg: string): void => this.showToast(msg)
        })
      }

      AppToast({
        message: this.toastMessage,
        visible: this.toastVisible,
        success: this.toastSuccess
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
