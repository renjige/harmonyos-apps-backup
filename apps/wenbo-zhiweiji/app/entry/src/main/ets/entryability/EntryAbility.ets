import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { SessionStore } from '../services/SessionStore'
import { ZhiweiStore } from '../services/ZhiweiStore'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '魏文波')
    AppStorage.setOrCreate('appDisplayName', '知微集')
    AppStorage.setOrCreate('appTagline', '把微知识收进来，分类整理、每日一知、建成个人知识库')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('zwShowCompose', false)
    AppStorage.setOrCreate('zwShowCapture', false)
    AppStorage.setOrCreate('zwShowQuote', false)
    AppStorage.setOrCreate('zwShowWeekly', false)
    AppStorage.setOrCreate('zwShowFocus', false)
    AppStorage.setOrCreate('zwShowLibrary', false)
    AppStorage.setOrCreate('zwShowDaily', false)
    AppStorage.setOrCreate('zwShowAllCaptures', false)
    AppStorage.setOrCreate('zwShowTimeline', false)
    AppStorage.setOrCreate('zwShowReview', false)
    AppStorage.setOrCreate('zwShowAchievement', false)
    AppStorage.setOrCreate('zwShowPlan', false)
    AppStorage.setOrCreate('zwShowKnowledgeCatalog', false)
    AppStorage.setOrCreate('zwShowReviewDeck', false)
    AppStorage.setOrCreate('zwShowInbox', false)
    AppStorage.setOrCreate('zwShowLearningPath', false)
    AppStorage.setOrCreate('zwDailyId', '')
    AppStorage.setOrCreate('zwReviewPeriod', 'week')
    AppStorage.setOrCreate('zwComposeTemplateId', '')
    AppStorage.setOrCreate('zwComposeId', '')
    AppStorage.setOrCreate('zwCaptureId', '')
    AppStorage.setOrCreate('zwQuoteId', '')
    AppStorage.setOrCreate('zwComposeVoice', false)
    AppStorage.setOrCreate('zwFocusTitle', '')
    AppStorage.setOrCreate('zwFocusKind', '')
    AppStorage.setOrCreate('zwFocusKey', '')
    AppStorage.setOrCreate('zwRev', 0)
    AppStorage.setOrCreate('zwOpenMineSettings', false)
    AppStorage.setOrCreate('zwTabJump', -1)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessGateActions', 'sync_account')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(async () => {
      await ZhiweiStore.init(this.context)
      ThemeAppearance.apply(ZhiweiStore.settings().darkMode ? 'dark' : 'light', this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(() => {
      ThemeAppearance.applyStored(this.context)
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
