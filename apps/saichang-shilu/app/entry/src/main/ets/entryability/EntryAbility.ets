import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SessionStore } from '../services/SessionStore';
import { RecordStore } from '../services/RecordStore';
import { ProfileStore } from '../services/ProfileStore';
import { GoalStore } from '../services/GoalStore';
import { CollectStore } from '../services/CollectStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '拾录体育');
    AppStorage.setOrCreate('appDisplayName', '赛场拾录');
    AppStorage.setOrCreate('appTagline', '记录每一场值得珍藏的比赛');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('mainTabIndex', 0);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Promise.all([
      SessionStore.init(this.context),
      RecordStore.init(this.context),
      ProfileStore.init(this.context),
      GoalStore.init(this.context),
      CollectStore.init(this.context)
    ]).then(() => {
      ThemeAppearance.applyStored(this.context);
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
