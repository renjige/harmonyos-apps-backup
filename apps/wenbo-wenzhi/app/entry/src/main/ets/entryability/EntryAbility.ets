import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { SessionStore } from '../services/SessionStore';
import { ApiConfig } from '../config/ApiConfig';
import { VaultStore } from '../services/VaultStore';
import { LearnStore } from '../services/LearnStore';
import { GrowthStore } from '../services/GrowthStore';
import { PathStore } from '../services/PathStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    AppStorage.setOrCreate('learnPanel', '');
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '承德锐泓科技信息有限公司');
    AppStorage.setOrCreate('appDisplayName', '问知');
    AppStorage.setOrCreate('appTagline', '提问求知、结构化解答与个人知识库，把答案真正留下来。');
    AppStorage.setOrCreate('tabBarHidden', false);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_vault');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context)
      .then(() => {
        return VaultStore.init(this.context);
      })
      .then(() => {
        return LearnStore.init(this.context);
      })
      .then(() => {
        return PathStore.init(this.context);
      })
      .then(() => {
        return GrowthStore.init(this.context);
      })
      .then(() => {
        windowStage.loadContent('pages/Index', (err) => {
          if (err.code) {
            hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
          }
        });
      })
      .catch(() => {
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
