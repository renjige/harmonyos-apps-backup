/** 全局 Overlay 路由：编辑 / 详情 / 标签管理 */

import { YouyuStore } from './YouyuStore'

export class YouyuNav {
  static openCompose(editId: string): void {
    AppStorage.setOrCreate('youyuComposeId', editId)
    AppStorage.setOrCreate('youyuShowCompose', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCompose(): void {
    AppStorage.setOrCreate('youyuShowCompose', false)
    AppStorage.setOrCreate('youyuComposeId', '')
    if (!YouyuNav.isDetailOpen() && !YouyuNav.isTagsOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    YouyuStore.touchUi()
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('youyuDetailId', id)
    AppStorage.setOrCreate('youyuShowDetail', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('youyuShowDetail', false)
    AppStorage.setOrCreate('youyuDetailId', '')
    if (!YouyuNav.isComposeOpen() && !YouyuNav.isTagsOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    YouyuStore.touchUi()
  }

  static openTags(): void {
    AppStorage.setOrCreate('youyuShowTags', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTags(): void {
    AppStorage.setOrCreate('youyuShowTags', false)
    if (!YouyuNav.isComposeOpen() && !YouyuNav.isDetailOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    YouyuStore.touchUi()
  }

  static isComposeOpen(): boolean {
    return AppStorage.get<boolean>('youyuShowCompose') === true
  }

  static isDetailOpen(): boolean {
    return AppStorage.get<boolean>('youyuShowDetail') === true
  }

  static isTagsOpen(): boolean {
    return AppStorage.get<boolean>('youyuShowTags') === true
  }

  static composeId(): string {
    return AppStorage.get<string>('youyuComposeId') ?? ''
  }

  static detailId(): string {
    return AppStorage.get<string>('youyuDetailId') ?? ''
  }
}
