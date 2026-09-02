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
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '亲子智谜');
    AppStorage.setOrCreate('appTagline', '一起动脑，一起开心。');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('quizRoute', '');
    AppStorage.setOrCreate('mainTab', 0);
    AppStorage.setOrCreate('quizTick', 0);
    AppStorage.setOrCreate('doneCount', 0);
    AppStorage.setOrCreate('streakDays', 0);
    AppStorage.setOrCreate('todayCount', 0);
    AppStorage.setOrCreate('familyMatch', 0);
    AppStorage.setOrCreate('puzzleCategory', 'all');
    AppStorage.setOrCreate('puzzleAge', 'all');
    AppStorage.setOrCreate('accountEpoch', 0);
    AppStorage.setOrCreate('wrongCount', 0);
    AppStorage.setOrCreate('progressOwner', 'state:guest');
    AppStorage.setOrCreate('detailPuzzleId', '');
    Theme.applyBrandPrimary('#4A78FF');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(() => {
      return ProgressStore.init(this.context);
    }).then(() => {
      windowStage.getMainWindow().then((win: window.Window) => {
        const size = win.getWindowProperties().windowRect;
        AppStorage.setOrCreate('windowIsWide', size.width >= 840);
      }).catch(() => {
        AppStorage.setOrCreate('windowIsWide', false);
      });
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(() => {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    });
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
