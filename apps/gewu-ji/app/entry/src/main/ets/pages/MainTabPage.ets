import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { KnowledgeDetailPane } from '../components/detail/KnowledgeDetailPane'
import { KnowledgeObject } from '../models/KnowledgeModels'
import { DailyPage } from './DailyPage'
import { FolioPage } from './FolioPage'
import { PracticePage } from './PracticePage'
import { TracePage } from './TracePage'
import { KnowledgeCatalog } from '../services/KnowledgeCatalog'
import { GewuDetailNav } from '../services/GewuDetailNav'
import { RecordDetailPane } from '../components/detail/RecordDetailPane'
import { RecordEditorSheet } from '../components/gewu/RecordEditorSheet'
import { CheckinSheet } from '../components/gewu/CheckinSheet'
import { PlanEditorSheet } from '../components/gewu/PlanEditorSheet'
import { TopicEditorSheet } from '../components/gewu/TopicEditorSheet'
import { PlanDetailPane } from '../components/gewu/PlanDetailPane'
import { TopicDetailPane } from '../components/gewu/TopicDetailPane'
import { ProductIntroOverlay } from '../components/gewu/ProductIntroOverlay'
import { GewuStore } from '../services/GewuStore'

class TabItem {
  index: number = 0
  name: AppIconName = 'calendar'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'calendar', '今日'],
      ['1', 'book', '图鉴'],
      ['2', 'biz', '功课'],
      ['3', 'chart', '足迹']
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
  @State showProductIntro: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('openDetailId') openDetailId: string = ''
  @StorageLink('openRecordId') openRecordId: string = ''
  @StorageLink('recordEditorId') recordEditorId: string = ''
  @StorageLink('practiceSheet') practiceSheet: string = ''
  @StorageLink('appearance') appearanceMode: string = 'system'
  @StorageLink('themeRevision') @Watch('onThemeRevision') themeRevision: number = 0
  @StorageLink('switchTabIndex') @Watch('onSwitchTab') switchTabIndex: number = -1
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 16

  aboutToAppear(): void {
    AppStorage.setOrCreate('openDetailId', '')
    AppStorage.setOrCreate('detailRefreshToken', 0)
    AppStorage.setOrCreate('practiceSheet', '')
    AppStorage.setOrCreate('practiceFocusId', '')
    void GewuStore.needsProductIntro().then((need: boolean): void => {
      this.showProductIntro = need
    })
  }

  private async dismissProductIntro(): Promise<void> {
    await GewuStore.markProductIntroSeen()
    this.showProductIntro = false
  }

  onThemeRevision(): void {
    this.refreshToken++
  }

  onSwitchTab(): void {
    if (this.switchTabIndex >= 0 && this.switchTabIndex <= 3) {
      this.current = this.switchTabIndex
      if (this.recordEditorId.length === 0 && this.openRecordId.length === 0 &&
        this.openDetailId.length === 0 && this.practiceSheet.length === 0) {
        AppStorage.setOrCreate('tabBarHidden', false)
      }
      this.refreshToken++
      AppStorage.setOrCreate('switchTabIndex', -1)
    }
  }

  private resolvedDetail(): KnowledgeObject {
    if (this.openDetailId.length === 0) {
      return new KnowledgeObject()
    }
    const obj = KnowledgeCatalog.resolveById(this.openDetailId)
    if (obj === undefined) {
      return new KnowledgeObject()
    }
    return obj
  }

  private pageBg(): string {
    if (this.themeRevision < 0 || this.appearanceMode.length === 0) {
      return Theme.colors().surfacePage
    }
    return Theme.colors().surfacePage
  }

  private closeDetail(): void {
    GewuDetailNav.close()
    this.refreshToken++
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          DailyPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else if (this.current === 1) {
          FolioPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else if (this.current === 2) {
          PracticePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else {
          TracePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onDataChanged: (): void => { this.refreshToken++ }
          }).layoutWeight(1)
        }

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
          .shadow({ radius: 16, color: 'rgba(26,58,92,0.10)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.pageBg())

      if (this.recordEditorId.length > 0) {
        Column() {
          RecordEditorSheet({
            editorId: this.recordEditorId,
            onSaved: (): void => { this.refreshToken++ }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(60)
      } else if (this.openRecordId.length > 0) {
        Column() {
          RecordDetailPane({
            recordId: this.openRecordId,
            onChanged: (): void => { this.refreshToken++ }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(55)
      } else if (this.openDetailId.length > 0 && this.resolvedDetail().id.length > 0) {
        Column() {
          DetailShell({
            title: this.resolvedDetail().title,
            onClose: (): void => { this.closeDetail() },
            body: (): void => {
              this.DetailBody()
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.pageBg())
        .zIndex(50)
      } else if (this.practiceSheet === 'checkin') {
        Column() {
          CheckinSheet({
            refreshToken: this.refreshToken,
            onSaved: (): void => { this.refreshToken++ }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(58)
      } else if (this.practiceSheet === 'plan') {
        Column() {
          PlanEditorSheet({
            onSaved: (): void => { this.refreshToken++ }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(58)
      } else if (this.practiceSheet === 'topic') {
        Column() {
          TopicEditorSheet({
            onSaved: (): void => { this.refreshToken++ }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(58)
      } else if (this.practiceSheet === 'planView') {
        Column() {
          PlanDetailPane({
            onChanged: (): void => { this.refreshToken++ }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(58)
      } else if (this.practiceSheet === 'topicView') {
        Column() {
          TopicDetailPane({
            onChanged: (): void => { this.refreshToken++ }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(58)
      }

      if (this.showProductIntro) {
        ProductIntroOverlay({
          onDismiss: (): void => { void this.dismissProductIntro() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  DetailBody() {
    KnowledgeDetailPane({
      item: this.resolvedDetail(),
      refreshToken: this.refreshToken,
      onDataChanged: (): void => { this.refreshToken++ }
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
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(44)
      .height(26)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 6 })
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.refreshToken++
    })
  }
}
