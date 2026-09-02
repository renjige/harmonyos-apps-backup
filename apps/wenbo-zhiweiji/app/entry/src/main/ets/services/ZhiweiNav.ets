export class ZhiweiNav {
  static openCompose(editId: string, voice: boolean): void {
    AppStorage.setOrCreate('zwComposeId', editId)
    AppStorage.setOrCreate('zwComposeVoice', voice)
    AppStorage.setOrCreate('zwComposeTemplateId', '')
    AppStorage.setOrCreate('zwShowCompose', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openComposeTemplate(templateId: string): void {
    AppStorage.setOrCreate('zwComposeId', '')
    AppStorage.setOrCreate('zwComposeVoice', false)
    AppStorage.setOrCreate('zwComposeTemplateId', templateId)
    AppStorage.setOrCreate('zwShowCompose', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCompose(): void {
    AppStorage.setOrCreate('zwShowCompose', false)
    AppStorage.setOrCreate('zwComposeId', '')
    AppStorage.setOrCreate('zwComposeVoice', false)
    AppStorage.setOrCreate('zwComposeTemplateId', '')
    ZhiweiNav.restoreTab()
  }

  static openCapture(id: string): void {
    AppStorage.setOrCreate('zwCaptureId', id)
    AppStorage.setOrCreate('zwShowCapture', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCapture(): void {
    AppStorage.setOrCreate('zwShowCapture', false)
    AppStorage.setOrCreate('zwCaptureId', '')
    ZhiweiNav.restoreTab()
  }

  static openQuote(id: string): void {
    AppStorage.setOrCreate('zwQuoteId', id)
    AppStorage.setOrCreate('zwShowQuote', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeQuote(): void {
    AppStorage.setOrCreate('zwShowQuote', false)
    AppStorage.setOrCreate('zwQuoteId', '')
    ZhiweiNav.restoreTab()
  }

  static openWeekly(): void {
    AppStorage.setOrCreate('zwShowWeekly', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWeekly(): void {
    AppStorage.setOrCreate('zwShowWeekly', false)
    ZhiweiNav.restoreTab()
  }

  static openFocus(kind: string, key: string, title: string): void {
    AppStorage.setOrCreate('zwFocusKind', kind)
    AppStorage.setOrCreate('zwFocusKey', key)
    AppStorage.setOrCreate('zwFocusTitle', title)
    AppStorage.setOrCreate('zwShowFocus', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFocus(): void {
    AppStorage.setOrCreate('zwShowFocus', false)
    AppStorage.setOrCreate('zwFocusKind', '')
    AppStorage.setOrCreate('zwFocusKey', '')
    AppStorage.setOrCreate('zwFocusTitle', '')
    ZhiweiNav.restoreTab()
  }

  static openLibrary(): void {
    AppStorage.setOrCreate('zwShowLibrary', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeLibrary(): void {
    AppStorage.setOrCreate('zwShowLibrary', false)
    ZhiweiNav.restoreTab()
  }

  static openDaily(dailyId: string = ''): void {
    AppStorage.setOrCreate('zwDailyId', dailyId)
    AppStorage.setOrCreate('zwShowDaily', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDaily(): void {
    AppStorage.setOrCreate('zwShowDaily', false)
    AppStorage.setOrCreate('zwDailyId', '')
    ZhiweiNav.restoreTab()
  }

  static openKnowledgeCatalog(): void {
    AppStorage.setOrCreate('zwShowKnowledgeCatalog', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeKnowledgeCatalog(): void {
    AppStorage.setOrCreate('zwShowKnowledgeCatalog', false)
    ZhiweiNav.restoreTab()
  }

  static openReviewDeck(): void {
    AppStorage.setOrCreate('zwShowReviewDeck', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeReviewDeck(): void {
    AppStorage.setOrCreate('zwShowReviewDeck', false)
    ZhiweiNav.restoreTab()
  }

  static openLearningPath(): void {
    AppStorage.setOrCreate('zwShowLearningPath', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeLearningPath(): void {
    AppStorage.setOrCreate('zwShowLearningPath', false)
    ZhiweiNav.restoreTab()
  }

  static openInbox(): void {
    AppStorage.setOrCreate('zwShowInbox', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeInbox(): void {
    AppStorage.setOrCreate('zwShowInbox', false)
    ZhiweiNav.restoreTab()
  }

  static openAllCaptures(): void {
    AppStorage.setOrCreate('zwShowAllCaptures', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeAllCaptures(): void {
    AppStorage.setOrCreate('zwShowAllCaptures', false)
    ZhiweiNav.restoreTab()
  }

  static openTimeline(): void {
    AppStorage.setOrCreate('zwShowTimeline', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTimeline(): void {
    AppStorage.setOrCreate('zwShowTimeline', false)
    ZhiweiNav.restoreTab()
  }

  static openReview(period: string): void {
    AppStorage.setOrCreate('zwReviewPeriod', period)
    AppStorage.setOrCreate('zwShowReview', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeReview(): void {
    AppStorage.setOrCreate('zwShowReview', false)
    ZhiweiNav.restoreTab()
  }

  static openAchievement(): void {
    AppStorage.setOrCreate('zwShowAchievement', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeAchievement(): void {
    AppStorage.setOrCreate('zwShowAchievement', false)
    ZhiweiNav.restoreTab()
  }

  static openPlan(): void {
    AppStorage.setOrCreate('zwShowPlan', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closePlan(): void {
    AppStorage.setOrCreate('zwShowPlan', false)
    ZhiweiNav.restoreTab()
  }

  static restoreTab(): void {
    if (!ZhiweiNav.anyOverlayOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static anyOverlayOpen(): boolean {
    return ZhiweiNav.isComposeOpen() || ZhiweiNav.isCaptureDetailOpen() ||
      ZhiweiNav.isQuoteDetailOpen() || ZhiweiNav.isWeeklyOpen() ||
      ZhiweiNav.isFocusOpen() || ZhiweiNav.isLibraryOpen() || ZhiweiNav.isDailyOpen() ||
      ZhiweiNav.isAllCapturesOpen() || ZhiweiNav.isTimelineOpen() ||
      ZhiweiNav.isReviewOpen() || ZhiweiNav.isAchievementOpen() || ZhiweiNav.isPlanOpen() ||
      ZhiweiNav.isKnowledgeCatalogOpen() || ZhiweiNav.isReviewDeckOpen() || ZhiweiNav.isInboxOpen() ||
      ZhiweiNav.isLearningPathOpen()
  }

  static isFocusOpen(): boolean {
    return AppStorage.get<boolean>('zwShowFocus') === true
  }

  static isComposeOpen(): boolean {
    return AppStorage.get<boolean>('zwShowCompose') === true
  }

  static isCaptureDetailOpen(): boolean {
    return AppStorage.get<boolean>('zwShowCapture') === true
  }

  static isQuoteDetailOpen(): boolean {
    return AppStorage.get<boolean>('zwShowQuote') === true
  }

  static isWeeklyOpen(): boolean {
    return AppStorage.get<boolean>('zwShowWeekly') === true
  }

  static isLibraryOpen(): boolean {
    return AppStorage.get<boolean>('zwShowLibrary') === true
  }

  static isDailyOpen(): boolean {
    return AppStorage.get<boolean>('zwShowDaily') === true
  }

  static isAllCapturesOpen(): boolean {
    return AppStorage.get<boolean>('zwShowAllCaptures') === true
  }

  static isTimelineOpen(): boolean {
    return AppStorage.get<boolean>('zwShowTimeline') === true
  }

  static isReviewOpen(): boolean {
    return AppStorage.get<boolean>('zwShowReview') === true
  }

  static isAchievementOpen(): boolean {
    return AppStorage.get<boolean>('zwShowAchievement') === true
  }

  static isPlanOpen(): boolean {
    return AppStorage.get<boolean>('zwShowPlan') === true
  }

  static isKnowledgeCatalogOpen(): boolean {
    return AppStorage.get<boolean>('zwShowKnowledgeCatalog') === true
  }

  static isReviewDeckOpen(): boolean {
    return AppStorage.get<boolean>('zwShowReviewDeck') === true
  }

  static isInboxOpen(): boolean {
    return AppStorage.get<boolean>('zwShowInbox') === true
  }

  static isLearningPathOpen(): boolean {
    return AppStorage.get<boolean>('zwShowLearningPath') === true
  }
}
