import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { PavilionStore } from '../services/PavilionStore';
import { ExploreStore } from '../services/ExploreStore';
import { JournalStore } from '../services/JournalStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    AppStorage.setOrCreate('darkModeOn', false)
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '魏文波')
    AppStorage.setOrCreate('appDisplayName', '识趣阁')
    AppStorage.setOrCreate('appTagline', '发现生活中有趣的知识与智慧')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('detailToken', 0)
    AppStorage.setOrCreate('showMineSettings', false)
    AppStorage.setOrCreate('pavilionRefresh', 0)
    AppStorage.setOrCreate('mainTabIndex', 0)
    Theme.applyBrandPrimary('#8B7A6B')
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessGateActions', 'sync_favorites')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.host = this.context
    SessionStore.init(this.context).then(async () => {
      await PavilionStore.init(this.context)
      await ExploreStore.init(this.context)
      await JournalStore.init(this.context)
      const dark = AppStorage.get<boolean>('darkModeOn') === true
      ThemeAppearance.apply(dark ? 'dark' : 'light', this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(() => {
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
