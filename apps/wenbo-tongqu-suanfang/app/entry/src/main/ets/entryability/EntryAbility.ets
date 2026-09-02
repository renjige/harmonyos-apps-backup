import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { MathLocalStore } from '../services/MathLocalStore';
import { MathFeedbackService } from '../services/MathFeedbackService';
import { MathRefresh } from '../services/MathRefresh';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '童趣算坊');
    AppStorage.setOrCreate('appTagline', '快乐计算，聪明成长');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('onboardingDone', false);
    AppStorage.setOrCreate('mathDetailOpen', false);
    AppStorage.setOrCreate('mathDetailKind', 'mode');
    AppStorage.setOrCreate('mathDetailId', '');
    AppStorage.setOrCreate('mathHomeTick', 0);
    AppStorage.setOrCreate('mathSettingsTick', 0);
    AppStorage.setOrCreate('mathTodayStars', 0);
    AppStorage.setOrCreate('mathTotalStars', 0);
    AppStorage.setOrCreate('mathTodayDone', 0);
    AppStorage.setOrCreate('mathTodayAcc', 0)
    AppStorage.setOrCreate('mathStatsEpoch', 0);
    Theme.applyBrandPrimary('#3B82F6');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', '');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then((): Promise<void> => {
      return MathLocalStore.init(this.context);
    }).then((): Promise<void> => {
      return MathFeedbackService.init(this.context);
    }).then((): void => {
      MathRefresh.publishStats();
      windowStage.getMainWindow().then((win: window.Window) => {
        const size = win.getWindowProperties().windowRect;
        AppStorage.setOrCreate('windowIsWide', size.width >= 840);
      }).catch(() => {
        AppStorage.setOrCreate('windowIsWide', false);
      });
      this.loadIndex(windowStage);
    }).catch(() => {
      this.loadIndex(windowStage);
    });
  }

  private loadIndex(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
      }
    });
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
