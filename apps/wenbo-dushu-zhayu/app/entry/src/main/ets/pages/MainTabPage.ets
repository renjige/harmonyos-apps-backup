import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { ShelfPage } from './ShelfPage'
import { NotesPage } from './NotesPage'
import { PlansPage } from './PlansPage'
import { MinePage } from './MinePage'
import { QuotesPage } from './QuotesPage'
import { OrganizePage } from './OrganizePage'
import { ReportPage } from './ReportPage'
import { CheckinPage } from './CheckinPage'
import { ReviewsPage } from './ReviewsPage'
import { BooklistsPage } from './BooklistsPage'
import { InspirationsPage } from './InspirationsPage'
import { MonthlyReviewPage } from './MonthlyReviewPage'
import { MessagesPage } from './MessagesPage'
import { LampSessionPage } from './LampSessionPage'
import { DialoguePage } from './DialoguePage'
import { StudioPlayPage } from './StudioPlayPage'
import { BookAskPage } from './BookAskPage'
import { FeaturedDetailPane } from '../components/detail/FeaturedDetailPane'
import { BookDetailPane } from '../components/detail/BookDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { QuoteDetailPane } from '../components/detail/QuoteDetailPane'
import { PlanDetailPane } from '../components/detail/PlanDetailPane'
import { CheckinDetailPane } from '../components/detail/CheckinDetailPane'
import { ReviewDetailPane } from '../components/detail/ReviewDetailPane'
import { BooklistDetailPane } from '../components/detail/BooklistDetailPane'
import { InspirationDetailPane } from '../components/detail/InspirationDetailPane'
import { AuthService } from '../services/AuthService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { ChainTabPage } from './ChainTabPage'
import { StudioIntroOverlay } from '../components/reading/StudioIntroOverlay'
import { SessionStore } from '../services/SessionStore'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '书房玩法'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'chart'
    t1.label = '札语链'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'user'
    t2.label = '我的'
    tabs.push(t2)
    return tabs
  }
}

/** 3 Tab：书房玩法 | 札语链 | 我的（书架/计划仅二级，弱化阅读记录印象） */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State shelfCreateTrigger: number = 0
  @State notesCreateTrigger: number = 0
  @State plansCreateTrigger: number = 0
  @State quotesRefresh: number = 0
  @State reportRefresh: number = 0
  @State showQuotes: boolean = false
  @State showOrganize: boolean = false
  @State showReport: boolean = false
  @State showCheckin: boolean = false
  @State showReviews: boolean = false
  @State showBooklists: boolean = false
  @State showInspirations: boolean = false
  @State showMonthly: boolean = false
  @State showMessages: boolean = false
  @State showLamp: boolean = false
  @State showDialogue: boolean = false
  @State showStudioPlay: boolean = false
  @State showBookAsk: boolean = false
  @State showNotes: boolean = false
  @State showShelf: boolean = false
  @State showPlans: boolean = false
  @State showStudioIntro: boolean = false
  @State studioRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '读书札语'
  @Prop tagline: string = '灯下共读、对读札、问书三札三种独有交互，把阅读收成可思考的书房'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    void this.maybeShowStudioIntro()
  }

  private async maybeShowStudioIntro(): Promise<void> {
    const seen = await SessionStore.isStudioIntroSeen()
    if (!seen) {
      this.showStudioIntro = true
      AppStorage.setOrCreate('tabBarHidden', true)
    }
  }

  private async dismissStudioIntro(): Promise<void> {
    await SessionStore.markStudioIntroSeen()
    this.showStudioIntro = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async tryLampFromIntro(): Promise<void> {
    await SessionStore.markStudioIntroSeen()
    this.showStudioIntro = false
    this.openStudio('lamp')
  }

  private bumpAllLists(): void {
    this.contentRefresh += 1
    this.studioRefresh += 1
    this.quotesRefresh += 1
    this.reportRefresh += 1
  }

  private bumpContentRefresh(): void {
    this.bumpAllLists()
  }

  private hideStudio(): void {
    this.showQuotes = false
    this.showOrganize = false
    this.showReport = false
    this.showCheckin = false
    this.showReviews = false
    this.showBooklists = false
    this.showInspirations = false
    this.showMonthly = false
    this.showMessages = false
    this.showLamp = false
    this.showDialogue = false
    this.showStudioPlay = false
    this.showBookAsk = false
    this.showNotes = false
    this.showShelf = false
    this.showPlans = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private openStudio(kind: string): void {
    this.hideStudio()
    AppStorage.setOrCreate('tabBarHidden', true)
    this.studioRefresh += 1
    if (kind === 'quotes') {
      this.showQuotes = true
      this.quotesRefresh += 1
    }
    if (kind === 'organize') { this.showOrganize = true }
    if (kind === 'report') { this.showReport = true }
    if (kind === 'checkin') { this.showCheckin = true }
    if (kind === 'reviews') { this.showReviews = true }
    if (kind === 'booklists') { this.showBooklists = true }
    if (kind === 'inspirations') { this.showInspirations = true }
    if (kind === 'monthly') { this.showMonthly = true }
    if (kind === 'messages') { this.showMessages = true }
    if (kind === 'lamp') { this.showLamp = true }
    if (kind === 'dialogue') { this.showDialogue = true }
    if (kind === 'studioPlay') { this.showStudioPlay = true }
    if (kind === 'bookAsk') { this.showBookAsk = true }
    if (kind === 'notes') { this.showNotes = true }
    if (kind === 'shelf') { this.showShelf = true }
    if (kind === 'plans') { this.showPlans = true }
  }

  private openReport(): void {
    this.openStudio('report')
    this.reportRefresh += 1
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          StudioPlayPage({
            embedded: true,
            appName: this.appName,
            tagline: this.tagline,
            onClose: (): void => {},
            onOpenLamp: (): void => { this.openStudio('lamp') },
            onOpenDialogue: (): void => { this.openStudio('dialogue') },
            onOpenBookAsk: (): void => { this.openStudio('bookAsk') },
            onOpenChain: (): void => { this.current = 1 }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ChainTabPage({
            refreshToken: this.studioRefresh,
            onOpenLamp: (): void => { this.openStudio('lamp') },
            onOpenDialogue: (): void => { this.openStudio('dialogue') },
            onOpenBookAsk: (): void => { this.openStudio('bookAsk') }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: (): void => this.onRequireAuth(),
            onSwitchTab: (index: number): void => {
              if (ReadingDetailNav.isOpen()) {
                ReadingDetailNav.close()
              }
              this.current = index
            },
            onOpenChainTab: (): void => { this.current = 1 },
            onOpenShelf: (): void => { this.openStudio('shelf') },
            onOpenPlans: (): void => { this.openStudio('plans') },
            onOpenNotes: (): void => { this.openStudio('notes') },
            onOpenQuotes: (): void => { this.openStudio('quotes') },
            onOpenOrganize: (): void => { this.openStudio('organize') },
            onOpenReport: (): void => { this.openReport() },
            onOpenCheckin: (): void => { this.openStudio('checkin') },
            onOpenReviews: (): void => { this.openStudio('reviews') },
            onOpenBooklists: (): void => { this.openStudio('booklists') },
            onOpenInspirations: (): void => { this.openStudio('inspirations') },
            onOpenMonthly: (): void => { this.openStudio('monthly') },
            onOpenMessages: (): void => { this.openStudio('messages') },
            onOpenLamp: (): void => { this.openStudio('lamp') },
            onOpenDialogue: (): void => { this.openStudio('dialogue') },
            onOpenStudioPlay: (): void => { this.openStudio('studioPlay') },
            onOpenBookAsk: (): void => { this.openStudio('bookAsk') }
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
          .shadow({ radius: 16, color: 'rgba(45,90,74,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showQuotes) {
        QuotesPage({
          refreshToken: this.quotesRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onOpenDialogue: (): void => { this.openStudio('dialogue') },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showOrganize) {
        OrganizePage({
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showReport) {
        ReportPage({
          refreshToken: this.reportRefresh,
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showCheckin) {
        CheckinPage({
          refreshToken: this.studioRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onChanged: (): void => { this.bumpContentRefresh() },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showReviews) {
        ReviewsPage({
          refreshToken: this.studioRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onChanged: (): void => { this.bumpContentRefresh() },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showBooklists) {
        BooklistsPage({
          refreshToken: this.studioRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onChanged: (): void => { this.bumpContentRefresh() },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showInspirations) {
        InspirationsPage({
          refreshToken: this.studioRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onChanged: (): void => { this.bumpContentRefresh() },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showMonthly) {
        MonthlyReviewPage({
          refreshToken: this.studioRefresh,
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showLamp) {
        LampSessionPage({
          onRequireAuth: (): void => this.onRequireAuth(),
          onChanged: (): void => { this.bumpAllLists() },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showDialogue) {
        DialoguePage({
          onRequireAuth: (): void => this.onRequireAuth(),
          onChanged: (): void => { this.bumpAllLists() },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showStudioPlay) {
        StudioPlayPage({
          embedded: false,
          appName: this.appName,
          tagline: this.tagline,
          onClose: (): void => { this.hideStudio() },
          onOpenLamp: (): void => {
            this.showStudioPlay = false
            this.showLamp = true
          },
          onOpenDialogue: (): void => {
            this.showStudioPlay = false
            this.showDialogue = true
          },
          onOpenBookAsk: (): void => {
            this.showStudioPlay = false
            this.showBookAsk = true
          },
          onOpenChain: (): void => {
            this.hideStudio()
            this.current = 1
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showBookAsk) {
        BookAskPage({
          refreshToken: this.studioRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onChanged: (): void => { this.bumpAllLists() },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showNotes) {
        NotesPage({
          overlayMode: true,
          createTrigger: this.notesCreateTrigger,
          refreshToken: this.contentRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onNoteCreated: (): void => { this.bumpContentRefresh() },
          onClose: (): void => { this.hideStudio() }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showShelf) {
        Column() {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'close', iconSize: Theme.icon.md })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.hideStudio() })
            Text('我的书架（辅助）')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
          ShelfPage({
            createTrigger: this.shelfCreateTrigger,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onBookCreated: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
        .zIndex(16)
      }

      if (this.showPlans) {
        Column() {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'close', iconSize: Theme.icon.md })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.hideStudio() })
            Text('阅读计划（辅助）')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
          PlansPage({
            createTrigger: this.plansCreateTrigger,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onPlanCreated: (): void => { this.bumpContentRefresh() },
            onOpenReport: (): void => { this.openReport() }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
        .zIndex(16)
      }

      if (this.showStudioIntro) {
        StudioIntroOverlay({
          onDismiss: (): void => { void this.dismissStudioIntro() },
          onTryLamp: (): void => { void this.tryLampFromIntro() }
        })
          .width('100%')
          .height('100%')
          .zIndex(30)
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
    if (ReadingDetailNav.parseKind() === 'featured') {
      FeaturedDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'book') {
      BookDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onProgressUpdated: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'note') {
      NoteDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onChanged: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'quote') {
      QuoteDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onChanged: (): void => { this.bumpAllLists() },
        onDeleted: (): void => { this.bumpAllLists() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'plan') {
      PlanDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onOpenReport: (): void => { this.openReport() },
        onProgressUpdated: (): void => { this.bumpContentRefresh() },
        onChanged: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'checkin') {
      CheckinDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onDeleted: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'review') {
      ReviewDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onDeleted: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'booklist') {
      BooklistDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onChanged: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'inspiration') {
      InspirationDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onChanged: (): void => { this.bumpContentRefresh() }
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
            Theme.tabSelectedIconForeground() : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.tabSelectedIconBackground() : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.tabSelectedLabelForeground() : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      if (ReadingDetailNav.isOpen()) {
        ReadingDetailNav.close()
      }
      this.hideStudio()
      this.current = t.index
    })
  }
}
