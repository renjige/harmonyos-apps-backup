import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { PortfolioExportBundle, PortfolioProject, CreatorProfile } from '../models/PortfolioModels'
import { PortfolioStore } from './PortfolioStore'
import { ProfileStore } from './ProfileStore'

export class ExportImportService {
  static async buildJson(): Promise<string> {
    const bundle = new PortfolioExportBundle()
    bundle.version = '1'
    bundle.profile = await ProfileStore.load()
    bundle.projects = await PortfolioStore.loadAll()
    const row: Record<string, string | object | object[]> = {}
    row['version'] = bundle.version
    row['profile'] = ExportImportService.profileToObject(bundle.profile)
    const projRows: object[] = []
    for (const p of bundle.projects) {
      projRows.push(ExportImportService.projectToObject(p))
    }
    row['projects'] = projRows
    return JSON.stringify(row, null, 2)
  }

  static async importFromJson(text: string): Promise<string> {
    try {
      const parsed = JSON.parse(text) as Record<string, object | object[] | string>
      if (Array.isArray(parsed['projects'])) {
        const projects: PortfolioProject[] = []
        for (const row of parsed['projects'] as object[]) {
          projects.push(ExportImportService.objectToProject(row))
        }
        if (projects.length > 0) {
          await PortfolioStore.replaceAll(projects)
        }
      }
      if (parsed['profile'] !== undefined && typeof parsed['profile'] === 'object') {
        await ProfileStore.save(ExportImportService.objectToProfile(parsed['profile'] as object))
      }
      return '导入成功'
    } catch {
      return 'JSON 格式无效，请检查后重试'
    }
  }

  static async exportToFile(context: common.UIAbilityContext): Promise<string> {
    const json = await ExportImportService.buildJson()
    const dir = `${context.filesDir}/export`
    fileIo.mkdirSync(dir, true)
    const path = `${dir}/portfolio-${Date.now()}.json`
    const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
    fileIo.writeSync(file.fd, json)
    fileIo.closeSync(file)
    return path
  }

  private static profileToObject(p: CreatorProfile): object {
    const row: Record<string, string | string[]> = {}
    row['name'] = p.name
    row['avatarKey'] = p.avatarKey
    row['title'] = p.title
    row['bio'] = p.bio
    row['skills'] = p.skills
    row['email'] = p.email
    return row
  }

  private static projectToObject(p: PortfolioProject): object {
    const row: Record<string, string | string[]> = {}
    row['id'] = p.id
    row['title'] = p.title
    row['category'] = p.category
    row['coverKey'] = p.coverKey
    row['imageKeys'] = p.imageKeys
    row['description'] = p.description
    row['createdAt'] = p.createdAt
    row['tags'] = p.tags
    return row
  }

  private static objectToProject(row: object): PortfolioProject {
    const p = new PortfolioProject()
    const r = row as Record<string, string | string[]>
    p.id = typeof r['id'] === 'string' ? r['id'] : `imp_${Date.now()}`
    p.title = typeof r['title'] === 'string' ? r['title'] : '未命名作品'
    p.category = typeof r['category'] === 'string' ? r['category'] : 'ui'
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

  private static objectToProfile(row: object): CreatorProfile {
    const p = new CreatorProfile()
    const r = row as Record<string, string | string[]>
    p.name = typeof r['name'] === 'string' ? r['name'] : ''
    p.avatarKey = typeof r['avatarKey'] === 'string' ? r['avatarKey'] : 'hero_studio'
    p.title = typeof r['title'] === 'string' ? r['title'] : ''
    p.bio = typeof r['bio'] === 'string' ? r['bio'] : ''
    p.email = typeof r['email'] === 'string' ? r['email'] : ''
    if (Array.isArray(r['skills'])) {
      p.skills = r['skills'] as string[]
    }
    return p
  }
}
