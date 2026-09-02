import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { GuideService } from '../services/GuideService';
import { AuditorBootstrapService } from '../services/AuditorBootstrapService';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '日常笺语');
    AppStorage.setOrCreate('appTagline', '记录、计划、打卡与成长回顾一体的数字生活笺台');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('detailToken', 0);
    AppStorage.setOrCreate('diaryDataVersion', 0)
    AppStorage.setOrCreate('lifeHubRoute', '')
    AppStorage.setOrCreate('lifeHubFromMenu', false)
    AppStorage.setOrCreate('lifeHubVersion', 0)
    AppStorage.setOrCreate('pendingTab', -1)
    AppStorage.setOrCreate('pendingWriteDiary', 0)
    AppStorage.setOrCreate('pendingOpenFavorites', 0)
    AppStorage.setOrCreate('showProductGuide', false)
    AppStorage.setOrCreate('journalPrefillDate', '')
    AppStorage.setOrCreate('journalPrefillScene', '')
    AppStorage.setOrCreate('journalPrefillMood', '')
    AppStorage.setOrCreate('journalPrefillTitle', '')
    AppStorage.setOrCreate('journalPrefillBody', '')
    AppStorage.setOrCreate('journalPrefillTag', '')
    Theme.applyBrandPrimary('#A67B5B');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions',
      'create_diary,create_album,add_favorite,sync_records,life_write');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(async () => {
      await GuideService.init(this.context);
      const user = AppStorage.get<string>('currentUsername') ?? '';
      if (user.length > 0) {
        await AuditorBootstrapService.ensureDemoLifeData(user);
      }
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
