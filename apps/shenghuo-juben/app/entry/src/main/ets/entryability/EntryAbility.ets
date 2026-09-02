import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SessionStore } from '../services/SessionStore';
import { ScriptStore } from '../services/ScriptStore';
import { ProfileStore } from '../services/ProfileStore';
import { PrivacyService } from '../services/PrivacyService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SessionStore } from '../services/SessionStore';
import { ScriptStore } from '../services/ScriptStore';
import { ProfileStore } from '../services/ProfileStore';
import { PrivacyService } from '../services/PrivacyService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '生活剧本');
    AppStorage.setOrCreate('appDisplayName', '生活剧本');
    AppStorage.setOrCreate('appTagline', '以剧本形式记录和回顾日常生活，每个人都是自己生活的主角');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('privacyAccepted', PrivacyService.isAccepted());
    AppStorage.setOrCreate('darkModeEnabled', false);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await ScriptStore.init(this.context);
            await ProfileStore.init(this.context);
            await ProfileStore.loadDarkModeToAppStorage();
            AppStorage.setOrCreate('privacyAccepted', PrivacyService.isAccepted());
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
