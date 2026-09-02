import { AbilityConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.apply();
    Theme.applyBrandPrimary('#FF6B35');
    AppStorage.setOrCreate('companyName', '拾光运动科技');
    AppStorage.setOrCreate('appDisplayName', '球场拾光');
    AppStorage.setOrCreate('appTagline',
      '个人球迷记录与赛事记忆，附带合作场馆预约');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('themeEpoch', 0);
    AppStorage.setOrCreate('courtVenueId', '');
    AppStorage.setOrCreate('courtPromotionId', '');
    AppStorage.setOrCreate('courtBookingVenueId', '');
    AppStorage.setOrCreate('showCourtDiagnose', false);
    AppStorage.setOrCreate('showCourtBookings', false)
    AppStorage.setOrCreate('showCourtFavorites', false)
    AppStorage.setOrCreate('showCourtMessages', false)
    AppStorage.setOrCreate('courtCaseId', '')
    AppStorage.setOrCreate('courtSlotTime', '')
    AppStorage.setOrCreate('courtFavoriteIds', '');
    AppStorage.setOrCreate('courtBookingStatus', '');
    AppStorage.setOrCreate('fanEntries', '');
    AppStorage.setOrCreate('fanEpoch', 0);
    AppStorage.setOrCreate('fanStreakDay', '');
    AppStorage.setOrCreate('fanStreakCount', '0');
    AppStorage.setOrCreate('courtFanKind', '');
    AppStorage.setOrCreate('courtFanId', '');
    AppStorage.setOrCreate('courtFanEditId', '');
    AppStorage.setOrCreate('showCourtFanList', false);
    AppStorage.setOrCreate('showCourtFanEditor', false);
    AppStorage.setOrCreate('showCourtFanCalendar', false);
    AppStorage.setOrCreate('showCourtFanTimeline', false);
    AppStorage.setOrCreate('showCourtFanWizard', false);
    AppStorage.setOrCreate('showCourtFanDashboard', false);
    AppStorage.setOrCreate('courtFanAlbumHint', '');
    AppStorage.setOrCreate('courtFanPrefillTitle', '');
    AppStorage.setOrCreate('courtFanPrefillBody', '');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'create,submit,sync');
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    ThemeAppearance.onSystemConfiguration(newConfig);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(() => {
      ThemeAppearance.applyStored(this.context);
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
}
