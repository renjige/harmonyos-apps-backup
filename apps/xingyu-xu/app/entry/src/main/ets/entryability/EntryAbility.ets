import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { Theme } from '../components/design-system/Theme'
import { XingyuStore } from '../services/XingyuStore'
import { LocalAuthStore } from '../services/LocalAuthStore'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('apiBaseUrl', '')
    AppStorage.setOrCreate('allowDevHttp', false)
    AppStorage.setOrCreate('companyName', '星隅叙')
    AppStorage.setOrCreate('appDisplayName', '星隅叙')
    AppStorage.setOrCreate('appTagline', '在生活的角落，收藏属于自己的星光时刻')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('themeEpoch', 0)
    AppStorage.setOrCreate('darkModeOn', false)
    AppStorage.setOrCreate('xingyuRev', 0)
    AppStorage.setOrCreate('xingyuTabIndex', 0)
    AppStorage.setOrCreate('xingyuNarrativeId', '')
    AppStorage.setOrCreate('xingyuSparkId', '')
    AppStorage.setOrCreate('xingyuThemeId', '')
    AppStorage.setOrCreate('xingyuEditorKind', '')
    AppStorage.setOrCreate('xingyuEditorId', '')
    AppStorage.setOrCreate('xingyuSearchOpen', false)
    AppStorage.setOrCreate('xingyuFavOpen', false)
    AppStorage.setOrCreate('xingyuAchieveOpen', false)
    AppStorage.setOrCreate('xingyuTagsOpen', false)
    AppStorage.setOrCreate('xingyuPendingThemeId', '')
    AccessConfig.applyDefaults('open_optional')
    Theme.applyBrandPrimary('#12182B')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(async () => {
      await XingyuStore.init(this.context)
      await LocalAuthStore.init(this.context)
      ThemeAppearance.applyStored(this.context)
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
  }
}
