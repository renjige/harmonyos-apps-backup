import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { GoalDetailPane } from '../components/detail/GoalDetailPane'
import { PlanDetailPane } from '../components/detail/PlanDetailPane'
import { HabitDetailPane } from '../components/detail/HabitDetailPane'
import { JournalDetailPane } from '../components/detail/JournalDetailPane'
import { GoalEditorSheet } from '../components/detail/GoalEditorSheet'
import { PlanEditorSheet } from '../components/detail/PlanEditorSheet'
import { HabitRecordSheet } from '../components/detail/HabitRecordSheet'
import { JournalEditorSheet } from '../components/detail/JournalEditorSheet'
import { PhaseReviewSheet } from '../components/detail/PhaseReviewSheet'
import { GlobalSearchSheet } from '../components/search/GlobalSearchSheet'
import { OrganizeSheet } from '../components/organize/OrganizeSheet'
import { YearArchiveSheet } from '../components/lookback/YearArchiveSheet'
import { HomePage } from './HomePage'
import { PlanPage } from './PlanPage'
import { GrowthPage } from './GrowthPage'
import { LookbackPage } from './LookbackPage'
import { MinePage } from './MinePage'
import { AchievementsPage } from './AchievementsPage'
import { ChenwuDetailNav } from '../services/ChenwuDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '晨雾'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'calendar'
    t1.label = '计划'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'book'
    t2.label = '成长'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
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
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('cwGoalId') goalId: string = ''
  @StorageLink('cwPlanId') planId: string = ''
  @StorageLink('cwHabitId') habitId: string = ''
  @StorageLink('cwJournalId') journalId: string = ''
  @StorageLink('cwGoalEditorOpen') goalEditorOpen: boolean = false
  @StorageLink('cwPlanEditorOpen') planEditorOpen: boolean = false
  @StorageLink('cwHabitRecordOpen') habitRecordOpen: boolean = false
  @StorageLink('cwJournalEditorOpen') journalEditorOpen: boolean = false
  @StorageLink('cwReviewSheetOpen') reviewSheetOpen: boolean = false
  @StorageLink('cwReviewPhaseId') reviewPhaseId: string = ''
  @StorageLink('cwSearchOpen') searchOpen: boolean = false
  @StorageLink('cwOrganizeOpen') organizeOpen: boolean = false
  @StorageLink('cwAnnualOpen') annualOpen: boolean = false
  @StorageLink('cwAchievementsOpen') achievementsOpen: boolean = false
  @StorageProp('cwDataRev') @Watch('onGlobalDataRev') dataRev: number = 0
  @StorageLink('cwActiveTab') @Watch('onActiveTab') activeTab: number = 0
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

  onActiveTab(): void {
    if (this.activeTab >= 1 && this.activeTab <= 4) {
      this.current = this.activeTab
      AppStorage.setOrCreate('cwActiveTab', 0)
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ refreshToken: this.dataRefresh, bottomInset: 76 }).layoutWeight(1)
        } else if (this.current === 1) {
          PlanPage({ refreshToken: this.dataRefresh, bottomInset: 76 }).layoutWeight(1)
        } else if (this.current === 2) {
          GrowthPage({ refreshToken: this.dataRefresh, bottomInset: 76 }).layoutWeight(1)
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
                this.bump()
              })
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .margin({ left: 16, right: 16, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(61,90,108,0.12)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.searchOpen) {
        GlobalSearchSheet()
      }
      if (this.organizeOpen) {
        OrganizeSheet()
      }
      if (this.annualOpen) {
        YearArchiveSheet()
      }
      if (this.achievementsOpen) {
        DetailShell({ title: '成就墙', onClose: (): void => { ChenwuDetailNav.closeAchievements() } }) {
          AchievementsPage()
        }
      }
      if (this.reviewSheetOpen && this.reviewPhaseId.length > 0) {
        PhaseReviewSheet({ onChanged: (): void => { this.bump() } })
      }
      if (this.goalId.length > 0 && !this.goalEditorOpen && !this.planEditorOpen) {
        DetailShell({ title: '目标', onClose: (): void => { ChenwuDetailNav.closeGoal() } }) {
          GoalDetailPane({ goalId: this.goalId, onChanged: (): void => { this.bump() } })
        }
      }
      if (this.planId.length > 0 && !this.planEditorOpen) {
        DetailShell({ title: '计划', onClose: (): void => { ChenwuDetailNav.closePlan() } }) {
          PlanDetailPane({ planId: this.planId, onChanged: (): void => { this.bump() } })
        }
      }
      if (this.habitId.length > 0 && !this.habitRecordOpen) {
        DetailShell({ title: '习惯', onClose: (): void => { ChenwuDetailNav.closeHabit() } }) {
          HabitDetailPane({ habitId: this.habitId, onChanged: (): void => { this.bump() } })
        }
      }
      if (this.journalId.length > 0 && !this.journalEditorOpen) {
        DetailShell({ title: '晨记', onClose: (): void => { ChenwuDetailNav.closeJournal() } }) {
          JournalDetailPane({ journalId: this.journalId, onChanged: (): void => { this.bump() } })
        }
      }
      if (this.goalEditorOpen) {
        GoalEditorSheet({ onChanged: (): void => { this.bump() } })
      }
      if (this.planEditorOpen) {
        PlanEditorSheet({ onChanged: (): void => { this.bump() } })
      }
      if (this.habitRecordOpen) {
        HabitRecordSheet({ onChanged: (): void => { this.bump() } })
      }
      if (this.journalEditorOpen) {
        JournalEditorSheet({ onChanged: (): void => { this.bump() } })
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
