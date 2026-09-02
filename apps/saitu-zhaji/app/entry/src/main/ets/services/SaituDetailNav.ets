export class SaituDetailNav {
  static restoreTabBar(): void {
    const anyOpen = AppStorage.get<boolean>('saituDetailOpen') === true
      || AppStorage.get<boolean>('saituEditorOpen') === true
      || AppStorage.get<boolean>('saituJourneyManageOpen') === true
      || AppStorage.get<boolean>('saituMilestoneOpen') === true
      || AppStorage.get<boolean>('saituMilestoneEditorOpen') === true
      || AppStorage.get<boolean>('saituInsightDetailOpen') === true
      || AppStorage.get<boolean>('saituSportDetailOpen') === true
      || AppStorage.get<boolean>('saituSportEditorOpen') === true
      || AppStorage.get<boolean>('saituAlbumDetailOpen') === true
      || AppStorage.get<boolean>('saituAlbumEditorOpen') === true
      || AppStorage.get<boolean>('saituFollowOpen') === true
      || AppStorage.get<boolean>('saituTimelineOpen') === true
      || AppStorage.get<boolean>('saituCheckInEditorOpen') === true
      || AppStorage.get<boolean>('saituPlanEditorOpen') === true
      || AppStorage.get<boolean>('saituPlanOpen') === true
      || AppStorage.get<boolean>('saituSportHubOpen') === true
      || AppStorage.get<boolean>('saituSportComposerOpen') === true
      || AppStorage.get<boolean>('saituJourneyDetailOpen') === true
      || AppStorage.get<boolean>('saituFollowDetailOpen') === true
      || AppStorage.get<boolean>('saituTrainingDetailOpen') === true
      || AppStorage.get<boolean>('saituTrainingEditorOpen') === true
      || AppStorage.get<boolean>('saituScenarioOpen') === true
    AppStorage.setOrCreate('tabBarHidden', anyOpen)
  }

  static openRecord(recordId: string): void {
    AppStorage.setOrCreate('saituDetailRecordId', recordId)
    AppStorage.setOrCreate('saituDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openEditor(recordId: string): void {
    const session = (AppStorage.get<number>('saituEditorSession') ?? 0) + 1
    AppStorage.setOrCreate('saituEditorSession', session)
    AppStorage.setOrCreate('saituEditorRecordId', recordId)
    AppStorage.setOrCreate('saituEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openNewEditor(): void {
    const session = (AppStorage.get<number>('saituEditorSession') ?? 0) + 1
    AppStorage.setOrCreate('saituEditorSession', session)
    AppStorage.setOrCreate('saituEditorRecordId', '')
    AppStorage.setOrCreate('saituEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openJourneyManage(): void {
    AppStorage.setOrCreate('saituJourneyManageOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openMilestone(id: string): void {
    AppStorage.setOrCreate('saituMilestoneId', id)
    AppStorage.setOrCreate('saituMilestoneOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openMilestoneEditor(id: string, journeyId: string): void {
    AppStorage.setOrCreate('saituMilestoneEditorId', id)
    AppStorage.setOrCreate('saituMilestoneJourneyId', journeyId)
    AppStorage.setOrCreate('saituMilestoneEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openInsight(id: string): void {
    AppStorage.setOrCreate('saituInsightId', id)
    AppStorage.setOrCreate('saituInsightDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSportDetail(id: string): void {
    AppStorage.setOrCreate('saituSportDetailId', id)
    AppStorage.setOrCreate('saituSportDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSportEditor(id: string, kind: string): void {
    const session = (AppStorage.get<number>('saituSportEditorSession') ?? 0) + 1
    AppStorage.setOrCreate('saituSportEditorSession', session)
    AppStorage.setOrCreate('saituSportEditorId', id)
    AppStorage.setOrCreate('saituSportEditorKind', kind)
    AppStorage.setOrCreate('saituSportEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openNewSportEditor(kind: string, albumId: string): void {
    const session = (AppStorage.get<number>('saituSportEditorSession') ?? 0) + 1
    AppStorage.setOrCreate('saituSportEditorSession', session)
    AppStorage.setOrCreate('saituSportEditorId', '')
    AppStorage.setOrCreate('saituSportEditorKind', kind)
    AppStorage.setOrCreate('saituSportEditorAlbumId', albumId)
    AppStorage.setOrCreate('saituSportEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openAlbumDetail(id: string): void {
    AppStorage.setOrCreate('saituAlbumDetailId', id)
    AppStorage.setOrCreate('saituAlbumDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openAlbumEditor(id: string): void {
    AppStorage.setOrCreate('saituAlbumEditorId', id)
    AppStorage.setOrCreate('saituAlbumEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFollow(): void {
    AppStorage.setOrCreate('saituFollowOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openTimeline(): void {
    AppStorage.setOrCreate('saituTimelineOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openCheckInEditor(journeyId: string): void {
    AppStorage.setOrCreate('saituCheckInJourneyId', journeyId)
    AppStorage.setOrCreate('saituCheckInEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openNewPlan(journeyId: string): void {
    AppStorage.setOrCreate('saituPlanEditorId', '')
    AppStorage.setOrCreate('saituPlanJourneyId', journeyId)
    AppStorage.setOrCreate('saituPlanEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openPlanEditor(planId: string): void {
    AppStorage.setOrCreate('saituPlanEditorId', planId)
    AppStorage.setOrCreate('saituPlanEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openPlan(planId: string): void {
    AppStorage.setOrCreate('saituPlanId', planId)
    AppStorage.setOrCreate('saituPlanOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSportHub(): void {
    AppStorage.setOrCreate('saituSportHubOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSportComposer(): void {
    AppStorage.setOrCreate('saituSportComposerOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSportComposer(): void {
    AppStorage.setOrCreate('saituSportComposerOpen', false)
    SaituDetailNav.restoreTabBar()
  }

  /** 从添加档案 sheet 选择类型 → 关 sheet/中枢 → 开对应编辑器 */
  static pickSportComposer(key: string): void {
    AppStorage.setOrCreate('saituSportComposerOpen', false)
    AppStorage.setOrCreate('saituSportHubOpen', false)
    if (key === 'album') {
      SaituDetailNav.openAlbumEditor('')
      return
    }
    if (key === 'training') {
      SaituDetailNav.openNewTrainingEditor()
      return
    }
    if (key === 'follow') {
      SaituDetailNav.openFollow()
      return
    }
    SaituDetailNav.openNewSportEditor(key, '')
  }

  static openJourneyDetail(id: string): void {
    AppStorage.setOrCreate('saituJourneyDetailId', id)
    AppStorage.setOrCreate('saituJourneyDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFollowDetail(id: string): void {
    AppStorage.setOrCreate('saituFollowDetailId', id)
    AppStorage.setOrCreate('saituFollowDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openTrainingDetail(id: string): void {
    AppStorage.setOrCreate('saituTrainingDetailId', id)
    AppStorage.setOrCreate('saituTrainingDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openTrainingEditor(id: string): void {
    const session = (AppStorage.get<number>('saituTrainingEditorSession') ?? 0) + 1
    AppStorage.setOrCreate('saituTrainingEditorSession', session)
    AppStorage.setOrCreate('saituTrainingEditorId', id)
    AppStorage.setOrCreate('saituTrainingEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openNewTrainingEditor(): void {
    SaituDetailNav.openTrainingEditor('')
  }

  static openScenarioGuide(): void {
    AppStorage.setOrCreate('saituScenarioOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeScenarioGuide(): void {
    AppStorage.setOrCreate('saituScenarioOpen', false)
    SaituDetailNav.restoreTabBar()
  }

  static closeSportHub(): void {
    AppStorage.setOrCreate('saituSportHubOpen', false)
    SaituDetailNav.restoreTabBar()
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('saituDetailOpen', false)
    AppStorage.setOrCreate('saituDetailRecordId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeEditor(): void {
    AppStorage.setOrCreate('saituEditorOpen', false)
    AppStorage.setOrCreate('saituEditorRecordId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeJourneyManage(): void {
    AppStorage.setOrCreate('saituJourneyManageOpen', false)
    SaituDetailNav.restoreTabBar()
  }

  static closeMilestone(): void {
    AppStorage.setOrCreate('saituMilestoneOpen', false)
    AppStorage.setOrCreate('saituMilestoneId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeMilestoneEditor(): void {
    AppStorage.setOrCreate('saituMilestoneEditorOpen', false)
    AppStorage.setOrCreate('saituMilestoneEditorId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeInsight(): void {
    AppStorage.setOrCreate('saituInsightDetailOpen', false)
    AppStorage.setOrCreate('saituInsightId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeSportDetail(): void {
    AppStorage.setOrCreate('saituSportDetailOpen', false)
    AppStorage.setOrCreate('saituSportDetailId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeSportEditor(): void {
    AppStorage.setOrCreate('saituSportEditorOpen', false)
    AppStorage.setOrCreate('saituSportEditorId', '')
    AppStorage.setOrCreate('saituSportEditorAlbumId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeAlbumDetail(): void {
    AppStorage.setOrCreate('saituAlbumDetailOpen', false)
    AppStorage.setOrCreate('saituAlbumDetailId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeAlbumEditor(): void {
    AppStorage.setOrCreate('saituAlbumEditorOpen', false)
    AppStorage.setOrCreate('saituAlbumEditorId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeFollow(): void {
    AppStorage.setOrCreate('saituFollowOpen', false)
    SaituDetailNav.restoreTabBar()
  }

  static closeTimeline(): void {
    AppStorage.setOrCreate('saituTimelineOpen', false)
    SaituDetailNav.restoreTabBar()
  }

  static closeCheckInEditor(): void {
    AppStorage.setOrCreate('saituCheckInEditorOpen', false)
    AppStorage.setOrCreate('saituCheckInJourneyId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closePlanEditor(): void {
    AppStorage.setOrCreate('saituPlanEditorOpen', false)
    AppStorage.setOrCreate('saituPlanEditorId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closePlan(): void {
    AppStorage.setOrCreate('saituPlanOpen', false)
    AppStorage.setOrCreate('saituPlanId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeJourneyDetail(): void {
    AppStorage.setOrCreate('saituJourneyDetailOpen', false)
    AppStorage.setOrCreate('saituJourneyDetailId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeFollowDetail(): void {
    AppStorage.setOrCreate('saituFollowDetailOpen', false)
    AppStorage.setOrCreate('saituFollowDetailId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeTrainingDetail(): void {
    AppStorage.setOrCreate('saituTrainingDetailOpen', false)
    AppStorage.setOrCreate('saituTrainingDetailId', '')
    SaituDetailNav.restoreTabBar()
  }

  static closeTrainingEditor(): void {
    AppStorage.setOrCreate('saituTrainingEditorOpen', false)
    AppStorage.setOrCreate('saituTrainingEditorId', '')
    SaituDetailNav.restoreTabBar()
  }
}
