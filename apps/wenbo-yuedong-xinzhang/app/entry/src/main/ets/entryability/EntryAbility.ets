import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { SessionStore } from '../services/SessionStore';
import { YdLocalStore } from '../services/YdLocalStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '跃动新章');
    AppStorage.setOrCreate('appTagline', '智慧日程与目标管理，计划-执行-复盘闭环，本机存储');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('ydGoalDetailId', '');
    AppStorage.setOrCreate('ydGoalCreateOpen', false);
    AppStorage.setOrCreate('ydTaskAddOpen', false);
    AppStorage.setOrCreate('ydTaskDetailId', '');
    AppStorage.setOrCreate('ydChapterCreateOpen', false);
    AppStorage.setOrCreate('ydChapterDetailId', '');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(async () => {
      ThemeAppearance.applyStored(this.context);
      await YdLocalStore.init(this.context);
      const dark = await YdLocalStore.isDarkMode();
      AppStorage.setOrCreate('ydDarkInit', dark);
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
