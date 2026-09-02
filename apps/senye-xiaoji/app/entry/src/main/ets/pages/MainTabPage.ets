import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { WriteNotePane } from '../components/note/WriteNotePane'
import { NoteDetailPane } from '../components/note/NoteDetailPane'
import { HomePage } from './HomePage'
import { CalendarPage } from './CalendarPage'
import { OrganizePage } from './OrganizePage'
import { MinePage } from './MinePage'
import { NoteNav } from '../services/NoteNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '记录'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'chart'
    t1.label = '日历'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'search'
    t2.label = '整理'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State writeToken: number = 0
  @State detailToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('showWriteNote') @Watch('onWriteFlag') showWrite: boolean = false
  @StorageLink('writeNoteId') writeNoteId: string = ''
  @StorageLink('detailNoteId') @Watch('onDetailFlag') detailNoteId: string = ''
  @StorageLink('noteRefresh') noteRefresh: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '森野文化'
  @Prop appName: string = '森野小记'
  @Prop tagline: string = '智慧记录，森野随行'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onWriteFlag(): void {
    if (this.showWrite) {
      this.writeToken += 1
    }
  }

  onDetailFlag(): void {
    if (this.detailNoteId.length > 0) {
      this.detailToken += 1
    }
  }

  onDarkChange(): void {
    Theme.setColorMode(this.darkModeOn ? 'dark' : 'light')
  }

  private openWrite(): void {
    NoteNav.openWrite('')
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.noteRefresh,
            onOpenWrite: (): void => { this.openWrite() }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          CalendarPage({
            refreshToken: this.noteRefresh,
            onOpenWrite: (_iso: string): void => { this.openWrite() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          OrganizePage({ refreshToken: this.noteRefresh }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.noteRefresh,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => { this.onLogout() }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (tab: TabItem) => {
              Column({ space: 4 }) {
                AppIcon({
                  name: tab.name,
                  iconSize: Theme.icon.lg,
                  color: this.current === tab.index ?
                    Theme.colors().brandPrimary : Theme.colors().textSecondary
                })
                Text(tab.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.current === tab.index ?
                    Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 8, bottom: 8 })
              .backgroundColor(this.current === tab.index ?
                Theme.colors().brandPrimaryContainer : 'transparent')
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { this.current = tab.index })
            }, (tab: TabItem) => `${tab.index}`)
          }
          .width('100%')
          .padding({ left: Theme.space.s2, right: Theme.space.s2, bottom: Theme.space.s2, top: 4 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showWrite) {
        WriteNotePane({
          editId: this.writeNoteId,
          onClose: (): void => { NoteNav.closeWrite() }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.detailNoteId.length > 0) {
        NoteDetailPane({
          noteId: this.detailNoteId,
          onClose: (): void => { NoteNav.closeDetail() }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
