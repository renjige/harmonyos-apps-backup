import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { ProgressStore } from '../services/ProgressStore';
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
import { ProgressStore } from '../services/ProgressStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '承德锐泓科技有限公司');
    AppStorage.setOrCreate('appDisplayName', '诗词挑战');
    AppStorage.setOrCreate('appTagline', '国潮现代诗词竞技：每日五题填空配对排序、飞花令关键字接龙与百首经典图鉴注释赏析，游客即可开练');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('poetryRoute', '');
    AppStorage.setOrCreate('mainTab', 0);
    AppStorage.setOrCreate('poetryTick', 0);
    AppStorage.setOrCreate('streakDays', 0);
    AppStorage.setOrCreate('totalAnswered', 0);
    AppStorage.setOrCreate('correctCount', 0);
    AppStorage.setOrCreate('maxCombo', 0);
    AppStorage.setOrCreate('totalScore', 0);
    AppStorage.setOrCreate('titleRank', '诗词童生');
    AppStorage.setOrCreate('dailyDoneFlag', 0);
    AppStorage.setOrCreate('dailyScore', 0);
    AppStorage.setOrCreate('feihuaRounds', 0);
    AppStorage.setOrCreate('feihuaWins', 0);
    AppStorage.setOrCreate('favoriteCount', 0);
    Theme.applyBrandPrimary('#C41A1A');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_progress');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return ProgressStore.init(this.context);
        }).then(() => {;
            const mode = ProgressStore.snapshot().colorMode;
            if (mode === 'dark' || mode === 'light' || mode === 'system') {;
                Theme.setColorMode(mode);
            };
            windowStage.getMainWindow().then((win: window.Window) => {;
                const size = win.getWindowProperties().windowRect;
                AppStorage.setOrCreate('windowIsWide', size.width >= 840);
            }).catch(() => {;
                AppStorage.setOrCreate('windowIsWide', false);
            });
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
