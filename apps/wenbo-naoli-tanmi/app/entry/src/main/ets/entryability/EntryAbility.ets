import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { BrainProgress } from '../services/BrainProgress';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { BrainProgress } from '../services/BrainProgress';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '脑力探秘');
    AppStorage.setOrCreate('appTagline', '通过游戏化每日训练探索记忆、专注、反应与逻辑潜能，生成脑力图谱并追踪成长轨迹');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('quizRoute', '');
    AppStorage.setOrCreate('mainTab', 0);
    AppStorage.setOrCreate('brainEntityId', '');
    AppStorage.setOrCreate('brainGameType', '');
    AppStorage.setOrCreate('brainLastScore', 0);
    AppStorage.setOrCreate('brainScoreTitle', '');
    AppStorage.setOrCreate('progressTick', 0);
    AppStorage.setOrCreate('wisdomIndex', 0);
    AppStorage.setOrCreate('streakDays', 0);
    AppStorage.setOrCreate('sessionCount', 0);
    AppStorage.setOrCreate('assessDoneFlag', 0);
    Theme.applyBrandPrimary('#6C3CE1');
    Theme.setColorMode('dark');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'sync_progress');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return BrainProgress.init(this.context);
        }).then(() => {;
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
