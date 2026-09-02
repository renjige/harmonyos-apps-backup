import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { DiaryStore } from '../services/DiaryStore';
import { AppLockService } from '../services/AppLockService';
import { SettingsService } from '../services/SettingsService';
import { AppContextService } from '../services/AppContextService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { DiaryStore } from '../services/DiaryStore';
import { AppLockService } from '../services/AppLockService';
import { SettingsService } from '../services/SettingsService';
import { AppContextService } from '../services/AppContextService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '私人空间');
    AppStorage.setOrCreate('appDisplayName', '私人日记');
    AppStorage.setOrCreate('appTagline', '智能陪伴的私人日记本，记录生活每一刻的温暖与思考');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('fontScale', 'medium');
    AppStorage.setOrCreate('themeMode', 'system');
    Theme.applyBrandPrimary('#2C3E50');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        AppContextService.setContext(this.context);
        SessionStore.init(this.context).then(async () => {;
            await DiaryStore.init(this.context);
            await AppLockService.init(this.context);
            await SettingsService.init(this.context);
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
