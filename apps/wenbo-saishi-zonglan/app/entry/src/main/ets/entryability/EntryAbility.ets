import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { ReminderLocalStore } from '../services/ReminderLocalStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '赛事纵览');
    AppStorage.setOrCreate('appTagline', '专业体育赛事信息管理工具，帮助用户查看比赛安排、关注赛事、设置智慧提醒、查阅比赛结果');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('notifyEnabled', true);
    AppStorage.setOrCreate('defaultRemindMinutes', 30);
    AppStorage.setOrCreate('themeColorMode', 'light');
    Theme.applyBrandPrimary('#1677FF');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'follow_match,set_reminder');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(() => {
      return ReminderLocalStore.init(this.context);
    }).then(() => {
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
