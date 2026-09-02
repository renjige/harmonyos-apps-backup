import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { Theme } from '../components/design-system/Theme'
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
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { WanderLocalStore } from '../services/WanderLocalStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '漫游生活')
    AppStorage.setOrCreate('appDisplayName', '夏日漫游')
    AppStorage.setOrCreate('appTagline', '用智慧的方式，记录每一个夏日漫游时刻')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('darkModeOn', false)
    AppStorage.setOrCreate('mainTabIndex', 0)
    AppStorage.setOrCreate('wanderDataRefresh', 0)
    AccessConfig.applyDefaults('open_optional')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await WanderLocalStore.init(this.context);
            const dark = await WanderLocalStore.loadDarkMode();
            AppStorage.setOrCreate('darkModeOn', dark);
            Theme.setColorMode(dark ? 'dark' : 'light');
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
