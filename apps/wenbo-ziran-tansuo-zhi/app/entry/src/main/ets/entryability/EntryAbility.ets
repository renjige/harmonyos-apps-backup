import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { ExploreRecordStore } from '../services/ExploreRecordStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { ExploreRecordStore } from '../services/ExploreRecordStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '薛茂新')
    AppStorage.setOrCreate('appDisplayName', '自然探索志')
    AppStorage.setOrCreate('appTagline', '探索自然之美，记录户外足迹，发现身边森林山川与观星秘境的随身自然指南')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('detailToken', 0)
    AppStorage.setOrCreate('switchTabIndex', -1)
    AppStorage.setOrCreate('recordRefreshToken', 0)
    AppStorage.setOrCreate('prefInterest', 'forest')
    AppContextService.setContext(this.context)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGateActions', 'sync,favorite_trail')
    Theme.applyBrandPrimary('#2D5A27')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await ExploreRecordStore.init(this.context);
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
                };
            });
        }).catch(() => {;
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
                };
            });
        });
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
