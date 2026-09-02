import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { TimelinePage } from './TimelinePage'
import { CalendarPage } from './CalendarPage'
import { StatsPage } from './StatsPage'
import { SettingsPage } from './SettingsPage'
import { DiaryEditorPage } from './DiaryEditorPage'
import { DiaryEntry } from '../models/DiaryModels'
import { DateHelper } from '../services/DateHelper'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '日记'],
      ['1', 'calendar', '日历'],
      ['2', 'chart', '统计'],
      ['3', 'user', '设置']
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
  @State showEditor: boolean = false
  @State editorEntryId: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 16

  private openCreate(): void {
    const e = DiaryEntry.createNew(DateHelper.todayKey())
    this.editorEntryId = e.id
    this.showEditor = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openEditor(id: string): void {
    this.editorEntryId = id
    this.showEditor = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeEditor(): void {
    this.showEditor = false
    this.editorEntryId = ''
    AppStorage.setOrCreate('tabBarHidden', false)
    this.refreshToken++
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          TimelinePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onOpenEditor: (id: string) => this.openEditor(id),
            onCreateNew: () => this.openCreate()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          CalendarPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else if (this.current === 2) {
          StatsPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else {
          SettingsPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
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
          .padding({ bottom: this.tabSafeBottom })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showEditor) {
        DiaryEditorPage({
          entryId: this.editorEntryId,
          onClose: () => this.closeEditor(),
          onSaved: () => { this.refreshToken++ }
        })
      }
    }
    .width('100%')
    .height('100%')
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
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
