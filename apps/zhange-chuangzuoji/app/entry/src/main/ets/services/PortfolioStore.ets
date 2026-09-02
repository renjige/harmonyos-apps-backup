import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { PortfolioProject } from '../models/PortfolioModels'

const STORE = 'zhange_portfolio_v1'
const KEY_PROJECTS = 'projects'
const KEY_SEEDED = 'seeded'

export class PortfolioStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PortfolioStore.pref = await preferences.getPreferences(context, STORE)
      await PortfolioStore.ensureSeed()
    } catch {
      PortfolioStore.pref = null
    }
  }

  static async loadAll(): Promise<PortfolioProject[]> {
    const raw = await PortfolioStore.getString(KEY_PROJECTS, '')
    return PortfolioStore.parseProjects(raw)
  }

  static async findById(id: string): Promise<PortfolioProject | undefined> {
    const list = await PortfolioStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async replaceAll(projects: PortfolioProject[]): Promise<void> {
    await PortfolioStore.persistProjects(projects)
  }

  static async deleteProject(id: string): Promise<void> {
    const list = await PortfolioStore.loadAll()
    const next: PortfolioProject[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await PortfolioStore.persistProjects(next)
  }

  static async saveProject(project: PortfolioProject): Promise<void> {
    const list = await PortfolioStore.loadAll()
    const next: PortfolioProject[] = []
    let found = false
    for (const it of list) {
      if (it.id === project.id) {
        next.push(project)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.unshift(project)
    }
    await PortfolioStore.persistProjects(next)
  }

  static async lastUpdatedLabel(): Promise<string> {
    const list = await PortfolioStore.loadAll()
    if (list.length === 0) {
      return '—'
    }
    let latest = list[0].createdAt
    for (const it of list) {
      if (it.createdAt > latest) {
        latest = it.createdAt
      }
    }
    return latest
  }

  static async categoryIdsInUse(): Promise<string[]> {
    const list = await PortfolioStore.loadAll()
    const ids: string[] = []
    for (const it of list) {
      if (it.category !== 'all' && ids.indexOf(it.category) < 0) {
        ids.push(it.category)
      }
    }
    return ids
  }

  private static async ensureSeed(): Promise<void> {
    const seeded = await PortfolioStore.getString(KEY_SEEDED, '')
    if (seeded === '1') {
      return
    }
    const samples = PortfolioStore.defaultSamples()
    await PortfolioStore.persistProjects(samples)
    await PortfolioStore.putString(KEY_SEEDED, '1', true)
  }

  private static defaultSamples(): PortfolioProject[] {
    const items: PortfolioProject[] = []
    const p1 = new PortfolioProject()
    p1.id = 'p1'
    p1.title = '智慧家居控制台'
    p1.category = 'ui'
    p1.coverKey = 'cat_ui'
    p1.imageKeys = ['cat_ui', 'case_dev']
    p1.description = '为智慧家居场景设计的控制台界面，强调信息层级与一键场景切换。采用深色模式与高对比度控件，适配 HarmonyOS 设计语言。'
    p1.createdAt = '2026-03-15'
    p1.tags = ['HarmonyOS', 'ArkUI', '深色模式']
    items.push(p1)

    const p2 = new PortfolioProject()
    p2.id = 'p2'
    p2.title = '城市黄昏系列'
    p2.category = 'photo'
    p2.coverKey = 'cat_photo'
    p2.imageKeys = ['cat_photo', 'banner_curate']
    p2.description = '记录城市边缘的黄昏光线，探索建筑与天空的交界。35mm 定焦，暖色调后期。'
    p2.createdAt = '2026-05-20'
    p2.tags = ['街拍', '暖色调', '35mm']
    items.push(p2)

    const p3 = new PortfolioProject()
    p3.id = 'p3'
    p3.title = '植物图鉴插画'
    p3.category = 'illustration'
    p3.coverKey = 'cat_illustration'
    p3.imageKeys = ['cat_illustration']
    p3.description = '为自然教育绘本绘制的植物图鉴系列，强调形态与色彩层次，水彩质感。'
    p3.createdAt = '2026-06-08'
    p3.tags = ['水彩', '绘本', ' botanical']
    items.push(p3)

    const p4 = new PortfolioProject()
    p4.id = 'p4'
    p4.title = '鸿蒙组件库文档站'
    p4.category = 'dev'
    p4.coverKey = 'case_dev'
    p4.imageKeys = ['case_dev', 'cat_ui']
    p4.description = '基于 ArkUI 的组件展示与文档站点，支持主题切换与示例代码预览。'
    p4.createdAt = '2026-07-02'
    p4.tags = ['TypeScript', '文档', '开源']
    items.push(p4)

    return items
  }

  private static parseProjects(raw: string): PortfolioProject[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as object[]
      const out: PortfolioProject[] = []
      for (const row of parsed) {
        const p = PortfolioStore.mapProject(row)
        if (p.id.length > 0) {
          out.push(p)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapProject(row: object): PortfolioProject {
    const p = new PortfolioProject()
    const r = row as Record<string, string | string[]>
    p.id = typeof r['id'] === 'string' ? r['id'] : ''
    p.title = typeof r['title'] === 'string' ? r['title'] : ''
    p.category = typeof r['category'] === 'string' ? r['category'] : ''
    p.coverKey = typeof r['coverKey'] === 'string' ? r['coverKey'] : 'hero_studio'
    p.description = typeof r['description'] === 'string' ? r['description'] : ''
    p.createdAt = typeof r['createdAt'] === 'string' ? r['createdAt'] : ''
    if (Array.isArray(r['tags'])) {
      p.tags = r['tags'] as string[]
    }
    if (Array.isArray(r['imageKeys'])) {
      p.imageKeys = r['imageKeys'] as string[]
    } else {
      p.imageKeys = [p.coverKey]
    }
    return p
  }

  private static async persistProjects(list: PortfolioProject[]): Promise<void> {
    const payload: object[] = []
    for (const it of list) {
      const row: Record<string, string | string[]> = {}
      row['id'] = it.id
      row['title'] = it.title
      row['category'] = it.category
      row['coverKey'] = it.coverKey
      row['imageKeys'] = it.imageKeys
      row['description'] = it.description
      row['createdAt'] = it.createdAt
      row['tags'] = it.tags
      payload.push(row)
    }
    await PortfolioStore.putString(KEY_PROJECTS, JSON.stringify(payload), true)
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (PortfolioStore.pref === null) {
      return fallback
    }
    try {
      const v = await PortfolioStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string, flush: boolean): Promise<void> {
    if (PortfolioStore.pref === null) {
      return
    }
    try {
      await PortfolioStore.pref.put(key, value)
      if (flush) {
        await PortfolioStore.pref.flush()
      }
    } catch {
      // ignore
    }
  }
}
