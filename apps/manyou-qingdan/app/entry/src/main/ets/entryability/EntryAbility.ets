import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { RmStore } from '../services/RmStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AccessConfig } from '../config/AccessConfig'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '漫游序')
    AppStorage.setOrCreate('appDisplayName', '漫游清单')
    AppStorage.setOrCreate('appTagline', '把想做的事，慢慢变成经历')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('RmChecklistId', '')
    AppStorage.setOrCreate('RmWishId', '')
    AppStorage.setOrCreate('RmThemeId', '')
    AppStorage.setOrCreate('RmItemId', '')
    AppStorage.setOrCreate('RmChecklistEditId', '')
    AppStorage.setOrCreate('RmChecklistTemplate', 'blank')
    AppStorage.setOrCreate('RmChecklistEditorOpen', false)
    AppStorage.setOrCreate('RmWishEditId', '')
    AppStorage.setOrCreate('RmWishEditorOpen', false)
    AppStorage.setOrCreate('RmThemeEditId', '')
    AppStorage.setOrCreate('RmThemeEditorOpen', false)
    AppStorage.setOrCreate('RmSearchOpen', false)
    AppStorage.setOrCreate('RmYearOpen', false)
    AppStorage.setOrCreate('RmDataRev', 0)
    AppStorage.setOrCreate('rmJumpChecklistInbox', false)
    AppStorage.setOrCreate('RmActiveTab', 0)
    AccessConfig.applyLocalDefaults()
    Theme.applyBrandPrimary('#0EA5E9')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await RmStore.init(this.context)
      const profile = await RmStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      ThemeAppearance.apply(mode, this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await RmStore.init(this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    })
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config)
  }
}
