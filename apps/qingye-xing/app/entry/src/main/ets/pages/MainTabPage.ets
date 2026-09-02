import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { EntryDetailPane } from '../components/detail/EntryDetailPane'
import { ClipDetailPane } from '../components/detail/ClipDetailPane'
import { ThemeDetailPane } from '../components/detail/ThemeDetailPane'
import { EntryEditorSheet } from '../components/detail/EntryEditorSheet'
import { ClipEditorSheet } from '../components/detail/ClipEditorSheet'
import { ThemeEditorSheet } from '../components/detail/ThemeEditorSheet'
import { GlobalSearchSheet } from '../components/search/GlobalSearchSheet'
import { YearArchiveSheet } from '../components/lookback/YearArchiveSheet'
import { HomePage } from './HomePage'
import { ExploreListPage } from './ExploreListPage'
import { ThemeSpacePage } from './ThemeSpacePage'
import { LookbackPage } from './LookbackPage'
import { MinePage } from './MinePage'
import { QyDetailNav } from '../services/QyDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '清野'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'book'
    t1.label = '记录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'grid'
    t2.label = '主题'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'clock'
    t3.label = '回望'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('QyEntryId') entryId: string = ''
  @StorageLink('QyClipId') clipId: string = ''
  @StorageLink('QyThemeId') themeId: string = ''
  @StorageLink('QyEntryEditorOpen') entryEditorOpen: boolean = false
  @StorageLink('QyEntryEditId') entryEditId: string = ''
  @StorageLink('QyEntryTemplate') entryTemplate: string = 'blank'
  @StorageLink('QyClipEditorOpen') clipEditorOpen: boolean = false
  @StorageLink('QyClipEditId') clipEditId: string = ''
  @StorageLink('QyThemeEditorOpen') themeEditorOpen: boolean = false
  @StorageLink('QyThemeEditId') themeEditId: string = ''
  @StorageLink('QySearchOpen') searchOpen: boolean = false
  @StorageLink('QyYearOpen') yearOpen: boolean = false
  @StorageLink('qyJumpExploreInbox') @Watch('onJumpInboxTab') jumpInbox: boolean = false
  @StorageProp('QyDataRev') @Watch('onGlobalDataRev') dataRev: number = 0
  @StorageLink('QyActiveTab') @Watch('onActiveTab') activeTab: number = 0
  @State current: number = 0
  @State dataRefresh: number = 0
  onPrivacyRevoked: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.dataRefresh++
  }

  onGlobalDataRev(): void {
    this.dataRefresh++
  }

  onJumpInboxTab(): void {
    if (this.jumpInbox) {
      this.current = 1
    }
  }

  onActiveTab(): void {
    if (this.activeTab >= 1 && this.activeTab <= 4) {
      this.current = this.activeTab
      AppStorage.setOrCreate('QyActiveTab', 0)
    }
  }

  aboutToAppear(): void {
    if (this.jumpInbox) {
      this.current = 1
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ refreshToken: this.dataRefresh, bottomInset: 76 }).layoutWeight(1)
        } else if (this.current === 1) {
          ExploreListPage({ refreshToken: this.dataRefresh, bottomInset: 76 }).layoutWeight(1)
        } else if (this.current === 2) {
          ThemeSpacePage({ refreshToken: this.dataRefresh, bottomInset: 76 }).layoutWeight(1)
        } else if (this.current === 3) {
          LookbackPage({ refreshToken: this.dataRefresh, bottomInset: 76 }).layoutWeight(1)
        } else {
          MinePage({
            refreshToken: this.dataRefresh,
            bottomInset: 76,
            onPrivacyRevoked: (): void => { this.onPrivacyRevoked() }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              Column({ space: 2 }) {
                Column() {
                  AppIcon({
                    name: t.name,
                    iconSize: 22,
                    color: this.current === t.index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
                  })
                }
                .width(36)
                .height(28)
                .justifyContent(FlexAlign.Center)
                .borderRadius(14)
                .backgroundColor(this.current === t.index ? Theme.colors().brandPrimary : Color.Transparent)
                Text(t.label)
                  .fontSize(10)
                  .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .height(52)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => {
                this.current = t.index
                if (t.index === 0) {
                  this.bump()
                }
              })
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .margin({ left: 16, right: 16, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(47,74,71,0.12)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.searchOpen) {
        GlobalSearchSheet()
      }
      if (this.yearOpen) {
        YearArchiveSheet()
      }
      if (this.entryEditorOpen) {
        EntryEditorSheet({
          editId: this.entryEditId,
          templateKey: this.entryTemplate,
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.clipEditorOpen) {
        ClipEditorSheet({
          editId: this.clipEditId,
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.themeEditorOpen) {
        ThemeEditorSheet({
          editId: this.themeEditId,
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.entryId.length > 0) {
        DetailShell({ title: '记录', onClose: (): void => { QyDetailNav.closeEntry() } }) {
          EntryDetailPane({ entryId: this.entryId, onChanged: (): void => { this.bump() } })
        }
      }
      if (this.clipId.length > 0) {
        DetailShell({ title: '观察', onClose: (): void => { QyDetailNav.closeClip() } }) {
          ClipDetailPane({ clipId: this.clipId, onChanged: (): void => { this.bump() } })
        }
      }
      if (this.themeId.length > 0) {
        DetailShell({ title: '主题', onClose: (): void => { QyDetailNav.closeTheme() } }) {
          ThemeDetailPane({ themeId: this.themeId, onChanged: (): void => { this.bump() } })
        }
      }

      Column() {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandDeep })
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .backgroundColor(Theme.colors().surfaceCard)
      .justifyContent(FlexAlign.Center)
      .shadow({ radius: 8, color: 'rgba(47,74,71,0.12)', offsetY: 2 })
      .position({ x: '82%', y: 18 })
      .visibility(this.tabBarHidden ? Visibility.Hidden : Visibility.Visible)
      .onClick((): void => { QyDetailNav.openSearch() })
    }
    .width('100%')
    .height('100%')
  }
}
