import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { LifeLocalStore } from '../services/LifeLocalStore'
import { AppContextService } from '../services/AppContextService'
import { ReminderService } from '../services/ReminderService'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '生活札')
    AppStorage.setOrCreate('appDisplayName', '生活札')
    AppStorage.setOrCreate('appTagline', '记录生活、沉淀经验、管理日常')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('lifeNoteDetailId', '')
    AppStorage.setOrCreate('lifeNoteEditorId', '')
    AppStorage.setOrCreate('lifeNoteEditorOpen', false)
    AppStorage.setOrCreate('lifeTodoEditId', '')
    AppStorage.setOrCreate('lifeSearchOpen', false)
    AppStorage.setOrCreate('lifeCraftDetailId', '')
    AppStorage.setOrCreate('lifeCraftEditorId', '')
    AppStorage.setOrCreate('lifeCraftEditorKind', 'tip')
    AppStorage.setOrCreate('lifeCraftEditorOpen', false)
    AppStorage.setOrCreate('lifeEditorTemplate', '')
    AppStorage.setOrCreate('lifeEditorCategory', '')
    AppStorage.setOrCreate('lifeThemeTick', 0)
    Theme.applyBrandPrimary('#E8A87C')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.lockSystemLight(this.context)
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await LifeLocalStore.init(this.context)
      const dark = await LifeLocalStore.isDarkMode()
      Theme.applyDark(dark)
      await ReminderService.syncAllTodos(this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await LifeLocalStore.init(this.context)
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

  onForeground(): void {
    AppContextService.setContext(this.context)
    void ReminderService.syncAllTodos(this.context)
  }
}
