import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { QyStore } from '../services/QyStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AccessConfig } from '../config/AccessConfig'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '清野生活')
    AppStorage.setOrCreate('appDisplayName', '清野行')
    AppStorage.setOrCreate('appTagline', '走入自然，记录每一次发现')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('QyEntryId', '')
    AppStorage.setOrCreate('QyClipId', '')
    AppStorage.setOrCreate('QyThemeId', '')
    AppStorage.setOrCreate('QyEntryEditId', '')
    AppStorage.setOrCreate('QyEntryTemplate', 'blank')
    AppStorage.setOrCreate('QyEntryEditorOpen', false)
    AppStorage.setOrCreate('QyClipEditId', '')
    AppStorage.setOrCreate('QyClipEditorOpen', false)
    AppStorage.setOrCreate('QyThemeEditId', '')
    AppStorage.setOrCreate('QyThemeEditorOpen', false)
    AppStorage.setOrCreate('QySearchOpen', false)
    AppStorage.setOrCreate('QyYearOpen', false)
    AppStorage.setOrCreate('QyDataRev', 0)
    AppStorage.setOrCreate('qyJumpExploreInbox', false)
    AppStorage.setOrCreate('QyActiveTab', 0)
    AccessConfig.applyLocalDefaults()
    Theme.applyBrandPrimary('#2D5A4A')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await QyStore.init(this.context)
      const profile = await QyStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      ThemeAppearance.apply(mode, this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await QyStore.init(this.context)
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
