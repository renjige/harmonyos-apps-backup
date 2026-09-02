import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ClassifyPage } from './ClassifyPage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { MemoryWritePane } from '../components/memory/MemoryWritePane'
import { MemoryDetailPane } from '../components/memory/MemoryDetailPane'
import { BookletDetailPane } from '../components/memory/BookletDetailPane'
import { BookletEditorSheet } from '../components/memory/BookletEditorSheet'
import { BookletPickerPane } from '../components/memory/BookletPickerPane'
import { AuthService } from '../services/AuthService'
import { MemoryStore } from '../services/MemoryStore'

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
    t1.name = 'tag'
    t1.label = '归类'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'clock'
    t2.label = '回顾'
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
  @State reloadToken: number = 0
  @State showWrite: boolean = false
  @State writeId: string = ''
  @State detailId: string = ''
  @State bookletId: string = ''
  @State showBookletEdit: boolean = false
  @State editBookletId: string = ''
  @State showPicker: boolean = false
  @State pickerMode: string = 'intoBook'
  @State pickerRecordId: string = ''
  @State pickerBookletId: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '慧忆智能'
  @Prop appName: string = '慧忆册'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.reloadToken++
    this.syncBar()
  }

  private syncBar(): void {
    const hidden = this.showWrite || this.detailId.length > 0 || this.bookletId.length > 0 ||
      this.showBookletEdit || this.showPicker
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private openWrite(id: string): void {
    this.detailId = ''
    this.writeId = id
    this.showWrite = true
  }

  private openDetail(id: string): void {
    this.showWrite = false
    this.showPicker = false
    this.detailId = id
  }

  private openBooklet(id: string): void {
    this.showBookletEdit = false
    this.showPicker = false
    this.bookletId = id
  }

  private openCreateBooklet(): void {
    this.editBookletId = ''
    this.showBookletEdit = true
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            reloadToken: this.reloadToken,
            onOpenWrite: (): void => { this.openWrite('') },
            onOpenDetail: (id: string): void => { this.openDetail(id) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ClassifyPage({
            reloadToken: this.reloadToken,
            onOpenDetail: (id: string): void => { this.openDetail(id) },
            onChanged: (): void => { this.bump() },
            onOpenBooklet: (id: string): void => { this.openBooklet(id) },
            onCreateBooklet: (): void => { this.openCreateBooklet() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          ReviewPage({
            reloadToken: this.reloadToken,
            onOpenDetail: (id: string): void => { this.openDetail(id) }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            reloadToken: this.reloadToken,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
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
          .padding({ left: 8, right: 8, bottom: 6 })
          .margin({ left: 12, right: 12, bottom: 10 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({
            radius: 16,
            color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(26,109,245,0.10)',
            offsetX: 0,
            offsetY: -2
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showWrite) {
        MemoryWritePane({
          recordId: this.writeId,
          onClose: (): void => {
            this.showWrite = false
            this.syncBar()
          },
          onSaved: (): void => { this.bump() }
        })
      }

      if (this.bookletId.length > 0) {
        BookletDetailPane({
          bookletId: this.bookletId,
          reloadToken: this.reloadToken,
          onClose: (): void => {
            this.bookletId = ''
            this.syncBar()
          },
          onChanged: (): void => { this.bump() },
          onOpenDetail: (id: string): void => { this.openDetail(id) },
          onEditBooklet: (id: string): void => {
            this.editBookletId = id
            this.showBookletEdit = true
          },
          onPickRecord: (id: string): void => {
            this.pickerMode = 'intoMemory'
            this.pickerBookletId = id
            this.pickerRecordId = ''
            this.showPicker = true
          }
        })
      }

      if (this.detailId.length > 0) {
        MemoryDetailPane({
          recordId: this.detailId,
          onClose: (): void => {
            this.detailId = ''
            this.syncBar()
          },
          onChanged: (): void => { this.bump() },
          onEdit: (id: string): void => { this.openWrite(id) },
          onAddBooklet: (id: string): void => {
            this.pickerMode = 'intoBook'
            this.pickerRecordId = id
            this.pickerBookletId = ''
            this.showPicker = true
          },
          onOpenRelated: (id: string): void => { this.openDetail(id) }
        })
      }

      if (this.showBookletEdit) {
        BookletEditorSheet({
          bookletId: this.editBookletId,
          onClose: (): void => {
            this.showBookletEdit = false
            this.syncBar()
          },
          onSaved: (id: string): void => {
            this.bump()
            if (this.pickerRecordId.length > 0) {
              void MemoryStore.addToBooklet(id, this.pickerRecordId)
              this.pickerRecordId = ''
            }
            this.openBooklet(id)
          }
        })
      }

      if (this.showPicker) {
        BookletPickerPane({
          mode: this.pickerMode,
          recordId: this.pickerRecordId,
          bookletId: this.pickerBookletId,
          onClose: (): void => {
            this.showPicker = false
            this.syncBar()
          },
          onChanged: (): void => { this.bump() },
          onCreateBooklet: (): void => {
            this.showPicker = false
            this.openCreateBooklet()
          }
        })
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
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.bump()
    })
  }
}
