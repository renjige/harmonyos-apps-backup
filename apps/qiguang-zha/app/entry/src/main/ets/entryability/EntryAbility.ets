import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { QgStore } from '../services/QgStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AccessConfig } from '../config/AccessConfig'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '栖光生活')
    AppStorage.setOrCreate('appDisplayName', '栖光札')
    AppStorage.setOrCreate('appTagline', '收藏生活中的微小光亮')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('qgEntryId', '')
    AppStorage.setOrCreate('qgClipId', '')
    AppStorage.setOrCreate('qgThemeId', '')
    AppStorage.setOrCreate('qgEntryEditId', '')
    AppStorage.setOrCreate('qgEntryTemplate', 'blank')
    AppStorage.setOrCreate('qgEntryEditorOpen', false)
    AppStorage.setOrCreate('qgClipEditId', '')
    AppStorage.setOrCreate('qgClipEditorOpen', false)
    AppStorage.setOrCreate('qgThemeEditId', '')
    AppStorage.setOrCreate('qgThemeEditorOpen', false)
    AppStorage.setOrCreate('qgSearchOpen', false)
    AppStorage.setOrCreate('qgYearOpen', false)
    AppStorage.setOrCreate('qgDataRev', 0)
    AppStorage.setOrCreate('qgJumpJournalInbox', false)
    AppStorage.setOrCreate('qgActiveTab', 0)
    AccessConfig.applyLocalDefaults()
    Theme.applyBrandPrimary('#5B7C78')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await QgStore.init(this.context)
      const profile = await QgStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      ThemeAppearance.apply(mode, this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await QgStore.init(this.context)
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
