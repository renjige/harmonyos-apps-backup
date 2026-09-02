import { AbilityConstant, Configuration, UIAbility, Want, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Theme } from '../components/design-system/Theme';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { ObserveStore } from '../services/ObserveStore';
import { ObservePlanService } from '../services/ObservePlanService';
import { ObserveWeeklyPlanService } from '../services/ObserveWeeklyPlanService';
import { CheckInService } from '../services/CheckInService';
import { ActivityTimelineService } from '../services/ActivityTimelineService';
import { AchievementService } from '../services/AchievementService';
import { AppContextService } from '../services/AppContextService';
import { ReminderService } from '../services/ReminderService';
import { ObserveAtlasStore } from '../services/ObserveAtlasStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('themeEpoch', 0);
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '观物生活');
    AppStorage.setOrCreate('appDisplayName', '观物');
    AppStorage.setOrCreate('appTagline', '以观物取象观察日常瞬间，记录心情、场景、想法与环境，生成本机生活洞察报告');
    AppStorage.setOrCreate('tabBarHidden', false);
    AccessConfig.applyDefaults('open_optional');
    Theme.applyBrandPrimary('#5B6ABF');
    AppContextService.setContext(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppContextService.setContext(this.context);
    windowStage.getMainWindow().then((win: window.Window) => {
      AppContextService.setWindow(win);
      ThemeAppearance.applyStored(this.context);
      ThemeAppearance.applySystemBars(win);
    }).catch(() => {
      ThemeAppearance.applyStored(this.context);
    });
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
      }
    });
    void EntryAbility.bootstrapStores(this.context);
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
    const win = AppContextService.getWindow();
    if (win !== null) {
      ThemeAppearance.applySystemBars(win);
    }
  }

  private static async bootstrapStores(context: common.UIAbilityContext): Promise<void> {
    try {
      await SessionStore.init(context);
      await ObserveStore.init(context);
      await ObservePlanService.init(context);
      await ObserveWeeklyPlanService.init(context);
      await CheckInService.init(context);
      await ActivityTimelineService.init(context);
      await AchievementService.init(context);
      await ObserveAtlasStore.init(context);
      const profile = await ObserveStore.loadProfile();
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system';
      AppStorage.setOrCreate('colorMode', mode);
      ThemeAppearance.apply(mode, context);
      const win = AppContextService.getWindow();
      if (win !== null) {
        ThemeAppearance.applySystemBars(win);
      }
      await ReminderService.syncFromProfile(context);
    } catch {
      try {
        await ObserveStore.init(context);
      } catch {
        hilog.error(0x0000, TAG, 'store bootstrap failed');
      }
    }
  }
}
