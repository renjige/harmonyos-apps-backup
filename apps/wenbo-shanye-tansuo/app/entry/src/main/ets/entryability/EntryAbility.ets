import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '魏文波')
    AppStorage.setOrCreate('appDisplayName', '山野探索')
    AppStorage.setOrCreate('appTagline', '为徒步与骑行爱好者匹配山野路线，并用自然百科读懂沿途的植物、地质与星空')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('switchTabIndex', -1)
    AppStorage.setOrCreate('prefDifficulty', '中级')
    AppStorage.setOrCreate('prefInterest', '地质')
    AppStorage.setOrCreate('prefDuration', 'half')
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGateActions', 'favorite_trail,mark_footprint')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
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
