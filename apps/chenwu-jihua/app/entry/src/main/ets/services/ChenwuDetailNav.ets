import { ChenwuStore } from './ChenwuStore'

export class ChenwuDetailNav {
  static openGoal(id: string): void {
    AppStorage.setOrCreate('cwGoalId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeGoal(): void {
    AppStorage.setOrCreate('cwGoalId', '')
    ChenwuDetailNav.restore()
    ChenwuStore.bump()
  }

  static openPlan(id: string): void {
    AppStorage.setOrCreate('cwPlanId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closePlan(): void {
    AppStorage.setOrCreate('cwPlanId', '')
    ChenwuDetailNav.restore()
    ChenwuStore.bump()
  }

  static openHabit(id: string): void {
    AppStorage.setOrCreate('cwHabitId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeHabit(): void {
    AppStorage.setOrCreate('cwHabitId', '')
    ChenwuDetailNav.restore()
  }

  static openJournal(id: string): void {
    AppStorage.setOrCreate('cwJournalId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeJournal(): void {
    AppStorage.setOrCreate('cwJournalId', '')
    ChenwuDetailNav.restore()
  }

  static openReview(phaseId: string): void {
    AppStorage.setOrCreate('cwReviewPhaseId', phaseId)
    AppStorage.setOrCreate('cwReviewSheetOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeReview(): void {
    AppStorage.setOrCreate('cwReviewSheetOpen', false)
    AppStorage.setOrCreate('cwReviewPhaseId', '')
    ChenwuDetailNav.restore()
  }

  static openGoalEditor(id: string): void {
    AppStorage.setOrCreate('cwGoalEditorOpen', true)
    AppStorage.setOrCreate('cwGoalId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeGoalEditor(): void {
    AppStorage.setOrCreate('cwGoalEditorOpen', false)
    AppStorage.setOrCreate('cwGoalId', '')
    ChenwuDetailNav.restore()
  }

  static openPlanEditor(id: string): void {
    AppStorage.setOrCreate('cwPlanEditorGoalId', '')
    AppStorage.setOrCreate('cwPlanEditorOpen', true)
    AppStorage.setOrCreate('cwPlanId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  /** 从目标详情新建计划：预填关联目标，且编辑器叠在目标页之上 */
  static openPlanEditorForGoal(goalId: string): void {
    AppStorage.setOrCreate('cwPlanEditorGoalId', goalId)
    AppStorage.setOrCreate('cwPlanEditorOpen', true)
    AppStorage.setOrCreate('cwPlanId', '')
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closePlanEditor(): void {
    AppStorage.setOrCreate('cwPlanEditorOpen', false)
    AppStorage.setOrCreate('cwPlanId', '')
    AppStorage.setOrCreate('cwPlanEditorGoalId', '')
    ChenwuDetailNav.restore()
  }

  static openHabitRecord(id: string): void {
    AppStorage.setOrCreate('cwHabitRecordOpen', true)
    AppStorage.setOrCreate('cwHabitId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeHabitRecord(): void {
    AppStorage.setOrCreate('cwHabitRecordOpen', false)
    AppStorage.setOrCreate('cwHabitId', '')
    ChenwuDetailNav.restore()
    ChenwuStore.bump()
  }

  static openJournalEditor(id: string): void {
    AppStorage.setOrCreate('cwJournalEditorOpen', true)
    AppStorage.setOrCreate('cwJournalId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeJournalEditor(): void {
    AppStorage.setOrCreate('cwJournalEditorOpen', false)
    AppStorage.setOrCreate('cwJournalId', '')
    ChenwuDetailNav.restore()
    ChenwuStore.bump()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('cwSearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('cwSearchOpen', false)
    ChenwuDetailNav.restore()
  }

  static openOrganize(): void {
    AppStorage.setOrCreate('cwOrganizeOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeOrganize(): void {
    AppStorage.setOrCreate('cwOrganizeOpen', false)
    ChenwuDetailNav.restore()
  }

  static openAnnual(): void {
    AppStorage.setOrCreate('cwAnnualOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeAnnual(): void {
    AppStorage.setOrCreate('cwAnnualOpen', false)
    ChenwuDetailNav.restore()
  }

  static openAchievements(): void {
    AppStorage.setOrCreate('cwAchievementsOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeAchievements(): void {
    AppStorage.setOrCreate('cwAchievementsOpen', false)
    ChenwuDetailNav.restore()
  }

  static restore(): void {
    const wasHidden = AppStorage.get<boolean>('tabBarHidden') === true
    const goalId = AppStorage.get<string>('cwGoalId') ?? ''
    const planId = AppStorage.get<string>('cwPlanId') ?? ''
    const habitId = AppStorage.get<string>('cwHabitId') ?? ''
    const journalId = AppStorage.get<string>('cwJournalId') ?? ''
    const reviewPhaseId = AppStorage.get<string>('cwReviewPhaseId') ?? ''
    const goalEd = AppStorage.get<boolean>('cwGoalEditorOpen') === true
    const planEd = AppStorage.get<boolean>('cwPlanEditorOpen') === true
    const habitRec = AppStorage.get<boolean>('cwHabitRecordOpen') === true
    const journalEd = AppStorage.get<boolean>('cwJournalEditorOpen') === true
    const review = AppStorage.get<boolean>('cwReviewSheetOpen') === true
    const search = AppStorage.get<boolean>('cwSearchOpen') === true
    const organize = AppStorage.get<boolean>('cwOrganizeOpen') === true
    const annual = AppStorage.get<boolean>('cwAnnualOpen') === true
    const achievements = AppStorage.get<boolean>('cwAchievementsOpen') === true
    const hidden = goalId.length > 0 || planId.length > 0 || habitId.length > 0 || journalId.length > 0
      || reviewPhaseId.length > 0 || goalEd || planEd || habitRec || journalEd || review
      || search || organize || annual || achievements
    AppStorage.setOrCreate('tabBarHidden', hidden)
    if (wasHidden && !hidden) {
      ChenwuStore.bump()
    }
  }
}
