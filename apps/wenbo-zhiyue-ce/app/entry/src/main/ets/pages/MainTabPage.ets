import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ExcerptListPage } from './ExcerptListPage'
import { FolioListPage } from './FolioListPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { ReaderPane } from '../components/read/ReaderPane'
import { PasteDocSheet } from '../components/read/PasteDocSheet'
import { ExcerptEditorSheet } from '../components/excerpt/ExcerptEditorSheet'
import { ExcerptDetailPane } from '../components/excerpt/ExcerptDetailPane'
import { FolioEditorSheet } from '../components/folio/FolioEditorSheet'
import { FolioDetailPane } from '../components/folio/FolioDetailPane'
import { AuthService } from '../services/AuthService'
import { FolioStore } from '../services/FolioStore'
import { ExcerptItem } from '../models/FolioModels'
import { DiagnoseReport } from '../models/DiagnoseModels'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'book'
    t0.label = '阅读'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'bookmark'
    t1.label = '摘录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'grid'
    t2.label = '知识册'
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
  @State current: number = 0
  @State reloadToken: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State readerId: string = ''
  @State pasteId: string = ''
  @State showPaste: boolean = false
  @State excerptId: string = ''
  @State excerptEditId: string = ''
  @State excerptDocId: string = ''
  @State excerptFolioId: string = ''
  @State showExcerptEdit: boolean = false
  @State folioId: string = ''
  @State folioEditId: string = ''
  @State showFolioEdit: boolean = false
  @State showDiagnose: boolean = false
  @State showMessages: boolean = false
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '智阅册'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.reloadToken++
    this.syncBar()
  }

  private async openMatchedFolio(report: DiagnoseReport): Promise<void> {
    const saved = await FolioStore.saveRhythmFromReport(report)
    this.showDiagnose = false
    this.showFolioEdit = false
    this.current = 2
    this.folioId = saved.folio.id
    this.syncBar()
    this.bump()
  }

  private overlayOpen(): boolean {
    return this.readerId.length > 0 || this.showPaste || this.excerptId.length > 0 ||
      this.showExcerptEdit || this.folioId.length > 0 || this.showFolioEdit ||
      this.showDiagnose || this.showMessages
  }

  private syncBar(): void {
    AppStorage.setOrCreate('tabBarHidden', this.overlayOpen())
  }

  private async openRandom(): Promise<void> {
    const it: ExcerptItem | undefined = await FolioStore.randomExcerpt()
    if (it === undefined) {
      this.toastText = '还没有摘录可回顾'
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    this.excerptId = it.id
    this.syncBar()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            reloadToken: this.reloadToken,
            onOpenReader: (id: string): void => {
              this.readerId = id
              this.syncBar()
            },
            onOpenPaste: (id: string): void => {
              this.pasteId = id
              this.showPaste = true
              this.syncBar()
            },
            onOpenExcerpt: (id: string): void => {
              this.excerptId = id
              this.syncBar()
            },
            onOpenDiagnose: (): void => {
              this.showDiagnose = true
              this.syncBar()
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ExcerptListPage({
            reloadToken: this.reloadToken,
            onOpenDetail: (id: string): void => {
              this.excerptId = id
              this.syncBar()
            },
            onWrite: (): void => {
              this.excerptEditId = ''
              this.excerptDocId = this.readerId
              this.showExcerptEdit = true
              this.syncBar()
            },
            onRandom: (): void => { void this.openRandom() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          FolioListPage({
            reloadToken: this.reloadToken,
            onOpenDetail: (id: string): void => {
              this.folioId = id
              this.syncBar()
            },
            onCreate: (): void => {
              this.folioEditId = ''
              this.showFolioEdit = true
              this.syncBar()
            }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            reloadToken: this.reloadToken,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
            },
            onOpenDiagnose: (): void => {
              this.showDiagnose = true
              this.syncBar()
            },
            onOpenMessages: (): void => {
              this.showMessages = true
              this.syncBar()
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
          .margin({ left: 12, right: 12, bottom: 28 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({
            radius: 16,
            color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(45,62,80,0.12)',
            offsetX: 0,
            offsetY: 4
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.readerId.length > 0) {
        ReaderPane({
          docId: this.readerId,
          onClose: (): void => {
            this.readerId = ''
            this.bump()
          },
          onExcerpt: (id: string): void => {
            this.excerptDocId = id
            this.excerptEditId = ''
            this.showExcerptEdit = true
          },
          onNeedBody: (id: string): void => {
            this.pasteId = id
            this.showPaste = true
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showPaste) {
        PasteDocSheet({
          editId: this.pasteId,
          onClose: (): void => {
            this.showPaste = false
            this.syncBar()
          },
          onSaved: (id: string): void => {
            this.showPaste = false
            this.readerId = id
            this.bump()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.excerptId.length > 0) {
        ExcerptDetailPane({
          excerptId: this.excerptId,
          onClose: (): void => {
            this.excerptId = ''
            this.bump()
          },
          onChanged: (): void => { this.reloadToken++ },
          onEdit: (id: string): void => {
            this.excerptEditId = id
            this.excerptFolioId = ''
            this.showExcerptEdit = true
            this.syncBar()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.folioId.length > 0) {
        FolioDetailPane({
          folioId: this.folioId,
          onClose: (): void => {
            this.folioId = ''
            this.bump()
          },
          onChanged: (): void => { this.reloadToken++ },
          onEdit: (id: string): void => {
            this.folioEditId = id
            this.showFolioEdit = true
            this.syncBar()
          },
          onWriteExcerpt: (id: string): void => {
            this.excerptEditId = ''
            this.excerptDocId = ''
            this.excerptFolioId = id
            this.showExcerptEdit = true
            this.syncBar()
          },
          onOpenExcerpt: (id: string): void => {
            this.excerptId = id
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showExcerptEdit) {
        ExcerptEditorSheet({
          editId: this.excerptEditId,
          docId: this.excerptDocId,
          defaultFolioId: this.excerptFolioId,
          onClose: (): void => {
            this.showExcerptEdit = false
            this.excerptFolioId = ''
            this.syncBar()
          },
          onSaved: (): void => {
            this.showExcerptEdit = false
            this.excerptFolioId = ''
            this.bump()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showFolioEdit) {
        FolioEditorSheet({
          editId: this.folioEditId,
          onClose: (): void => {
            this.showFolioEdit = false
            this.syncBar()
          },
          onSaved: (): void => {
            this.showFolioEdit = false
            this.bump()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showDiagnose) {
        Column() {
          AIAssistantPage({
            onRequireAuth: (): void => { this.onRequireAuth() },
            onClose: (): void => {
              this.showDiagnose = false
              this.syncBar()
            },
            onBookFromAi: (report: DiagnoseReport): void => {
              void this.openMatchedFolio(report)
            }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
      }

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => {
            this.showMessages = false
            this.syncBar()
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 40 })
      }
    }
    .width('100%')
    .height('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
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
    .padding({ top: 4, bottom: 4 })
    .onClick((): void => {
      this.current = t.index
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }
}
