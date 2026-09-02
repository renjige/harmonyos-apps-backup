import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { StudyStore } from '../services/StudyStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('apiBaseUrl', 'https://saas16.qianqi.online/api/v1');
    AppStorage.setOrCreate('allowDevHttp', false);
    AppStorage.setOrCreate('tenantId', 'xuejian');
    AppStorage.setOrCreate('companyName', '学见');
    AppStorage.setOrCreate('appDisplayName', '学见');
    AppStorage.setOrCreate('appTagline', '智慧学习助手，让每一次学习都被看见。');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('themeEpoch', 0);
    AppStorage.setOrCreate('studyDataEpoch', 0);
    AppStorage.setOrCreate('xuejianDark', false);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    Theme.applyBrandPrimary('#1A2A4A');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(() => {
      return StudyStore.init(this.context);
    }).then(() => {
      return StudyStore.loadDark();
    }).then((dark: boolean) => {
      ThemeAppearance.apply(dark ? 'dark' : 'light', this.context);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(() => {
      ThemeAppearance.apply('light', this.context);
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
