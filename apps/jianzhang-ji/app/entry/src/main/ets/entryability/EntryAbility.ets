import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { FavoriteService } from '../services/FavoriteService';
import { CompareStore } from '../services/CompareStore';
import { BrowseHistoryService } from '../services/BrowseHistoryService';
import { WatchlistService } from '../services/WatchlistService';
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
import { FavoriteService } from '../services/FavoriteService';
import { CompareStore } from '../services/CompareStore';
import { BrowseHistoryService } from '../services/BrowseHistoryService';
import { WatchlistService } from '../services/WatchlistService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '北京简章集科技有限公司');
    AppStorage.setOrCreate('appDisplayName', '简章集');
    AppStorage.setOrCreate('appTagline',
      '高校招生简章智慧检索平台，帮助学生和家长快速找到目标院校的官方招生信息');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('brochureRoute', '');
    AppStorage.setOrCreate('brochureTick', 0);
    AppStorage.setOrCreate('mainTab', 0);
    AppStorage.setOrCreate('favoriteTick', 0);
    AppStorage.setOrCreate('compareTick', 0);
    AppStorage.setOrCreate('watchTick', 0);
    AppStorage.setOrCreate('historyTick', 0);
    AppStorage.setOrCreate('compareIds', '');
    Theme.applyBrandPrimary('#007AFF');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'favorite_brochure,compare_brochure,watch_school');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return FavoriteService.init(this.context);
        }).then(() => {;
            return CompareStore.init(this.context);
        }).then(() => {;
            return BrowseHistoryService.init(this.context);
        }).then(() => {;
            return WatchlistService.init(this.context);
        }).then(() => {;
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
