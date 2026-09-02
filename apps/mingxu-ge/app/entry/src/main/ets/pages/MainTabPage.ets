import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { SchedulePage } from './SchedulePage'
import { HabitPage } from './HabitPage'
import { NotesPage } from './NotesPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { DetailShell } from '../components/detail/DetailShell'
import { AgendaDetailPane } from '../components/detail/AgendaDetailPane'
import { HabitDetailPane } from '../components/detail/HabitDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { TipDetailPane } from '../components/detail/TipDetailPane'
import { AgendaEditorSheet } from '../components/detail/AgendaEditorSheet'
import { HabitEditorSheet } from '../components/detail/HabitEditorSheet'
import { NoteEditorSheet } from '../components/detail/NoteEditorSheet'
import { XuDetailNav } from '../services/XuDetailNav'
import { AuthService } from '../services/AuthService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const a = new TabItem()
    a.index = 0
    a.name = 'home'
    a.label = '首页'
    tabs.push(a)
    const b = new TabItem()
    b.index = 1
    b.name = 'calendar'
    b.label = '日程'
    tabs.push(b)
    const c = new TabItem()
    c.index = 2
    c.name = 'heart'
    c.label = '习惯'
    tabs.push(c)
    const d = new TabItem()
    d.index = 3
    d.name = 'book'
    d.label = '知识'
    tabs.push(d)
    const e = new TabItem()
    e.index = 4
    e.name = 'user'
    e.label = '我的'
    tabs.push(e)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State dataRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('xuAgendaId') agendaId: string = ''
  @StorageLink('xuHabitId') habitId: string = ''
  @StorageLink('xuNoteId') noteId: string = ''
  @StorageLink('xuTipId') tipId: string = ''
  @StorageLink('xuAgendaEditOpen') agendaEditOpen: boolean = false
  @StorageLink('xuHabitEditOpen') habitEditOpen: boolean = false
  @StorageLink('xuNoteEditOpen') noteEditOpen: boolean = false
  @StorageLink('xuAgendaEditId') agendaEditId: string = ''
  @StorageLink('xuAgendaEditDate') agendaEditDate: string = ''
  @StorageLink('xuHabitEditId') habitEditId: string = ''
  @StorageLink('xuNoteEditId') noteEditId: string = ''
  @StorageLink('xuDiagnoseOpen') diagnoseOpen: boolean = false
  @StorageLink('xuMessagesOpen') messagesOpen: boolean = false
  @StorageLink('xuThemeTick') themeTick: number = 0
  @Prop appName: string = '明序阁'
  @Prop company: string = '明序阁'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.dataRefresh++
  }

  build() {
    Stack() {
      Column() {
        // 用 if 切换：回到首页会重新 aboutToAppear，强制读最新统计
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.dataRefresh,
            onOpenSchedule: () => { this.current = 1 },
            onOpenHabits: () => { this.current = 2 },
            onOpenNotes: () => { this.current = 3 },
            onDataChanged: () => this.bump()
          })
            .width('100%')
            .layoutWeight(1)
        } else if (this.current === 1) {
          SchedulePage({
            refreshToken: this.dataRefresh,
            onDataChanged: () => this.bump()
          })
            .width('100%')
            .layoutWeight(1)
        } else if (this.current === 2) {
          HabitPage({
            refreshToken: this.dataRefresh,
            onDataChanged: () => this.bump()
          })
            .width('100%')
            .layoutWeight(1)
        } else if (this.current === 3) {
          NotesPage({
            refreshToken: this.dataRefresh,
            onDataChanged: () => this.bump()
          })
            .width('100%')
            .layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.dataRefresh,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => {
              void AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: () => this.onRequireAuth()
          })
            .width('100%')
            .layoutWeight(1)
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
          .shadow({ radius: 16, color: 'rgba(26,42,58,0.08)', offsetY: -2 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.agendaId.length > 0) {
        Column() {
          DetailShell({
            title: '日程详情',
            onClose: () => XuDetailNav.closeAgenda()
          }) {
            AgendaDetailPane({
              agendaId: this.agendaId,
              refreshToken: this.dataRefresh,
              onChanged: () => this.bump()
            })
          }
        }
        .width('100%')
        .height('100%')
        .zIndex(50)
      }
      if (this.habitId.length > 0) {
        Column() {
          DetailShell({
            title: '习惯详情',
            onClose: () => XuDetailNav.closeHabit()
          }) {
            HabitDetailPane({
              habitId: this.habitId,
              onChanged: () => this.bump()
            })
          }
        }
        .width('100%')
        .height('100%')
        .zIndex(50)
      }
      if (this.noteId.length > 0) {
        Column() {
          DetailShell({
            title: '知识碎片',
            onClose: () => XuDetailNav.closeNote()
          }) {
            NoteDetailPane({
              noteId: this.noteId,
              onChanged: () => this.bump()
            })
          }
        }
        .width('100%')
        .height('100%')
        .zIndex(50)
      }
      if (this.tipId.length > 0) {
        Column() {
          DetailShell({
            title: '阁中笺注',
            onClose: () => XuDetailNav.closeTip()
          }) {
            TipDetailPane({ tipId: this.tipId })
          }
        }
        .width('100%')
        .height('100%')
        .zIndex(50)
      }
      if (this.agendaEditOpen) {
        Column() {
          AgendaEditorSheet({
            editId: this.agendaEditId,
            presetDate: this.agendaEditDate,
            onSaved: () => this.bump(),
            onClose: () => XuDetailNav.closeAgendaEditor()
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(55)
      }
      if (this.habitEditOpen) {
        Column() {
          HabitEditorSheet({
            editId: this.habitEditId,
            onSaved: () => this.bump(),
            onClose: () => XuDetailNav.closeHabitEditor()
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(55)
      }
      if (this.noteEditOpen) {
        Column() {
          NoteEditorSheet({
            editId: this.noteEditId,
            onSaved: () => this.bump(),
            onClose: () => XuDetailNav.closeNoteEditor()
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(55)
      }
      if (this.diagnoseOpen) {
        Column() {
          AIAssistantPage({
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .zIndex(50)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
      if (this.messagesOpen) {
        Column() {
          DetailShell({
            title: '消息',
            onClose: () => XuDetailNav.closeMessages()
          }) {
            MessagesPage()
          }
        }
        .width('100%')
        .height('100%')
        .zIndex(50)
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
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.bump()
    })
  }
}
