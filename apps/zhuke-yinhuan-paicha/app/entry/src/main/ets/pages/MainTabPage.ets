import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { HomePage } from './HomePage'
import { HazardListPage } from './HazardListPage'
import { InspectPage } from './InspectPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { HazardFormOverlay } from '../components/hazard/HazardFormOverlay'
import { HazardDetailPane } from '../components/hazard/HazardDetailPane'
import { RectifyOverlay } from '../components/hazard/RectifyOverlay'
import { ReviewOverlay } from '../components/hazard/ReviewOverlay'
import { InspectRunOverlay } from '../components/hazard/InspectRunOverlay'
import { CheckItem, CreateHazardBody, HazardItem, RectifyBody, ReviewBody } from '../models/HazardModels'
import { HazardBizService } from '../services/HazardBizService'
import { AuthService } from '../services/AuthService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const a = new TabItem(); a.index = 0; a.name = 'home'; a.label = '首页'; tabs.push(a)
    const b = new TabItem(); b.index = 1; b.name = 'alert'; b.label = '隐患'; tabs.push(b)
    const c = new TabItem(); c.index = 2; c.name = 'check'; c.label = '检查'; tabs.push(c)
    const d = new TabItem(); d.index = 3; d.name = 'user'; d.label = '我的'; tabs.push(d)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State tick: number = 0
  @State listFilter: string = 'all'
  @State toastText: string = ''
  @State showForm: boolean = false
  @State showDetail: boolean = false
  @State showRectify: boolean = false
  @State showReview: boolean = false
  @State showInspect: boolean = false
  @State showMessages: boolean = false
  @State showSelfCheck: boolean = false
  @State seedTitle: string = ''
  @State seedCategory: string = ''
  @State detail: HazardItem = new HazardItem()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('accessToken') @Watch('onAuthChange') accessToken: string = ''
  @Prop company: string = '筑科建筑工程有限公司'
  @Prop appName: string = '筑科隐患排查'
  @Prop tagline: string = '今日安全，及时发现'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private bump(): void {
    this.tick += 1
  }

  onAuthChange(): void {
    this.bump()
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private openForm(title: string, category: string): void {
    this.seedTitle = title
    this.seedCategory = category
    this.showForm = true
    this.hideBar(true)
  }

  private openDetail(item: HazardItem): void {
    this.detail = item
    this.showDetail = true
    this.hideBar(true)
  }

  private closeForm(): void {
    this.showForm = false
    this.hideBar(this.showDetail)
  }

  private closeDetail(): void {
    this.showDetail = false
    this.showRectify = false
    this.showReview = false
    this.hideBar(false)
  }

  private async saveHazard(title: string, location: string, category: string, risk: string,
    description: string, suggestion: string, owner: string, dueAt: string): Promise<void> {
    const draft = new CreateHazardBody()
    draft.title = title
    draft.location = location
    draft.category = category
    draft.riskLevel = risk
    draft.description = description
    draft.suggestion = suggestion
    draft.ownerName = owner
    draft.dueAt = dueAt
    draft.photosJson = '[]'
    const row = await HazardBizService.createHazard(draft)
    this.showForm = false
    this.detail = row
    this.showDetail = true
    this.hideBar(true)
    this.bump()
    this.toast('隐患已记录')
  }

  private async submitRectify(note: string, worker: string, _doneAt: string): Promise<void> {
    const body = new RectifyBody()
    body.rectifyNote = note
    body.rectifyBy = worker
    const row = await HazardBizService.rectify(this.detail.id, body)
    this.detail = row
    this.showRectify = false
    this.bump()
    this.toast('整改已提交，待复查')
  }

  private async submitReview(passed: boolean, note: string): Promise<void> {
    const body = new ReviewBody()
    body.passed = passed
    body.reviewNote = note
    const row = await HazardBizService.review(this.detail.id, body)
    this.detail = row
    this.showReview = false
    this.bump()
    this.toast(passed ? '✓ 隐患已完成闭环' : '复查未通过，已退回整改')
  }

  private async submitInspect(items: CheckItem[], location: string): Promise<void> {
    const result = await HazardBizService.submitInspect(items, location)
    this.showInspect = false
    this.hideBar(false)
    this.current = 1
    this.listFilter = 'all'
    this.bump()
    if (result.hazards.length > 0) {
      this.toast(`检查完成，已生成 ${result.hazards.length} 条隐患`)
    } else {
      this.toast('检查完成，未见异常')
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.tick,
            onAdd: () => this.openForm('', ''),
            onInspect: () => { this.showInspect = true; this.hideBar(true) },
            onOpen: (it: HazardItem) => this.openDetail(it),
            onOpenAll: () => { this.listFilter = 'all'; this.current = 1 },
            onOpenRectify: () => { this.listFilter = 'pending_rectify'; this.current = 1 },
            onOpenReview: () => { this.listFilter = 'pending_review'; this.current = 1 },
            onOpenMessages: () => { this.showMessages = true; this.hideBar(true) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          HazardListPage({
            refreshToken: this.tick,
            filterSeed: this.listFilter,
            onOpen: (it: HazardItem) => this.openDetail(it),
            onAdd: () => this.openForm('', '')
          }).layoutWeight(1)
        } else if (this.current === 2) {
          InspectPage({
            refreshToken: this.tick,
            onStart: () => { this.showInspect = true; this.hideBar(true) },
            onSelfCheck: () => { this.showSelfCheck = true; this.hideBar(true) }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
              this.bump()
            },
            onDataCleared: (): void => { this.bump() }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => { this.TabBarItem(t) }, (t: TabItem) => `${t.index}`)
          }
          .width('100%').height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%').height('100%')

      if (this.showForm) {
        HazardFormOverlay({
          seedTitle: this.seedTitle,
          seedCategory: this.seedCategory,
          onClose: () => this.closeForm(),
          onSave: (title: string, location: string, category: string, risk: string, description: string,
            suggestion: string, owner: string, dueAt: string) => {
            void this.saveHazard(title, location, category, risk, description, suggestion, owner, dueAt)
          }
        })
      }
      if (this.showDetail && !this.showForm && !this.showRectify && !this.showReview) {
        Column() {
          Row() {
            Text('返回').fontSize(15).fontColor(Theme.colors().brandAccent).onClick(() => this.closeDetail())
            Text('隐患详情').fontSize(18).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
              .layoutWeight(1).textAlign(TextAlign.Center)
            Text(' ').fontSize(15)
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
          HazardDetailPane({
            item: this.detail,
            onRectify: () => { this.showRectify = true },
            onReview: () => { this.showReview = true }
          }).layoutWeight(1)
        }
        .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
      if (this.showRectify) {
        RectifyOverlay({
          onClose: () => { this.showRectify = false },
          onSubmit: (note: string, worker: string, doneAt: string) => {
            void this.submitRectify(note, worker, doneAt)
          }
        })
      }
      if (this.showReview) {
        ReviewOverlay({
          onClose: () => { this.showReview = false },
          onSubmit: (passed: boolean, note: string) => { void this.submitReview(passed, note) }
        })
      }
      if (this.showInspect) {
        InspectRunOverlay({
          onClose: () => { this.showInspect = false; this.hideBar(false) },
          onSubmit: (items: CheckItem[], location: string) => { void this.submitInspect(items, location) }
        })
      }
      if (this.showMessages) {
        Column() {
          MessagesPage().layoutWeight(1)
          AppButton({ label: '返回', variant: 'secondary', onTap: () => {
            this.showMessages = false
            this.hideBar(false)
          } }).margin(16)
        }
        .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
      if (this.showSelfCheck) {
        Column() {
          AIAssistantPage({
            onRequireAuth: () => this.onRequireAuth(),
            onBookFromAi: (c: string) => {
              this.showSelfCheck = false
              this.openForm('', c)
            }
          }).layoutWeight(1)
          AppButton({ label: '返回', variant: 'secondary', onTap: () => {
            this.showSelfCheck = false
            this.hideBar(false)
          } }).margin(16)
        }
        .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(13).fontColor('#FFFFFF').padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary).borderRadius(999)
        }
        .width('100%').padding({ top: 24 }).alignItems(HorizontalAlign.Center).zIndex(30)
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
      .width(48).height(28).justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1).height('100%').justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      this.hideBar(false)
      this.current = t.index
    })
  }
}
