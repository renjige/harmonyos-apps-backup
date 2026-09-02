import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { LearningProgressService } from '../services/LearningProgressService'
import { FavoriteService } from '../services/FavoriteService'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { LearningProgressService } from '../services/LearningProgressService'
import { FavoriteService } from '../services/FavoriteService'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '承德锐泓科技信息有限公司')
    AppStorage.setOrCreate('appDisplayName', '露营课堂')
    AppStorage.setOrCreate('appTagline', '在大自然里，把露营学扎实')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('detailToken', 0)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGateActions',
      'create_trip,manage_gear,write_journal,publish_guide,favorite_camp,write_note')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await LearningProgressService.ensure(this.context);
            await FavoriteService.init(this.context);
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
