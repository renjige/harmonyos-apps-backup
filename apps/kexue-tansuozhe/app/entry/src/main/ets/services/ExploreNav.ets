import { ExplorationStore } from './ExplorationStore'

export class ExploreNav {
  static bump(): void {
    const rev = (AppStorage.get<number>('progressRev') ?? 0) + 1
    AppStorage.setOrCreate('progressRev', rev)
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTab', index)
    ExploreNav.bump()
  }

  static anyOverlayOpen(): boolean {
    return AppStorage.get<boolean>('showAtlasDetail') === true ||
      AppStorage.get<boolean>('showRecordEditor') === true ||
      AppStorage.get<boolean>('showRecordDetail') === true ||
      AppStorage.get<boolean>('showSearch') === true ||
      AppStorage.get<boolean>('showStats') === true ||
      AppStorage.get<boolean>('showCalendar') === true ||
      AppStorage.get<boolean>('showTimeline') === true ||
      AppStorage.get<boolean>('showDomainMap') === true ||
      AppStorage.get<boolean>('showBadges') === true ||
      AppStorage.get<boolean>('showChallenge') === true ||
      AppStorage.get<boolean>('showFavorites') === true ||
      AppStorage.get<boolean>('showTopics') === true
  }

  static hideTabBar(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  /** 关闭二级列表页（保留详情/编辑全屏页） */
  static closeHubOverlays(): void {
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('showTopics', false)
    AppStorage.setOrCreate('showCalendar', false)
    AppStorage.setOrCreate('showStats', false)
    AppStorage.setOrCreate('showTimeline', false)
    AppStorage.setOrCreate('showDomainMap', false)
    AppStorage.setOrCreate('showBadges', false)
    AppStorage.setOrCreate('showChallenge', false)
    AppStorage.setOrCreate('showSearch', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static isFullscreenOverlayOpen(): boolean {
    return AppStorage.get<boolean>('showAtlasDetail') === true ||
      AppStorage.get<boolean>('showRecordEditor') === true ||
      AppStorage.get<boolean>('showRecordDetail') === true
  }

  static maybeShowTabBar(): void {
    if (!ExploreNav.isFullscreenOverlayOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private static showHubOverlay(flagKey: string): void {
    AppStorage.setOrCreate(flagKey, true)
    AppStorage.setOrCreate('tabBarHidden', false)
    ExploreNav.bump()
  }

  static openAtlasDetail(id: string): void {
    AppStorage.setOrCreate('atlasDetailId', id)
    AppStorage.setOrCreate('showAtlasDetail', true)
    ExploreNav.hideTabBar()
    ExploreNav.bump()
  }

  static closeAtlasDetail(): void {
    AppStorage.setOrCreate('showAtlasDetail', false)
    AppStorage.setOrCreate('atlasDetailId', '')
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openRecordEditor(id: string): void {
    AppStorage.setOrCreate('recordEditorId', id)
    AppStorage.setOrCreate('showRecordEditor', true)
    ExploreNav.hideTabBar()
    ExploreNav.bump()
  }

  static openNewRecord(): void {
    ExploreNav.openRecordEditor('')
  }

  static closeRecordEditor(): void {
    AppStorage.setOrCreate('showRecordEditor', false)
    AppStorage.setOrCreate('recordEditorId', '')
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openRecordDetail(id: string): void {
    AppStorage.setOrCreate('recordDetailId', id)
    AppStorage.setOrCreate('showRecordDetail', true)
    ExploreNav.hideTabBar()
    ExploreNav.bump()
  }

  static closeRecordDetail(): void {
    AppStorage.setOrCreate('showRecordDetail', false)
    AppStorage.setOrCreate('recordDetailId', '')
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openSearch(): void {
    ExploreNav.showHubOverlay('showSearch')
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('showSearch', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openStats(): void {
    ExploreNav.showHubOverlay('showStats')
  }

  static closeStats(): void {
    AppStorage.setOrCreate('showStats', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openCalendar(): void {
    ExploreNav.showHubOverlay('showCalendar')
  }

  static closeCalendar(): void {
    AppStorage.setOrCreate('showCalendar', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openTimeline(): void {
    ExploreNav.showHubOverlay('showTimeline')
  }

  static closeTimeline(): void {
    AppStorage.setOrCreate('showTimeline', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openDomainMap(): void {
    ExploreNav.showHubOverlay('showDomainMap')
  }

  static closeDomainMap(): void {
    AppStorage.setOrCreate('showDomainMap', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openBadges(): void {
    ExploreNav.showHubOverlay('showBadges')
  }

  static closeBadges(): void {
    AppStorage.setOrCreate('showBadges', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openChallenge(): void {
    ExploreNav.showHubOverlay('showChallenge')
  }

  static closeChallenge(): void {
    AppStorage.setOrCreate('showChallenge', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openFavorites(): void {
    ExploreNav.showHubOverlay('showFavorites')
  }

  static closeFavorites(): void {
    AppStorage.setOrCreate('showFavorites', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }

  static openTopics(): void {
    AppStorage.setOrCreate('showTopics', true)
    ExplorationStore.touchTopicsPanel()
    AppStorage.setOrCreate('tabBarHidden', false)
    ExploreNav.bump()
  }

  static closeTopics(): void {
    AppStorage.setOrCreate('showTopics', false)
    ExploreNav.maybeShowTabBar()
    ExploreNav.bump()
  }
}
