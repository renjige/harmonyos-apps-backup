import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { AppContextService } from '../services/AppContextService'
import { UserDataStore } from '../services/UserDataStore'
import { LocalPrefs } from '../services/LocalPrefs'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    AppStorage.setOrCreate('wanxiangStoreReady', false)
    hilog.info(0x0000, TAG, 'onCreate')
    AppContextService.setContext(this.context)
    AppStorage.setOrCreate('companyName', '万象信息')
    AppStorage.setOrCreate('appDisplayName', '万象页')
    AppStorage.setOrCreate('appTagline', '个人轻知识工作台 · 读记复习成长')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('wanxiangDetailId', '')
    Theme.applyBrandPrimary('#007AFF')
    AccessConfig.applyDefaults('open_optional')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    void (async () => {
      try {
        await SessionStore.init(this.context)
      } catch {
        hilog.warn(0x0000, TAG, 'SessionStore init skipped')
      }
      await LocalPrefs.init(this.context)
      await UserDataStore.init(this.context)
      const mode = await UserDataStore.getThemeMode()
      AppStorage.setOrCreate('colorMode', mode)
      ThemeAppearance.applyStored(this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    })()
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config)
  }
}
