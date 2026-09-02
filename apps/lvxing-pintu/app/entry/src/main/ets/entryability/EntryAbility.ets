import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { PuzzleStore } from '../services/PuzzleStore'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { PuzzleStore } from '../services/PuzzleStore'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '拼图记忆')
    AppStorage.setOrCreate('appDisplayName', '旅行拼图')
    AppStorage.setOrCreate('appTagline', '将碎片化的旅行记忆拼合成完整的旅行故事')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('puzzleShowCreate', false)
    AppStorage.setOrCreate('puzzleShowDetail', false)
    AppStorage.setOrCreate('puzzleMinePanel', false)
    AppStorage.setOrCreate('puzzleEditId', '')
    AppStorage.setOrCreate('puzzleDetailId', '')
    AppStorage.setOrCreate('puzzleRev', 0)
    AppStorage.setOrCreate('puzzleShowPrivacy', false)
    AppStorage.setOrCreate('puzzleNeedPrivacy', false)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessAllowRegister', false)
    AppStorage.setOrCreate('accessGateActions', '')
    Theme.setColorMode('system')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return PuzzleStore.init(this.context);
        }).then(() => {;
            const settings = PuzzleStore.settings();
            if (settings.colorMode === 'dark') {;
                Theme.setColorMode('dark');
            };
            else if (settings.colorMode === 'light') {;
                Theme.setColorMode('light');
            };
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
