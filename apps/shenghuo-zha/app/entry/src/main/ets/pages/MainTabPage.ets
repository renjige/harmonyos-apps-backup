import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { NoteEditorSheet } from '../components/detail/NoteEditorSheet'
import { TodoEditSheet } from '../components/detail/TodoEditSheet'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { TimelinePage } from './TimelinePage'
import { ReminderPage } from './ReminderPage'
import { CraftPage } from './CraftPage'
import { AlbumPage } from './AlbumPage'
import { MinePage } from './MinePage'
import { SearchPage } from './SearchPage'
import { LifeDetailNav } from '../services/LifeDetailNav'
import { CraftDetailPane } from '../components/detail/CraftDetailPane'
import { CraftEditorSheet } from '../components/detail/CraftEditorSheet'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '时间线'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'alert'
    t1.label = '日常'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '锦囊'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '回忆'
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
  @State current: number = 0
  @State dataRefresh: number = 0
  @StorageLink('lifeThemeTick') themeTick: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('lifeNoteDetailId') noteDetailId: string = ''
  @StorageLink('lifeNoteEditorId') noteEditorId: string = ''
  @StorageLink('lifeNoteEditorOpen') noteEditorOpen: boolean = false
  @StorageLink('lifeTodoEditId') todoEditId: string = ''
  @StorageLink('lifeSearchOpen') searchOpen: boolean = false
  @StorageLink('lifeCraftDetailId') craftDetailId: string = ''
  @StorageLink('lifeCraftEditorOpen') craftEditorOpen: boolean = false
  private tabs: TabItem[] = TabItem.all()

  private bumpRefresh(): void {
    this.dataRefresh++
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          TimelinePage({ refreshToken: this.dataRefresh }).layoutWeight(1)
        } else if (this.current === 1) {
          ReminderPage({ refreshToken: this.dataRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          CraftPage({ refreshToken: this.dataRefresh }).layoutWeight(1)
        } else if (this.current === 3) {
          AlbumPage({ refreshToken: this.dataRefresh }).layoutWeight(1)
        } else {
          MinePage({
            refreshToken: this.dataRefresh,
            onDataChanged: (): void => { this.bumpRefresh() }
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
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(196,120,74,0.10)', offsetY: -2 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.noteDetailId.length > 0) {
        DetailShell({
          title: '札记详情',
          onClose: (): void => { LifeDetailNav.closeNote() },
          body: this.NoteDetailBody
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.noteEditorOpen) {
        NoteEditorSheet({
          noteId: this.noteEditorId,
          onSaved: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.todoEditId.length > 0) {
        TodoEditSheet({
          todoId: this.todoEditId,
          onSaved: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.searchOpen) {
        SearchPage({ refreshToken: this.dataRefresh })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.craftDetailId.length > 0) {
        DetailShell({
          title: '锦囊详情',
          onClose: (): void => { LifeDetailNav.closeCraft() },
          body: this.CraftDetailBody
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.craftEditorOpen) {
        CraftEditorSheet({
          onSaved: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(56)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeTick >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  NoteDetailBody() {
    NoteDetailPane({
      refreshToken: this.dataRefresh,
      onChanged: (): void => { this.bumpRefresh() }
    })
  }

  @Builder
  CraftDetailBody() {
    CraftDetailPane({
      refreshToken: this.dataRefresh,
      onChanged: (): void => { this.bumpRefresh() }
    })
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
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
