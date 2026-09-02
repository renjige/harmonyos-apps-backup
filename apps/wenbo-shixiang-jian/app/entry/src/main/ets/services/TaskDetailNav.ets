import { TaskItem } from '../models/TaskModels'
import { TaskDetailCache } from './TaskDetailCache'

/** 全局详情导航 — MainTabPage 顶层 Overlay */
export class TaskDetailNav {
  static openTask(id: string, preview?: TaskItem): void {
    if (preview !== undefined) {
      TaskDetailCache.save(preview)
    }
    AppStorage.setOrCreate('detailRoute', `task:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openTip(id: string): void {
    AppStorage.setOrCreate('detailRoute', `tip:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static close(): void {
    TaskDetailCache.clear()
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return TaskDetailNav.currentRoute().length > 0
  }

  static parseKind(): string {
    const route = TaskDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = TaskDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }
}
