import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { NoteStore } from '../services/NoteStore'
import { StudyStore } from '../services/StudyStore'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    AppStorage.setOrCreate('noteEpoch', 0)
    AppStorage.setOrCreate('studyEpoch', 0)
    AppStorage.setOrCreate('statTotalNotes', 0)
    AppStorage.setOrCreate('statBookCount', 0)
    AppStorage.setOrCreate('statFavoriteCount', 0)
    AppStorage.setOrCreate('statTodayRecall', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '承德锐泓科技有限公司')
    AppStorage.setOrCreate('appDisplayName', '纸上方')
    AppStorage.setOrCreate('appTagline', '智能书摘，让每本读过的书都留下智慧精华，从纸质书高效提取、整理与回顾')
    AppStorage.setOrCreate('tabBarHidden', false)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    Theme.applyBrandPrimary('#2C3E6B')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(async () => {
      await NoteStore.init(this.context)
      await StudyStore.init(this.context)
      await StudyStore.syncFromNotes()
      const dark = await NoteStore.loadDark()
      ThemeAppearance.apply(dark ? 'dark' : 'light', this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(() => {
      NoteStore.init(this.context).then(() => {
        windowStage.loadContent('pages/Index', (err) => {
          if (err.code) {
            hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
          }
        })
      }).catch(() => {
        windowStage.loadContent('pages/Index', (err) => {
          if (err.code) {
            hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
          }
        })
      })
    })
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config)
  }
}
