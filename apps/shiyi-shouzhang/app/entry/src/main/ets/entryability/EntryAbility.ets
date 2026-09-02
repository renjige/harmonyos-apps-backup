import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { ShiyiStore } from '../services/ShiyiStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { ShiyiStore } from '../services/ShiyiStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '拾意生活')
    AppStorage.setOrCreate('appDisplayName', '手账拾意')
    AppStorage.setOrCreate('appTagline', '拾起生活里的小事，记录值得留下的心意。')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('shiyiShowCompose', false)
    AppStorage.setOrCreate('shiyiShowDetail', false)
    AppStorage.setOrCreate('shiyiShowPickup', false)
    AppStorage.setOrCreate('shiyiShowTags', false)
    AppStorage.setOrCreate('shiyiMinePanel', false)
    AppStorage.setOrCreate('shiyiComposeId', '')
    AppStorage.setOrCreate('shiyiComposeDate', '')
    AppStorage.setOrCreate('shiyiDetailId', '')
    AppStorage.setOrCreate('shiyiRev', 0)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessAllowRegister', false)
    AppStorage.setOrCreate('accessGateActions', '')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return ShiyiStore.init(this.context);
        }).then(() => {;
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed');
                };
            });
        }).catch(() => {;
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed');
                };
            });
        });
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
