import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { TeaDetailPane } from '../components/detail/TeaDetailPane'
import { TastingDetailPane } from '../components/detail/TastingDetailPane'
import { TeaEditorSheet } from '../components/detail/TeaEditorSheet'
import { TastingEditorSheet } from '../components/detail/TastingEditorSheet'
import { SearchSheet, ListHubSheet, AlbumHubSheet, PlanHubSheet, OrganizeSheet } from '../components/mine/HubSheets'
import { HomePage } from './HomePage'
import { CabinetPage } from './CabinetPage'
import { RecordPage } from './RecordPage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { TeaNav } from '../services/TeaNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '茶库'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'check'
    t2.label = '记录'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'calendar'
    t3.label = '回顾'
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
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('teaDetailId') teaDetailId: string = ''
  @StorageLink('tastingDetailId') tastingDetailId: string = ''
  @StorageLink('teaEditorOpen') teaEditorOpen: boolean = false
  @StorageLink('teaEditorId') teaEditorId: string = ''
  @StorageLink('tastingEditorOpen') tastingEditorOpen: boolean = false
  @StorageLink('tastingEditorTeaId') tastingEditorTeaId: string = ''
  @StorageLink('tastingEditorId') tastingEditorId: string = ''
  @StorageLink('searchOpen') searchOpen: boolean = false
  @StorageLink('listSheetOpen') listSheetOpen: boolean = false
  @StorageLink('albumSheetOpen') albumSheetOpen: boolean = false
  @StorageLink('planSheetOpen') planSheetOpen: boolean = false
  @StorageLink('organizeOpen') organizeOpen: boolean = false
  onPrivacyRevoked: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  @Builder
  TeaDetailBody() {
    // 详情页自行 @StorageLink 读 id，勿再透传 @Prop（BuilderParam 易传空）
    TeaDetailPane({ onChanged: (): void => {} })
  }

  @Builder
  TastingDetailBody() {
    TastingDetailPane({ onChanged: (): void => {} })
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: 22,
          active: this.current === t.index,
          color: this.current === t.index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
        })
      }
      .width(36)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .borderRadius(Theme.radius.pill)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimary : 'transparent')
      Text(t.label)
        .fontSize(10)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height(56)
    .justifyContent(FlexAlign.Center)
    .onClick((): void => { this.current = t.index })
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage().layoutWeight(1)
        } else if (this.current === 1) {
          CabinetPage().layoutWeight(1)
        } else if (this.current === 2) {
          RecordPage().layoutWeight(1)
        } else if (this.current === 3) {
          ReviewPage().layoutWeight(1)
        } else {
          MinePage({ onPrivacyRevoked: (): void => { this.onPrivacyRevoked() } }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(60)
          .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: 10 })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.teaDetailId.length > 0) {
        DetailShell({
          title: '茶品档案',
          onClose: (): void => { TeaNav.closeTea() },
          body: this.TeaDetailBody
        })
          .width('100%')
          .height('100%')
      }

      if (this.tastingDetailId.length > 0) {
        DetailShell({
          title: '品饮记录',
          onClose: (): void => { TeaNav.closeTasting() },
          body: this.TastingDetailBody
        })
          .width('100%')
          .height('100%')
      }

      if (this.teaEditorOpen) {
        TeaEditorSheet({ teaId: this.teaEditorId, onSaved: (): void => {} })
          .width('100%')
          .height('100%')
      }

      if (this.tastingEditorOpen) {
        TastingEditorSheet({
          teaId: this.tastingEditorTeaId,
          tastingId: this.tastingEditorId,
          onSaved: (): void => {}
        })
          .width('100%')
          .height('100%')
      }

      if (this.searchOpen) {
        SearchSheet().width('100%').height('100%')
      }
      if (this.listSheetOpen) {
        ListHubSheet().width('100%').height('100%')
      }
      if (this.albumSheetOpen) {
        AlbumHubSheet().width('100%').height('100%')
      }
      if (this.planSheetOpen) {
        PlanHubSheet().width('100%').height('100%')
      }
      if (this.organizeOpen) {
        OrganizeSheet().width('100%').height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
