import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { JournalDetailPane } from '../components/detail/JournalDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { NoteEditorSheet } from '../components/detail/NoteEditorSheet'
import { TodoEditSheet } from '../components/detail/TodoEditSheet'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { JournalCalendarPage } from './JournalCalendarPage'
import { NotesPage } from './NotesPage'
import { SettingsPage } from './SettingsPage'
import { TodoPage } from './TodoPage'
import { ZhaDetailNav } from '../services/ZhaDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '札记'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '笔记'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'check'
    t2.label = '待办'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'gear'
    t3.label = '设置'
    tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State dataRefresh: number = 0
  @StorageLink('zhaThemeTick') themeTick: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('zhaNoteDetailId') noteDetailId: string = ''
  @StorageLink('zhaNoteEditorId') noteEditorId: string = ''
  @StorageLink('zhaNoteEditorOpen') noteEditorOpen: boolean = false
  @StorageLink('zhaJournalCalendarOpen') journalCalendarOpen: boolean = false
  @StorageLink('zhaJournalDetailKey') journalDetailKey: string = ''
  @StorageLink('zhaTodoEditId') todoEditId: string = ''
  @Prop appName: string = '松岚札'
  onPrivacyRevoked: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpRefresh(): void {
    this.dataRefresh++
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.dataRefresh,
            onOpenNotes: () => {
              this.current = 1
              ZhaDetailNav.openNoteEditor('')
            },
            onOpenTodos: () => {
              this.current = 2
            },
            onDataChanged: () => this.bumpRefresh()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          NotesPage({ refreshToken: this.dataRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          TodoPage({ refreshToken: this.dataRefresh }).layoutWeight(1)
        } else {
          SettingsPage({
            refreshToken: this.dataRefresh,
            onRevokePrivacy: () => this.onPrivacyRevoked(),
            onDataChanged: () => this.bumpRefresh()
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
          .shadow({ radius: 16, color: 'rgba(45,90,74,0.08)', offsetY: -2 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.noteDetailId.length > 0) {
        DetailShell({
          title: '笔记详情',
          onClose: () => ZhaDetailNav.closeNote(),
          body: () => {
            NoteDetailPane({
              noteId: this.noteDetailId,
              refreshToken: this.dataRefresh,
              onChanged: () => this.bumpRefresh()
            })
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.noteEditorOpen) {
        NoteEditorSheet({
          noteId: this.noteEditorId,
          onSaved: () => this.bumpRefresh()
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.journalCalendarOpen) {
        JournalCalendarPage({
          refreshToken: this.dataRefresh,
          onChanged: () => this.bumpRefresh()
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.journalDetailKey.length > 0) {
        DetailShell({
          title: '札记详情',
          onClose: () => ZhaDetailNav.closeJournalDetail(),
          body: () => {
            JournalDetailPane({
              dateKey: this.journalDetailKey,
              refreshToken: this.dataRefresh,
              onChanged: () => this.bumpRefresh()
            })
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(60)
      }

      if (this.todoEditId.length > 0) {
        TodoEditSheet({
          todoId: this.todoEditId,
          onSaved: () => this.bumpRefresh()
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeTick >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
