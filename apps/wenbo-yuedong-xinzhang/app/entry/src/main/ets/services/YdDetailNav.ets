/** 跃动新章 — 全局详情 / 表单 Overlay 路由 */
export class YdDetailNav {
  static openGoalDetail(id: string): void {
    AppStorage.setOrCreate('ydGoalDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeGoalDetail(): void {
    AppStorage.setOrCreate('ydGoalDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openGoalCreate(): void {
    AppStorage.setOrCreate('ydGoalCreateOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeGoalCreate(): void {
    AppStorage.setOrCreate('ydGoalCreateOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openTaskAdd(): void {
    AppStorage.setOrCreate('ydTaskAddOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTaskAdd(): void {
    AppStorage.setOrCreate('ydTaskAddOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openTaskDetail(id: string): void {
    AppStorage.setOrCreate('ydTaskDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTaskDetail(): void {
    AppStorage.setOrCreate('ydTaskDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openChapterCreate(): void {
    AppStorage.setOrCreate('ydChapterCreateOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeChapterCreate(): void {
    AppStorage.setOrCreate('ydChapterCreateOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openChapterDetail(id: string): void {
    AppStorage.setOrCreate('ydChapterDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeChapterDetail(): void {
    AppStorage.setOrCreate('ydChapterDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openSearch(): void {
    AppStorage.setOrCreate('ydSearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('ydSearchOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openFavorites(): void {
    AppStorage.setOrCreate('ydFavoritesOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFavorites(): void {
    AppStorage.setOrCreate('ydFavoritesOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openCheckIn(): void {
    AppStorage.setOrCreate('ydCheckInOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCheckIn(): void {
    AppStorage.setOrCreate('ydCheckInOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openTagsManage(): void {
    AppStorage.setOrCreate('ydTagsOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTagsManage(): void {
    AppStorage.setOrCreate('ydTagsOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openHelp(): void {
    AppStorage.setOrCreate('ydHelpOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeHelp(): void {
    AppStorage.setOrCreate('ydHelpOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openLegal(kind: string): void {
    AppStorage.setOrCreate('ydLegalKind', kind)
    AppStorage.setOrCreate('ydLegalOpen', true)
  }

  static closeLegal(): void {
    AppStorage.setOrCreate('ydLegalOpen', false)
  }

  static openFromSearch(hitType: string, hitId: string): void {
    YdDetailNav.closeSearch()
    if (hitType === 'task') {
      YdDetailNav.openTaskDetail(hitId)
    } else if (hitType === 'chapter') {
      YdDetailNav.openChapterDetail(hitId)
    } else if (hitType === 'goal') {
      YdDetailNav.openGoalDetail(hitId)
    }
  }

  static openFromFavorite(entityType: string, entityId: string): void {
    YdDetailNav.closeFavorites()
    if (entityType === 'task') {
      YdDetailNav.openTaskDetail(entityId)
    } else if (entityType === 'chapter') {
      YdDetailNav.openChapterDetail(entityId)
    } else if (entityType === 'goal') {
      YdDetailNav.openGoalDetail(entityId)
    }
  }
}
