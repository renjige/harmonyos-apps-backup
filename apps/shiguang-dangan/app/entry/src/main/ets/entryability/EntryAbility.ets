import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { ArchiveStore } from '../services/ArchiveStore'
import { LifeStore } from '../services/LifeStore'
import { AppContextService } from '../services/AppContextService'
import { PrivacyService } from '../services/PrivacyService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AccessConfig } from '../config/AccessConfig'
import { DateHelper } from '../services/DateHelper'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '时光印记')
    AppStorage.setOrCreate('appDisplayName', '时光档案')
    AppStorage.setOrCreate('appTagline', '把重要时刻，整理成一生的档案')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('archiveDetailId', '')
    AppStorage.setOrCreate('nodeDetailId', '')
    AppStorage.setOrCreate('createArchiveOpen', false)
    AppStorage.setOrCreate('nodeEditorOpen', false)
    AppStorage.setOrCreate('nodeEditorArchiveId', '')
    AppStorage.setOrCreate('nodeEditorNodeId', '')
    AppStorage.setOrCreate('editArchiveId', '')
    AppStorage.setOrCreate('searchOpen', false)
    AppStorage.setOrCreate('inspirationEditorOpen', false)
    AppStorage.setOrCreate('momentEditorOpen', false)
    AppStorage.setOrCreate('archiveDataRev', 0)
    AccessConfig.applyLocalArchiveDefaults()
    Theme.applyBrandPrimary('#182333')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await ArchiveStore.init(this.context)
      await LifeStore.init(this.context)
      await ArchiveStore.recordActivityDate(DateHelper.todayKey())
      const profile = await ArchiveStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      Theme.setColorMode(mode as 'light' | 'dark' | 'system')
      AppStorage.setOrCreate('colorMode', mode)
      if (mode === 'system') {
        Theme.setForcedDark(this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await ArchiveStore.init(this.context)
      await LifeStore.init(this.context)
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
