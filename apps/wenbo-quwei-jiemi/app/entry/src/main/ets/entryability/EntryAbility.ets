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
    AppStorage.setOrCreate('companyName', '承德锐泓科技信息有限公司');
    AppStorage.setOrCreate('appDisplayName', '趣味解谜');
    AppStorage.setOrCreate('appTagline', '轻量级智慧解谜应用：每日智慧挑战、分类谜题库、智慧排行榜与成就徽章，碎片时间轻松动脑');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('quizRoute', '');
    AppStorage.setOrCreate('mainTab', 0);
    AppStorage.setOrCreate('quizTick', 0);
    AppStorage.setOrCreate('doneCount', 0);
    AppStorage.setOrCreate('streakDays', 0);
    AppStorage.setOrCreate('todayCount', 0);
    AppStorage.setOrCreate('wisdomPointsTotal', 0);
    AppStorage.setOrCreate('wisdomPointsWeek', 0);
    Theme.applyBrandPrimary('#007AFF');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return ProgressStore.init(this.context);
        }).then(() => {;
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
