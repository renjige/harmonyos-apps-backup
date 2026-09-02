import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { LocalRecordStore } from '../services/LocalRecordStore'
import { FavoriteStore } from '../services/FavoriteStore'
import { ResearchStore } from '../services/ResearchStore'
import { HubStore } from '../services/HubStore'
import { AppStoreContext } from '../services/AppStoreContext'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('themeEpoch', 0)
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '魏文波')
    AppStorage.setOrCreate('appDisplayName', '研语')
    AppStorage.setOrCreate('appTagline', '润色表达，也把学习与思考沉淀成自己的研究资料。')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('researchPanel', '')
    AppStorage.setOrCreate('researchItemId', '')
    AppStorage.setOrCreate('researchDraftTopicId', '')
    AppStorage.setOrCreate('researchRefresh', 0)
    AppStorage.setOrCreate('researchHubRefresh', 0)
    AppStorage.setOrCreate('detailInspirationId', '')
    AppStorage.setOrCreate('detailStyleKey', '')
    AppStorage.setOrCreate('showHistory', false)
    AppStorage.setOrCreate('historyTab', 'polish')
    AppStorage.setOrCreate('expressToast', '')
    AppStorage.setOrCreate('expressToastTick', 0)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showDraft', false)
    AppStorage.setOrCreate('showScenarioLibrary', false)
    AppStorage.setOrCreate('showUseCaseGuide', false)
    AppStorage.setOrCreate('expressBannerDismissed', false)
    AppStorage.setOrCreate('summarySeedText', '')
    AppStorage.setOrCreate('summaryModeSeed', '')
    AppStorage.setOrCreate('showManuscripts', false)
    AppStorage.setOrCreate('expressSegment', 0)
    AppStorage.setOrCreate('hubRefresh', 0)
    AppStorage.setOrCreate('recordRefresh', 0)
    AppStorage.setOrCreate('favRefresh', 0)
    AppStorage.setOrCreate('storesReady', false)
    AppStorage.setOrCreate('mainTabIndex', 0)
    AppStorage.setOrCreate('polishSeedText', '')
    AppStorage.setOrCreate('polishStyleKey', '')
    AppStorage.setOrCreate('colorMode', 'light')
    AppStorage.setOrCreate('darkModeOn', false)
    AccessConfig.applyDefaults('open_optional')
    Theme.applyBrandPrimary('#1A3A5C')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStoreContext.bind(this.context)
    SessionStore.init(this.context).then(async () => {
      ThemeAppearance.applyStored(this.context)
      await LocalRecordStore.init(this.context)
      await FavoriteStore.init(this.context)
      await ResearchStore.init(this.context)
      await HubStore.init(this.context)
      AppStorage.setOrCreate('storesReady', true)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      ThemeAppearance.apply('light', this.context)
      try {
        await LocalRecordStore.init(this.context)
        await FavoriteStore.init(this.context)
        await ResearchStore.init(this.context)
        await HubStore.init(this.context)
        AppStorage.setOrCreate('storesReady', true)
      } catch {
        AppStorage.setOrCreate('storesReady', false)
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    })
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config)
  }
}
