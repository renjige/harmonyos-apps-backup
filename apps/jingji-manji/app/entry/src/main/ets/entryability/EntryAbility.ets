import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { SportStore } from '../services/SportStore';
import { ProfileStore } from '../services/ProfileStore';
import { ChallengeStore } from '../services/ChallengeStore';
import { FavoriteStore } from '../services/FavoriteStore';
import { PlanStore } from '../services/PlanStore';
import { LocalCacheService } from '../services/LocalCacheService';
import { DiagnoseReportStore } from '../services/DiagnoseReportStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.apply();
    AppStorage.setOrCreate('companyName', '漫记竞技');
    AppStorage.setOrCreate('appDisplayName', '竞技漫记');
    AppStorage.setOrCreate('appTagline',
      '个人竞技数据记录与成长轨迹可视化，快速录入运动表现、智慧统计趋势与成就激励，数据默认仅存本地设备');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('sportDetailId', '');
    AppStorage.setOrCreate('challengeDetailId', '');
    AppStorage.setOrCreate('showCalendar', false);
    AppStorage.setOrCreate('showDiagnose', false);
    AppStorage.setOrCreate('showMonthlyReport', false)
    AppStorage.setOrCreate('planDetailId', '')
    AppStorage.setOrCreate('showFavorites', false);
    AppStorage.setOrCreate('localCacheEpoch', 0);
    AppStorage.setOrCreate('sportDataEpoch', 0);
    AppStorage.setOrCreate('diagnoseDraftStep', 0);
    AppStorage.setOrCreate('recordFormRequest', 0);
    AppStorage.setOrCreate('recordPrefillDate', '');
    AppStorage.setOrCreate('recordPrefillCategory', '');
    AppStorage.setOrCreate('lastDiagnoseCategory', '');
    AppStorage.setOrCreate('lastDiagnoseScore', '');
    AppStorage.setOrCreate('lastDiagnoseAt', '');
    AppStorage.setOrCreate('diagnoseReportEpoch', 0);
    Theme.setColorMode('system');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'create,submit,sync');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(async () => {
      ThemeAppearance.applyStored(this.context);
      await SportStore.init(this.context);
      await ProfileStore.init(this.context);
      await ChallengeStore.init(this.context);
      await FavoriteStore.init(this.context);
      await PlanStore.init(this.context);
      await LocalCacheService.init(this.context);
      await DiagnoseReportStore.init(this.context);
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
