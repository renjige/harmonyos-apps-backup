import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SessionStore } from '../services/SessionStore';
import { TrainingStore } from '../services/TrainingStore';
import { FunQuestStore } from '../services/FunQuestStore';
import { PracticeHubStore } from '../services/PracticeHubStore';
import { ProfileStore } from '../services/ProfileStore';
import { VitalityStore } from '../services/VitalityStore';
import { VitalityService } from '../services/VitalityService';
import { WeekPlaybookService } from '../services/WeekPlaybookService';
import { AppContextService } from '../services/AppContextService';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { Theme } from '../components/design-system/Theme';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '训练拾趣');
    AppStorage.setOrCreate('appTagline', '跟练·玩法·呼吸·图鉴·挑战·成长');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('mainTabIndex', 1);
    AppStorage.setOrCreate('trainingDetailId', '');
    AppStorage.setOrCreate('questDetailId', '');
    AppStorage.setOrCreate('showTrainingForm', false);
    AppStorage.setOrCreate('showQuestForm', false);
    AppStorage.setOrCreate('showRecap', false);
    AppStorage.setOrCreate('practiceHubKind', '');
    AppStorage.setOrCreate('dataEpoch', 0);
    AppStorage.setOrCreate('showFeatureTour', false);
    AppStorage.setOrCreate('showFollowAlong', false);
    AppStorage.setOrCreate('showSportRoulette', false);
    AppStorage.setOrCreate('showBreathGuide', false);
    AppStorage.setOrCreate('showWeekPlaybook', false);
    AppStorage.setOrCreate('weekPlaybookRev', 0);
    Theme.applyBrandPrimary('#007AFF');
    AppContextService.setContext(this.context);
    const sysDark = this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    AppStorage.setOrCreate('systemColorDark', sysDark);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppContextService.setContext(this.context);
    SessionStore.init(this.context).then(async () => {
      await TrainingStore.init(this.context);
      await FunQuestStore.init(this.context);
      await PracticeHubStore.init(this.context);
      await ProfileStore.init(this.context);
      await VitalityStore.init(this.context);
      await WeekPlaybookService.init(this.context);
      await ProfileStore.ensureFirstUse();
      VitalityService.applyStoredSkin();
      const profile = ProfileStore.get();
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system';
      ThemeAppearance.apply(mode, this.context);
      AppStorage.setOrCreate('mainTabIndex', 1);
      AppStorage.setOrCreate('showFeatureTour', profile.featureTourSeen !== 1);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(async () => {
      await TrainingStore.init(this.context);
      await FunQuestStore.init(this.context);
      await PracticeHubStore.init(this.context);
      await ProfileStore.init(this.context);
      await VitalityStore.init(this.context);
      VitalityService.applyStoredSkin();
      ThemeAppearance.apply('system', this.context);
      AppStorage.setOrCreate('mainTabIndex', 1);
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
