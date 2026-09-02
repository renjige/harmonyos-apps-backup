import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { ChenwuStore } from '../services/ChenwuStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AccessConfig } from '../config/AccessConfig'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  private mainWin: window.Window | null = null

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '晨雾计划')
    AppStorage.setOrCreate('appDisplayName', '晨雾计划')
    AppStorage.setOrCreate('appTagline', '在晨雾中规划成长，清晰回望每一步')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('cwGoalId', '')
    AppStorage.setOrCreate('cwPlanId', '')
    AppStorage.setOrCreate('cwHabitId', '')
    AppStorage.setOrCreate('cwJournalId', '')
    AppStorage.setOrCreate('cwReviewPhaseId', '')
    AppStorage.setOrCreate('cwGoalEditorOpen', false)
    AppStorage.setOrCreate('cwPlanEditorOpen', false)
    AppStorage.setOrCreate('cwPlanEditorGoalId', '')
    AppStorage.setOrCreate('cwHabitRecordOpen', false)
    AppStorage.setOrCreate('cwJournalEditorOpen', false)
    AppStorage.setOrCreate('cwReviewSheetOpen', false)
    AppStorage.setOrCreate('cwSearchOpen', false)
    AppStorage.setOrCreate('cwOrganizeOpen', false)
    AppStorage.setOrCreate('cwAnnualOpen', false)
    AppStorage.setOrCreate('cwAchievementsOpen', false)
    AppStorage.setOrCreate('cwDataRev', 0)
    AppStorage.setOrCreate('cwActiveTab', 0)
    AccessConfig.applyLocalDefaults()
    Theme.applyBrandPrimary('#5B8FA8')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    windowStage.getMainWindow().then((win: window.Window) => {
      this.mainWin = win
      try {
        win.setWindowLayoutFullScreen(false)
      } catch {
      }
      this.applySystemBars(win)
    })
    SessionStore.init(this.context).then(async () => {
      await ChenwuStore.init(this.context)
      const profile = await ChenwuStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      ThemeAppearance.apply(mode, this.context)
      if (this.mainWin !== null) {
        this.applySystemBars(this.mainWin)
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await ChenwuStore.init(this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    })
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config)
    if (this.mainWin !== null) {
      this.applySystemBars(this.mainWin)
    }
  }

  private applySystemBars(win: window.Window): void {
    const dark = Theme.isDark()
    const bg = dark ? '#3D5A6C' : '#F7F5F0'
    const fg = dark ? '#F7F5F0' : '#3D5A6C'
    const props: window.SystemBarProperties = {
      statusBarColor: bg,
      statusBarContentColor: fg,
      navigationBarColor: bg,
      navigationBarContentColor: fg
    }
    win.setWindowSystemBarProperties(props).catch(() => {
    })
  }
}
