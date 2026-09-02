/** 全局详情 / 二级页路由（MainTabPage 顶层 Overlay） */
import { WritingScenario, WritingWorkflow } from '../models/LanguageCraftModels'
import { LanguageWorkflowService } from './LanguageWorkflowService'

export class LanguageCraftNav {
  static openDetail(id: string): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('detailInspirationId', id)
    AppStorage.setOrCreate('detailRefresh', Date.now())
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailInspirationId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static detailId(): string {
    return AppStorage.get<string>('detailInspirationId') ?? ''
  }

  static openHistory(tab: string = 'polish'): void {
    AppStorage.setOrCreate('historyTab', tab)
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('showHistory', true)
    AppStorage.setOrCreate('recordRefresh', Date.now())
  }

  static closeHistory(): void {
    AppStorage.setOrCreate('showHistory', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openFavorites(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('showFavorites', true)
    AppStorage.setOrCreate('favRefresh', Date.now())
  }

  static closeFavorites(): void {
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openManuscripts(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('showManuscripts', true)
    AppStorage.setOrCreate('hubRefresh', Date.now())
  }

  static closeManuscripts(): void {
    AppStorage.setOrCreate('showManuscripts', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('showUseCaseGuide', false)
    AppStorage.setOrCreate('showDiagnose', true)
  }

  static closeDiagnose(): void {
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openDraft(templateKey: string = ''): void {
    AppStorage.setOrCreate('draftTemplateKey', templateKey)
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('showUseCaseGuide', false)
    AppStorage.setOrCreate('showDraft', true)
  }

  static closeDraft(): void {
    AppStorage.setOrCreate('showDraft', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  /** 把范例/成稿写入润色台并切回润色 Tab */
  static applyToPolish(text: string): void {
    AppStorage.setOrCreate('detailInspirationId', '')
    AppStorage.setOrCreate('detailStyleKey', '')
    AppStorage.setOrCreate('showHistory', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('showManuscripts', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showDraft', false)
    AppStorage.setOrCreate('showScenarioLibrary', false)
    AppStorage.setOrCreate('showUseCaseGuide', false)
    AppStorage.setOrCreate('researchPanel', '')
    AppStorage.setOrCreate('researchItemId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('polishSeedText', text)
    AppStorage.setOrCreate('expressSegment', 0)
    AppStorage.setOrCreate('mainTabIndex', 1)
  }

  static openStyle(key: string): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('detailStyleKey', key)
    AppStorage.setOrCreate('detailStyleRefresh', Date.now())
  }

  static closeStyle(): void {
    AppStorage.setOrCreate('detailStyleKey', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static applyStyleToPolish(styleKey: string, sample: string): void {
    AppStorage.setOrCreate('polishStyleKey', styleKey)
    LanguageCraftNav.applyToPolish(sample)
  }

  /** 创作场景：载入样例 + 自动润色演示 */
  static applyScenarioDemo(scenarioKey: string, sampleText: string, sceneKey: string): void {
    AppStorage.setOrCreate('detailInspirationId', '')
    AppStorage.setOrCreate('detailStyleKey', '')
    AppStorage.setOrCreate('showHistory', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('showManuscripts', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showDraft', false)
    AppStorage.setOrCreate('showScenarioLibrary', false)
    AppStorage.setOrCreate('showUseCaseGuide', false)
    AppStorage.setOrCreate('researchPanel', '')
    AppStorage.setOrCreate('researchItemId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('polishSeedText', sampleText)
    AppStorage.setOrCreate('polishStyleKey', 'formal')
    AppStorage.setOrCreate('polishSceneKey', sceneKey)
    AppStorage.setOrCreate('polishAutoDemo', true)
    AppStorage.setOrCreate('expressSegment', 0)
    AppStorage.setOrCreate('mainTabIndex', 1)
  }

  static applyScenarioDemoRow(scenario: WritingScenario): void {
    LanguageCraftNav.applyScenarioDemo(scenario.key, scenario.sampleText, scenario.sceneKey)
  }

  /** 创作工作流：载入样例 + 指定风格/场景 + 四风格对照 */
  static applyWorkflow(row: WritingWorkflow): void {
    AppStorage.setOrCreate('detailInspirationId', '')
    AppStorage.setOrCreate('detailStyleKey', '')
    AppStorage.setOrCreate('showHistory', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('showManuscripts', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showDraft', false)
    AppStorage.setOrCreate('showScenarioLibrary', false)
    AppStorage.setOrCreate('showUseCaseGuide', false)
    AppStorage.setOrCreate('researchPanel', '')
    AppStorage.setOrCreate('researchItemId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('polishSeedText', row.sampleText)
    AppStorage.setOrCreate('polishStyleKey', row.styleKey)
    AppStorage.setOrCreate('polishSceneKey', row.sceneKey)
    AppStorage.setOrCreate('polishAutoDemo', true)
    AppStorage.setOrCreate('expressSegment', 0)
    AppStorage.setOrCreate('mainTabIndex', 1)
  }

  static openScenarioLibrary(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('showScenarioLibrary', true)
  }

  static closeScenarioLibrary(): void {
    AppStorage.setOrCreate('showScenarioLibrary', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  /** 长文送到摘要 Tab */
  static applyToSummary(text: string, mode: string = 'brief'): void {
    AppStorage.setOrCreate('detailInspirationId', '')
    AppStorage.setOrCreate('showHistory', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('showManuscripts', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showDraft', false)
    AppStorage.setOrCreate('showScenarioLibrary', false)
    AppStorage.setOrCreate('showUseCaseGuide', false)
    AppStorage.setOrCreate('researchPanel', '')
    AppStorage.setOrCreate('researchItemId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('summarySeedText', text)
    AppStorage.setOrCreate('summaryModeSeed', mode)
    AppStorage.setOrCreate('expressSegment', 1)
    AppStorage.setOrCreate('mainTabIndex', 1)
  }

  static openUseCaseGuide(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('showUseCaseGuide', true)
  }

  static closeUseCaseGuide(): void {
    AppStorage.setOrCreate('showUseCaseGuide', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  /** 首页 / 空态：一键演示润色 + 四风格对照 */
  static runQuickDemo(): void {
    const wf = LanguageWorkflowService.all()[0]
    LanguageCraftNav.applyWorkflow(wf)
  }
}
