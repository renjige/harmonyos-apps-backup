import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { InsightItem } from '../models/AskModels'
import { LearningPath, PathDef, PathStep } from '../models/PathModels'
import { AskBizService } from './AskBizService'
import { GrowthStore } from './GrowthStore'

const STORE_NAME = 'wenzhi_paths'
const KEY_DONE = 'path_done_json'

export class PathStore {
  private static pref: preferences.Preferences | null = null
  private static doneKeys: string[] = []
  private static paths: LearningPath[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PathStore.pref = await preferences.getPreferences(context, STORE_NAME)
      PathStore.doneKeys = PathStore.parseDone(await PathStore.str(KEY_DONE, '[]'))
    } catch {
      PathStore.doneKeys = []
    }
  }

  static async ensureReady(): Promise<void> {
    if (PathStore.ready && PathStore.paths.length > 0) {
      return
    }
    const insights = await AskBizService.loadInsights()
    PathStore.paths = PathStore.buildPaths(insights)
    PathStore.ready = true
  }

  static all(): LearningPath[] {
    const out: LearningPath[] = []
    for (const p of PathStore.paths) {
      out.push(p)
    }
    return out
  }

  static find(pathId: string): LearningPath | undefined {
    for (const p of PathStore.paths) {
      if (p.id === pathId) {
        return p
      }
    }
    return undefined
  }

  static firstIncompletePathId(): string {
    for (const p of PathStore.paths) {
      if (p.doneCount() < p.totalCount()) {
        return p.id
      }
    }
    if (PathStore.paths.length > 0) {
      return PathStore.paths[0].id
    }
    return ''
  }

  static isStepDone(pathId: string, stepId: string): boolean {
    const key = `${pathId}:${stepId}`
    for (const k of PathStore.doneKeys) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  static async markStepDone(pathId: string, stepId: string, title: string): Promise<void> {
    const key = `${pathId}:${stepId}`
    let exists = false
    for (const k of PathStore.doneKeys) {
      if (k === key) {
        exists = true
        break
      }
    }
    if (!exists) {
      PathStore.doneKeys.push(key)
      await PathStore.flush()
    }
    for (const p of PathStore.paths) {
      if (p.id === pathId) {
        for (const s of p.steps) {
          if (s.id === stepId) {
            s.done = true
          }
        }
      }
    }
    await GrowthStore.logActivity('path', title, stepId, pathId)
  }

  private static buildPaths(insights: InsightItem[]): LearningPath[] {
    const defs = PathStore.defs()
    const out: LearningPath[] = []
    for (const d of defs) {
      const path = new LearningPath()
      path.id = d.id
      path.title = d.title
      path.subtitle = d.subtitle
      path.coverKey = d.coverKey
      const matched: InsightItem[] = []
      for (const row of insights) {
        if (d.topic.length > 0 && row.topic === d.topic) {
          matched.push(row)
        } else if (d.category.length > 0 && row.category === d.category) {
          matched.push(row)
        }
      }
      let order = 0
      for (let i = 0; i < matched.length && i < 4; i++) {
        const row = matched[i]
        const step = new PathStep()
        step.id = `${d.id}_s${order}`
        step.insightId = row.id
        step.title = row.title
        step.summary = row.summary
        step.order = order
        step.done = PathStore.isStepDone(d.id, step.id)
        path.steps.push(step)
        order += 1
      }
      if (path.steps.length > 0) {
        out.push(path)
      }
    }
    return out
  }

  private static defs(): PathDef[] {
    const out: PathDef[] = []
    const rows: string[][] = [
      ['path_history', '历史文化入门', '从典故到人物，建立脉络', 'cover_history', '历史专题', '历史文化'],
      ['path_science', '科学素养路径', '用问答理解常见科学概念', 'cover_tech', '科学专题', '科普知识'],
      ['path_life', '生活实用指南', '健康、习惯与日常决策', 'cover_life', '生活技巧专题', '生活百科'],
      ['path_culture', '文化通识精选', '语言、艺术与当代文化', 'cover_study', '文化专题', '学习知识']
    ]
    for (const r of rows) {
      const d = new PathDef()
      d.id = r[0]
      d.title = r[1]
      d.subtitle = r[2]
      d.coverKey = r[3]
      d.topic = r[4]
      d.category = r[5]
      out.push(d)
    }
    return out
  }

  private static async flush(): Promise<void> {
    if (PathStore.pref === null) {
      return
    }
    try {
      await PathStore.pref.put(KEY_DONE, JSON.stringify(PathStore.doneKeys))
      await PathStore.pref.flush()
    } catch {
    }
  }

  private static async str(key: string, fallback: string): Promise<string> {
    if (PathStore.pref === null) {
      return fallback
    }
    const raw = await PathStore.pref.get(key, fallback)
    return typeof raw === 'string' ? raw : fallback
  }

  private static parseDone(raw: string): string[] {
    const out: string[] = []
    try {
      const arr = JSON.parse(raw) as string[]
      if (Array.isArray(arr)) {
        for (const k of arr) {
          if (typeof k === 'string' && k.length > 0) {
            out.push(k)
          }
        }
      }
    } catch {
    }
    return out
  }
}
