import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { QualityLocalStore } from '../services/QualityLocalStore';
import { QualityStatsBus } from '../services/QualityStatsBus';
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
import { QualityLocalStore } from '../services/QualityLocalStore';
import { QualityStatsBus } from '../services/QualityStatsBus';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '筑科建筑工程有限公司');
    AppStorage.setOrCreate('appDisplayName', '筑科质量巡查');
    AppStorage.setOrCreate('appTagline', '让每一次巡查，都有迹可循');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('qualityKind', 'none');
    AppStorage.setOrCreate('qualityId', '');
    AppStorage.setOrCreate('qualityExtra', '');
    AppStorage.setOrCreate('qualityToast', '');
    AppStorage.setOrCreate('qualityTick', 0);
    AppStorage.setOrCreate('qualityDataVersion', '0');
    AppStorage.setOrCreate('sqStatTodayInspect', 0);
    AppStorage.setOrCreate('sqStatFoundToday', 0);
    AppStorage.setOrCreate('sqStatRectifying', 0);
    AppStorage.setOrCreate('sqStatClosed', 0);
    AppStorage.setOrCreate('sqStatMonthInspect', 0);
    AppStorage.setOrCreate('sqStatMonthFound', 0);
    AppStorage.setOrCreate('sqStatMonthClosed', 0);
    AppStorage.setOrCreate('sqProjectCount', 0);
    AppStorage.setOrCreate('sqInspectionCount', 0);
    AppStorage.setOrCreate('sqIssueCount', 0);
    AppStorage.setOrCreate('qualityTab', 0);
    AppStorage.setOrCreate('issueFilter', '全部');
    AppStorage.setOrCreate('notifyEnabled', true);
    AppStorage.setOrCreate('themeColorMode', 'light');
    Theme.setColorMode('light');
    Theme.applyBrandPrimary('#2563EB');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return QualityLocalStore.init(this.context);
        }).then(() => {;
            QualityStatsBus.publish();
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
