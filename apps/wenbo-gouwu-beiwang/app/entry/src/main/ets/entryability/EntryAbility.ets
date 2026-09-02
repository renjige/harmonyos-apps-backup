import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { BrandIdentity } from '../config/BrandIdentity';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { ShoppingLocalStore } from '../services/ShoppingLocalStore';
import { GrowthLocalStore } from '../services/GrowthLocalStore';
import { GrowthService } from '../services/GrowthService';
import { ShoppingNotifyService } from '../services/ShoppingNotifyService';
import { ShoppingWidgetSync } from '../services/ShoppingWidgetSync';
import { ShoppingService } from '../services/ShoppingService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('themeEpoch', 0);
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', BrandIdentity.developer());
    AppStorage.setOrCreate('appDisplayName', BrandIdentity.appName());
    AppStorage.setOrCreate('appTagline', '今天准备买些什么？');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('insetTop', 44);
    AppStorage.setOrCreate('onboardingDone', false);
    AppStorage.setOrCreate('notifyEnabled', true);
    AppStorage.setOrCreate('appearance', 'system');
    Theme.applyBrandPrimary('#1677FF');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_records');
  }

  private static applyWindowMetrics(win: window.Window): void {
    try {
      const size = win.getWindowProperties().windowRect;
      const widthVp = size.width / 3.25;
      AppStorage.setOrCreate('windowIsWide', widthVp >= 840);
      const avoid = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const topVp = avoid.topRect.height / 3.25;
      AppStorage.setOrCreate('insetTop', topVp > 24 ? topVp : 44);
    } catch {
      AppStorage.setOrCreate('windowIsWide', false);
      AppStorage.setOrCreate('insetTop', 44);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.init(this.context);
    ShoppingNotifyService.init(this.context);
    SessionStore.init(this.context).then(() => {
      return ShoppingLocalStore.init(this.context);
    }).then(() => {
      return GrowthLocalStore.init(this.context);
    }).then(() => {
      void GrowthService.createDefaultWeekPlan();
      ThemeAppearance.applyStored();
      void ShoppingWidgetSync.push();
      void ShoppingService.rescheduleReminders();
      windowStage.getMainWindow().then((win: window.Window) => {
        EntryAbility.applyWindowMetrics(win);
        try {
          win.on('windowSizeChange', () => {
            EntryAbility.applyWindowMetrics(win);
          });
        } catch {
        }
      }).catch(() => {
        AppStorage.setOrCreate('windowIsWide', false);
        AppStorage.setOrCreate('insetTop', 44);
      });
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

  onForeground(): void {
    ThemeAppearance.applyStored();
    void ShoppingNotifyService.deliverDue();
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
