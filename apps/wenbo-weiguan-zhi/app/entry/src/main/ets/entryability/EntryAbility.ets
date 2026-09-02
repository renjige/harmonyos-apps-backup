import { AbilityConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { EssayStore } from '../services/EssayStore'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { PracticeStore } from '../services/PracticeStore'
import { GrowthStore } from '../services/GrowthStore'
import { IntroStore } from '../services/IntroStore'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '承德锐泓科技有限公司')
    AppStorage.setOrCreate('appDisplayName', '微观志')
    AppStorage.setOrCreate('appTagline', '五感观察练习本 · 对照 · 专题 · 专辑')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('tagFilter', '')
    AppStorage.setOrCreate('essayTabIndex', -1)
    AppStorage.setOrCreate('essayFontScale', 1)
    AppStorage.setOrCreate('essayDataEpoch', 0)
    AppStorage.setOrCreate('themeEpoch', 0)
    AppStorage.setOrCreate('colorMode', 'system')
    AppStorage.setOrCreate('practiceEpoch', 0)
    AppStorage.setOrCreate('essayPracticeHint', '')
    AppStorage.setOrCreate('essayCardHint', '')
    AppStorage.setOrCreate('growthToast', '')
    AppStorage.setOrCreate('contrastSeedId', '')
    AppStorage.setOrCreate('openContrast', 0)
    AppStorage.setOrCreate('openObserveCard', 0)
    AppStorage.setOrCreate('forceObserveIntro', 0)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(async () => {
      await EssayStore.init(this.context)
      await PracticeStore.init(this.context)
      await GrowthStore.init(this.context)
      await IntroStore.init(this.context)
      const epoch = AppStorage.get<number>('essayDataEpoch') ?? 0
      AppStorage.setOrCreate('essayDataEpoch', epoch + 1)
      const mode = AppStorage.get<string>('colorMode') ?? 'system'
      ThemeAppearance.apply(mode, this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(() => {
      void EssayStore.init(this.context)
      void PracticeStore.init(this.context)
      void GrowthStore.init(this.context)
      void IntroStore.init(this.context)
      ThemeAppearance.apply('system', this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    })
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    ThemeAppearance.onSystemConfiguration(newConfig)
  }
}
