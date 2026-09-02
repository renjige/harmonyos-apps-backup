import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { RecordDetailPane } from '../components/detail/RecordDetailPane'
import { MilestoneDetailPane } from '../components/detail/MilestoneDetailPane'
import { InsightDetailPane } from '../components/detail/InsightDetailPane'
import { RecordEditorSheet } from '../components/saitu/RecordEditorSheet'
import { JourneyManageSheet } from '../components/saitu/JourneyManageSheet'
import { MilestoneEditorSheet } from '../components/saitu/MilestoneEditorSheet'
import { SportEventDetail } from '../components/sport/SportEventDetail'
import { SportEventEditor } from '../components/sport/SportEventEditor'
import { SportAlbumDetail, SportAlbumEditor } from '../components/sport/SportAlbumPane'
import { SportFollowSheet } from '../components/sport/SportFollowSheet'
import { CheckInEditorSheet } from '../components/growth/CheckInEditorSheet'
import { PlanEditorSheet } from '../components/growth/PlanEditorSheet'
import { PlanDetailPane } from '../components/detail/PlanDetailPane'
import { JourneyDetailPane } from '../components/detail/JourneyDetailPane'
import { FollowDetailPane } from '../components/detail/FollowDetailPane'
import { TrainingLogEditor } from '../components/sport/TrainingLogEditor'
import { TrainingLogDetail } from '../components/sport/TrainingLogDetail'
import { TimelinePage } from './TimelinePage'
import { ScenarioGuidePage } from './ScenarioGuidePage'
import { Journey, SaituRecord } from '../models/SaituModels'
import { HomePage } from './HomePage'
import { ArchivePage } from './ArchivePage'
import { JourneyPage } from './JourneyPage'
import { GrowthPage } from './GrowthPage'
import { SportPage } from './SportPage'
import { SportComposerSheet } from '../components/sport/SportComposerSheet'
import { SettingsPage } from './SettingsPage'
import { SaituLocalStore } from '../services/SaituLocalStore'
import { SaituDetailNav } from '../services/SaituDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'biz', '档案'],
      ['2', 'chart', '赛途'],
      ['3', 'ai', '成长'],
      ['4', 'user', '我的']
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
  @StorageLink('saituDetailOpen') @Watch('onDetailOpenChange') detailOpen: boolean = false
  @StorageLink('saituEditorOpen') editorOpen: boolean = false
  @StorageLink('saituEditorSession') editorSession: number = 0
  @StorageLink('saituSportEditorSession') sportEditorSession: number = 0
  @StorageLink('saituJourneyManageOpen') journeyManageOpen: boolean = false
  @StorageLink('saituMilestoneOpen') milestoneOpen: boolean = false
  @StorageLink('saituMilestoneEditorOpen') milestoneEditorOpen: boolean = false
  @StorageLink('saituInsightDetailOpen') insightOpen: boolean = false
  @StorageLink('saituSportDetailOpen') sportDetailOpen: boolean = false
  @StorageLink('saituSportEditorOpen') sportEditorOpen: boolean = false
  @StorageLink('saituAlbumDetailOpen') albumDetailOpen: boolean = false
  @StorageLink('saituAlbumEditorOpen') albumEditorOpen: boolean = false
  @StorageLink('saituFollowOpen') followOpen: boolean = false
  @StorageLink('saituTimelineOpen') timelineOpen: boolean = false
  @StorageLink('saituCheckInEditorOpen') checkInEditorOpen: boolean = false
  @StorageLink('saituPlanEditorOpen') planEditorOpen: boolean = false
  @StorageLink('saituPlanOpen') planOpen: boolean = false
  @StorageLink('saituPlanId') planId: string = ''
  @StorageLink('saituSportHubOpen') sportHubOpen: boolean = false
  @StorageLink('saituSportComposerOpen') sportComposerOpen: boolean = false
  @StorageLink('saituJourneyDetailOpen') journeyDetailOpen: boolean = false
  @StorageLink('saituFollowDetailOpen') followDetailOpen: boolean = false
  @StorageLink('saituTrainingDetailOpen') trainingDetailOpen: boolean = false
  @StorageLink('saituTrainingEditorOpen') trainingEditorOpen: boolean = false
  @StorageLink('saituTrainingEditorSession') trainingEditorSession: number = 0
  @StorageLink('saituScenarioOpen') scenarioOpen: boolean = false
  @StorageLink('saituJourneyDetailId') journeyDetailId: string = ''
  @StorageLink('saituFollowDetailId') followDetailId: string = ''
  @StorageLink('saituTrainingDetailId') trainingDetailId: string = ''
  @StorageLink('saituDetailRecordId') @Watch('onDetailIdChange') detailRecordId: string = ''
  @StorageLink('saituEditorRecordId') editorRecordId: string = ''
  @StorageLink('saituMilestoneId') milestoneId: string = ''
  @StorageLink('saituMilestoneEditorId') milestoneEditorId: string = ''
  @StorageLink('saituMilestoneJourneyId') milestoneJourneyId: string = ''
  @StorageLink('saituInsightId') insightId: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('saituMainTab') @Watch('onMainTabChange') mainTab: number = -1
  @State current: number = 0
  @State refreshToken: number = 0
  @State detailRecord: SaituRecord = new SaituRecord()
  @State detailJourney: Journey | null = null
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 28

  aboutToAppear(): void {
    AppStorage.setOrCreate('saituDetailOpen', false)
    AppStorage.setOrCreate('saituEditorOpen', false)
    AppStorage.setOrCreate('saituJourneyManageOpen', false)
    AppStorage.setOrCreate('saituMilestoneOpen', false)
    AppStorage.setOrCreate('saituMilestoneEditorOpen', false)
    AppStorage.setOrCreate('saituInsightDetailOpen', false)
    AppStorage.setOrCreate('saituSportDetailOpen', false)
    AppStorage.setOrCreate('saituSportEditorOpen', false)
    AppStorage.setOrCreate('saituAlbumDetailOpen', false)
    AppStorage.setOrCreate('saituAlbumEditorOpen', false)
    AppStorage.setOrCreate('saituFollowOpen', false)
    AppStorage.setOrCreate('saituTimelineOpen', false)
    AppStorage.setOrCreate('saituCheckInEditorOpen', false)
    AppStorage.setOrCreate('saituPlanEditorOpen', false)
    AppStorage.setOrCreate('saituPlanOpen', false)
    AppStorage.setOrCreate('saituPlanId', '')
    AppStorage.setOrCreate('saituPlanEditorId', '')
    AppStorage.setOrCreate('saituPlanJourneyId', '')
    AppStorage.setOrCreate('saituCheckInJourneyId', '')
    AppStorage.setOrCreate('saituSportHubOpen', false)
    AppStorage.setOrCreate('saituSportComposerOpen', false)
    AppStorage.setOrCreate('saituJourneyDetailOpen', false)
    AppStorage.setOrCreate('saituFollowDetailOpen', false)
    AppStorage.setOrCreate('saituTrainingDetailOpen', false)
    AppStorage.setOrCreate('saituTrainingEditorOpen', false)
    AppStorage.setOrCreate('saituJourneyDetailId', '')
    AppStorage.setOrCreate('saituFollowDetailId', '')
    AppStorage.setOrCreate('saituTrainingDetailId', '')
    AppStorage.setOrCreate('saituTrainingEditorSession', 0)
    AppStorage.setOrCreate('saituScenarioOpen', false)
    AppStorage.setOrCreate('saituJourneyEpoch', 0)
    AppStorage.setOrCreate('saituTrackEpoch', 0)
    AppStorage.setOrCreate('saituSportEditorKind', 'record')
    AppStorage.setOrCreate('saituSportEditorAlbumId', '')
    AppStorage.setOrCreate('saituEditorSession', 0)
    AppStorage.setOrCreate('saituSportEditorSession', 0)
    AppStorage.setOrCreate('saituMainTab', -1)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  onMainTabChange(): void {
    if (this.mainTab >= 0 && this.mainTab <= 4) {
      this.current = this.mainTab
      AppStorage.setOrCreate('saituMainTab', -1)
    }
  }

  onDetailOpenChange(): void {
    if (this.detailOpen) {
      void this.loadDetail()
    }
  }

  onDetailIdChange(): void {
    if (this.detailOpen) {
      void this.loadDetail()
    }
  }

  private bumpRefresh(): void {
    this.refreshToken++
  }

  private async afterRecordSaved(): Promise<void> {
    await this.loadDetail()
    this.bumpRefresh()
  }

  private async loadDetail(): Promise<void> {
    if (this.detailRecordId.length === 0) {
      return
    }
    const found = await SaituLocalStore.findRecord(this.detailRecordId)
    if (found !== undefined) {
      this.detailRecord = found
      const j = await SaituLocalStore.findJourney(found.journeyId)
      this.detailJourney = j !== undefined ? j : null
    }
  }

  private async deleteDetail(): Promise<void> {
    if (this.detailRecordId.length === 0) {
      return
    }
    await SaituLocalStore.deleteRecord(this.detailRecordId)
    SaituDetailNav.closeDetail()
    this.bumpRefresh()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ refreshToken: this.refreshToken, bottomInset: this.tabBarHeight + this.tabSafeBottom })
            .layoutWeight(1)
        } else if (this.current === 1) {
          ArchivePage({ refreshToken: this.refreshToken, bottomInset: this.tabBarHeight + this.tabSafeBottom })
            .layoutWeight(1)
        } else if (this.current === 2) {
          JourneyPage({ refreshToken: this.refreshToken, bottomInset: this.tabBarHeight + this.tabSafeBottom })
            .layoutWeight(1)
        } else if (this.current === 3) {
          GrowthPage({ refreshToken: this.refreshToken, bottomInset: this.tabBarHeight + this.tabSafeBottom })
            .layoutWeight(1)
        } else {
          SettingsPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onDataCleared: (): void => this.bumpRefresh()
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}_${this.themeEpoch}`)
          }
          .width('100%')
          .height(this.tabBarHeight)
          .padding({ left: Theme.space.s2, right: Theme.space.s2, bottom: this.tabSafeBottom })
          .margin({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s2 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(44,44,44,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.detailOpen) {
        RecordDetailPane({
          record: this.detailRecord,
          journey: this.detailJourney,
          onClose: (): void => SaituDetailNav.closeDetail(),
          onEdit: (): void => {
            if (this.detailRecordId.length > 0) {
              SaituDetailNav.openEditor(this.detailRecordId)
            }
          },
          onDelete: (): void => { void this.deleteDetail() },
          onShare: (): void => {},
          onFavoriteChanged: (): void => this.bumpRefresh()
        })
      }
      if (this.milestoneOpen) {
        MilestoneDetailPane({
          milestoneId: this.milestoneId,
          onChanged: (): void => this.bumpRefresh()
        })
      }
      if (this.insightOpen) {
        InsightDetailPane({
          insightId: this.insightId,
          onChanged: (): void => this.bumpRefresh()
        })
      }
      if (this.sportDetailOpen) {
        SportEventDetail({ onChanged: (): void => this.bumpRefresh() })
      }
      if (this.albumDetailOpen) {
        SportAlbumDetail({ onChanged: (): void => this.bumpRefresh() })
      }
      if (this.timelineOpen) {
        TimelinePage({ refreshToken: this.refreshToken, onChanged: (): void => this.bumpRefresh() })
      }
      if (this.planOpen) {
        PlanDetailPane({ planId: this.planId, onChanged: (): void => this.bumpRefresh() })
      }
      if (this.journeyDetailOpen) {
        JourneyDetailPane({ onChanged: (): void => this.bumpRefresh() })
      }
      if (this.followDetailOpen) {
        FollowDetailPane({ onChanged: (): void => this.bumpRefresh() })
      }
      if (this.trainingDetailOpen) {
        TrainingLogDetail({ onChanged: (): void => this.bumpRefresh() })
      }
      if (this.scenarioOpen) {
        ScenarioGuidePage()
      }
      if (this.sportHubOpen) {
        SportPage({ refreshToken: this.refreshToken, bottomInset: 0 })
      }
      if (this.sportComposerOpen) {
        SportComposerSheet()
      }
      if (this.journeyManageOpen) {
        JourneyManageSheet({ onChanged: (): void => this.bumpRefresh() })
      }
      if (this.editorOpen) {
        RecordEditorSheet({
          editorSession: this.editorSession,
          onSaved: (): void => { void this.afterRecordSaved() }
        })
      }
      if (this.milestoneEditorOpen) {
        MilestoneEditorSheet({
          milestoneId: this.milestoneEditorId,
          journeyId: this.milestoneJourneyId,
          onSaved: (): void => this.bumpRefresh()
        })
      }
      if (this.sportEditorOpen) {
        SportEventEditor({
          editorSession: this.sportEditorSession,
          onSaved: (): void => this.bumpRefresh()
        })
      }
      if (this.albumEditorOpen) {
        SportAlbumEditor({ onSaved: (): void => this.bumpRefresh() })
      }
      if (this.followOpen) {
        SportFollowSheet({ onChanged: (): void => this.bumpRefresh() })
      }
      if (this.checkInEditorOpen) {
        CheckInEditorSheet({ onSaved: (): void => this.bumpRefresh() })
      }
      if (this.planEditorOpen) {
        PlanEditorSheet({ onSaved: (): void => this.bumpRefresh() })
      }
      if (this.trainingEditorOpen) {
        TrainingLogEditor({
          editorSession: this.trainingEditorSession,
          onSaved: (): void => this.bumpRefresh()
        })
      }
    }
    .width('100%')
    .height('100%')
    .onVisibleAreaChange([0.0, 1.0], (): void => {
      if (this.detailOpen) {
        void this.loadDetail()
      }
    })
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
      .width(40)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : Color.Transparent)
      .borderRadius(Theme.radius.md)
      Text(t.label)
        .fontSize(10)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 4, bottom: 2 })
    .onClick((): void => { this.current = t.index })
  }
}
