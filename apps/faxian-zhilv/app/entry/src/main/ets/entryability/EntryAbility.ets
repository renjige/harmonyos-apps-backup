import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { WanderLocalStore } from '../services/WanderLocalStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { WanderLocalStore } from '../services/WanderLocalStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '发现科技')
    AppStorage.setOrCreate('appDisplayName', '发现之旅')
    AppStorage.setOrCreate('appTagline', '让每一次出行，都成为发现之旅')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('detailRoute', '')
    AccessConfig.applyDefaults('open_optional')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await WanderLocalStore.init(this.context);
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
