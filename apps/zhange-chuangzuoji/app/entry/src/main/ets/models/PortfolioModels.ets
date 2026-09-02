export class PortfolioProject {
  id: string = ''
  title: string = ''
  category: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  description: string = ''
  createdAt: string = ''
  tags: string[] = []
}

export class CreatorProfile {
  name: string = ''
  avatarKey: string = 'hero_studio'
  title: string = ''
  bio: string = ''
  skills: string[] = []
  email: string = ''
}

export class PortfolioCategory {
  id: string = ''
  label: string = ''

  static all(): PortfolioCategory[] {
    const items: PortfolioCategory[] = []
    const defs: string[][] = [
      ['all', '全部'],
      ['ui', 'UI设计'],
      ['illustration', '插画'],
      ['photo', '摄影'],
      ['dev', '开发项目']
    ]
    for (const row of defs) {
      const c = new PortfolioCategory()
      c.id = row[0]
      c.label = row[1]
      items.push(c)
    }
    return items
  }
}

export class PortfolioExportBundle {
  version: string = '1'
  profile: CreatorProfile = new CreatorProfile()
  projects: PortfolioProject[] = []
}

export class PortfolioStats {
  totalProjects: number = 0
  categoryCount: number = 0
  lastUpdated: string = '—'
  visitCount: number = 0
  detailViewCount: number = 0
}
