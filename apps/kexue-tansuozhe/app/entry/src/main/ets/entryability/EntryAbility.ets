import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { Theme } from '../components/design-system/Theme';
import { ExplorationStore } from '../services/ExplorationStore';
import { SessionStore } from '../services/SessionStore';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { ExploreNav } from '../services/ExploreNav';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '科学探索');
    AppStorage.setOrCreate('appDisplayName', '元素探索者');
    AppStorage.setOrCreate('appTagline', '世界很大，也藏在每天经过的地方');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('themeEpoch', 0);
    AppStorage.setOrCreate('darkModeOn', false);
    AppStorage.setOrCreate('mainTab', 0);
    AppStorage.setOrCreate('showAtlasDetail', false);
    AppStorage.setOrCreate('showRecordEditor', false);
    AppStorage.setOrCreate('showRecordDetail', false);
    AppStorage.setOrCreate('showSearch', false);
    AppStorage.setOrCreate('showStats', false);
    AppStorage.setOrCreate('showCalendar', false);
    AppStorage.setOrCreate('showTimeline', false);
    AppStorage.setOrCreate('showDomainMap', false);
    AppStorage.setOrCreate('showBadges', false);
    AppStorage.setOrCreate('showChallenge', false);
    AppStorage.setOrCreate('showFavorites', false);
    AppStorage.setOrCreate('showTopics', false);
    AppStorage.setOrCreate('atlasDetailId', '');
    AppStorage.setOrCreate('recordEditorId', '');
    AppStorage.setOrCreate('recordDetailId', '');
    AppStorage.setOrCreate('progressRev', 0);
    AppStorage.setOrCreate('globalToast', '');
    AppStorage.setOrCreate('globalToastTick', 0);
    AppStorage.setOrCreate('topicCount', 0);
    AppStorage.setOrCreate('brandPrimary', '#1B4332');
    Theme.applyBrandPrimary('#1B4332');
    AccessConfig.applyDefaults('open_optional', false);
    ExploreNav.bump();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    void (async (): Promise<void> => {
      try {
        await SessionStore.init(this.context);
        await ExplorationStore.init(this.context);
        const mode = ExplorationStore.themeMode();
        ThemeAppearance.apply(mode, this.context);
      } catch {
        ThemeAppearance.apply('system', this.context);
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    })();
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    ThemeAppearance.onSystemConfiguration(newConfig);
  }
}
