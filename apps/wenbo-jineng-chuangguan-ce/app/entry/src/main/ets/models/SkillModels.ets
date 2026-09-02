export class SkillCategory {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'cat_workplace'
  category: string = ''
  categoryLabel: string = ''
}

export class CategoryListData {
  list: SkillCategory[] = []
}

export class SkillLevel {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  taskBody: string = ''
  coverKey: string = 'hero_bg'
  category: string = ''
  categoryId: string = ''
  categoryLabel: string = ''
  difficulty: number = 1
  durationMin: number = 15
  growthValue: number = 20
  xp: number = 20
  prerequisiteId: string = ''
}

export class LevelListData {
  list: SkillLevel[] = []
}

export class SkillBadge {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  rule: string = ''
  tier: string = 'bronze'
  coverKey: string = 'badge_bronze'
}

export class BadgeListData {
  list: SkillBadge[] = []
}

export class LeaderboardEntry {
  id: string = ''
  title: string = ''
  displayName: string = ''
  score: number = 0
  rank: number = 0
  category: string = 'all'
  categoryLabel: string = ''
  summary: string = ''
}

export class LeaderboardListData {
  list: LeaderboardEntry[] = []
}

export class KpiItem {
  id: string = ''
  key: string = ''
  label: string = ''
  value: string = ''
  unit: string = ''
  trend: string = ''
}

export class KpiListData {
  list: KpiItem[] = []
}

export class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
}

export class MsgListData {
  list: MsgItem[] = []
}

export class StarIndex {
  n: number = 1

  static five(): StarIndex[] {
    const list: StarIndex[] = []
    for (let i = 1; i <= 5; i++) {
      const o = new StarIndex()
      o.n = i
      list.push(o)
    }
    return list
  }
}

export class RadarDimension {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class BadgeRule {
  id: string = ''
  rule: string = ''
}
