import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { NotebookPage } from './NotebookPage'
import { TrainingPage } from './TrainingPage'
import { DashboardPage } from './DashboardPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { CatalogDetailPane } from '../components/detail/CatalogDetailPane'
import { EntryDetailPane } from '../components/detail/EntryDetailPane'
import { CaptureOverlay } from '../components/wrong/CaptureOverlay'
import { CatalogItem, CatalogKind, WrongEntry, WrongEntryWrite } from '../models/WrongModels'
import { WrongBizService } from '../services/WrongBizService'
import { WrongDetailNav } from '../services/WrongDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '首页'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '错题本'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'refresh'; t2.label = '训练'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'user'; t3.label = '我的'; tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State homeTick: number = 0
  @State showMessages: boolean = false
  @State showReport: boolean = false
  @State toastText: string = ''
  @State subjects: CatalogItem[] = []
  @State methods: CatalogItem[] = []
  @State tips: CatalogItem[] = []
  @State articles: CatalogItem[] = []
  @State entries: WrongEntry[] = []
  @State detailItem: CatalogItem = new CatalogItem()
  @State detailEntry: WrongEntry = new WrongEntry()
  @State captureEntry: WrongEntry = new WrongEntry()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('wqDetailOpen') @Watch('onDetailFlag') detailOpen: boolean = false
  @StorageLink('wqCaptureOpen') @Watch('onCaptureFlag') captureOpen: boolean = false
  @StorageLink('wqDetailKind') detailKind: string = 'subject'
  @StorageLink('wqDetailId') detailId: string = ''
  @StorageLink('wqCaptureMode') captureMode: string = 'manual'
  @StorageLink('wqCaptureEditId') captureEditId: string = ''
  @Prop company: string = '知错智慧'
  @Prop appName: string = '知错·错题智慧训练'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    void this.reloadCatalog()
  }

  onDetailFlag(): void {
    if (this.detailOpen) {
      void this.openDetail()
    }
  }

  onCaptureFlag(): void {
    if (this.captureOpen) {
      this.applyCaptureEntry()
    }
  }

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private bump(): void {
    this.homeTick += 1
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reloadCatalog(): Promise<void> {
    this.subjects = await WrongBizService.loadSubjects()
    this.methods = await WrongBizService.loadMethods()
    this.tips = await WrongBizService.loadTips()
    this.articles = await WrongBizService.loadArticles()
    this.entries = await WrongBizService.loadEntries()
    this.bump()
  }

  private async openDetail(): Promise<void> {
    this.hideBar(true)
    if (this.detailKind === CatalogKind.ENTRY) {
      this.entries = await WrongBizService.loadEntries()
      this.detailEntry = WrongBizService.findEntry(this.detailId, this.entries)
      return
    }
    let list = this.subjects
    if (this.detailKind === CatalogKind.METHOD) {
      list = this.methods
    } else if (this.detailKind === CatalogKind.TIP) {
      list = this.tips
    } else if (this.detailKind === CatalogKind.ARTICLE) {
      list = this.articles
    }
    this.detailItem = WrongBizService.findCatalog(this.detailId, list)
  }

  private applyCaptureEntry(): void {
    this.hideBar(true)
    if (this.captureEditId.length > 0) {
      this.captureEntry = WrongBizService.findEntry(this.captureEditId, this.entries)
    } else {
      this.captureEntry = new WrongEntry()
    }
  }

  private closeOverlays(): void {
    WrongDetailNav.close()
    this.showMessages = false
    this.showReport = false
    this.hideBar(false)
  }

  private async handleSave(write: WrongEntryWrite, editId: string): Promise<void> {
    const ok = editId.length > 0 ?
      await WrongBizService.updateEntry(editId, write) :
      await WrongBizService.saveEntry(write)
    if (ok) {
      this.closeOverlays()
      await this.reloadCatalog()
      this.toast('已保存到错题本')
      return
    }
    this.toast(WrongBizService.lastError.length > 0 ? WrongBizService.lastError : '保存失败')
  }

  private async handleToggle(): Promise<void> {
    const write = new WrongEntryWrite()
    write.stem = this.detailEntry.stem
    write.correctAnswer = this.detailEntry.correctAnswer
    write.wrongAnswer = this.detailEntry.wrongAnswer
    write.subjectCode = this.detailEntry.subjectCode
    write.knowledgeTag = this.detailEntry.knowledgeTag
    write.causeCode = this.detailEntry.causeCode
    write.photoUri = this.detailEntry.photoUri
    write.remark = this.detailEntry.remark
    write.status = this.detailEntry.status === 'mastered' ? 'pending' : 'mastered'
    const ok = await WrongBizService.updateEntry(this.detailEntry.id, write)
    if (ok) {
      this.closeOverlays()
      await this.reloadCatalog()
      this.toast(write.status === 'mastered' ? '已标记掌握' : '已改回待复习')
    }
  }

  private async handleDelete(): Promise<void> {
    const ok = await WrongBizService.deleteEntry(this.detailEntry.id)
    if (ok) {
      this.closeOverlays()
      await this.reloadCatalog()
      this.toast('已删除')
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.homeTick,
            onRequireAuth: () => this.onRequireAuth(),
            onOpenMessages: () => {
              this.showMessages = true
              this.hideBar(true)
            },
            onSwitchTab: (i: number) => { this.current = i },
            onStartTraining: () => { this.current = 2 }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          NotebookPage({
            refreshToken: this.homeTick,
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          TrainingPage({
            refreshToken: this.homeTick,
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.homeTick,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout(),
            onRequireAuth: () => this.onRequireAuth(),
            onOpenMessages: () => {
              this.showMessages = true
              this.hideBar(true)
            },
            onOpenReport: () => {
              this.showReport = true
              this.hideBar(true)
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
        }
      }
      .width('100%')
      .height('100%')

      if (this.detailOpen && this.detailKind === CatalogKind.ENTRY) {
        EntryDetailPane({
          entry: this.detailEntry,
          onClose: () => this.closeOverlays(),
          onEdit: () => WrongDetailNav.openCapture('manual', this.detailEntry.id),
          onToggle: () => { void this.handleToggle() },
          onDelete: () => { void this.handleDelete() }
        })
      } else if (this.detailOpen) {
        CatalogDetailPane({
          item: this.detailItem,
          ctaLabel: '去录入错题',
          onClose: () => this.closeOverlays(),
          onCta: () => {
            this.closeOverlays()
            WrongDetailNav.openCapture('manual', '')
          }
        })
      }

      if (this.captureOpen) {
        CaptureOverlay({
          mode: this.captureMode,
          editEntry: this.captureEntry,
          onClose: () => this.closeOverlays(),
          onSave: (w: WrongEntryWrite, id: string) => { void this.handleSave(w, id) }
        })
      }

      if (this.showMessages) {
        MessagesPage({
          onClose: () => {
            this.showMessages = false
            this.hideBar(false)
          }
        })
      }

      if (this.showReport) {
        Column() {
          Row() {
            Text('学情报告')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('关闭')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => this.closeOverlays())
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.pageY
          })
          DashboardPage({ refreshToken: this.homeTick }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
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
    .onClick(() => { this.current = t.index })
  }
}
