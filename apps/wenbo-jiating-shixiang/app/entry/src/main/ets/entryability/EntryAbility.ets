import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { TaskLocalStore } from '../services/TaskLocalStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '家庭事项');
    AppStorage.setOrCreate('appTagline', '让家庭里的每件小事都有回应，打开就知道今天家里有什么事');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('onboardingDone', false);
    AppStorage.setOrCreate('notifyEnabled', true);
    AppStorage.setOrCreate('appearance', 'system');
    AppStorage.setOrCreate('themeRevision', 0);
    AppStorage.setOrCreate('defaultReminder', 'none');
    Theme.applyBrandPrimary('#24443A');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(() => {
      return TaskLocalStore.init(this.context);
    }).then(() => {
      ThemeAppearance.applyStored(this.context);
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
