import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { LocalPhotoStore } from '../services/LocalPhotoStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('uiAbilityContext', this.context);
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '生活札记');
    AppStorage.setOrCreate('appTagline', '一款记录生活、收藏美好瞬间的智慧生活应用，日系手账美学与数字整理并存');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('detailToken', 0);
    Theme.applyBrandPrimary('#E8A87C');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions',
      'create_diary,create_album,add_favorite,sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(() => {
      LocalPhotoStore.init(this.context).then(() => {
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
