export class AchievementBadgeItem {
  badgeId: string = ''
  title: string = ''
  summary: string = ''
}

export class AchievementCatalog {
  static all(): AchievementBadgeItem[] {
    const list: AchievementBadgeItem[] = []
    list.push(AchievementCatalog.of('badge_sprout', '初芽新手', '写下第一条成长记录'))
    list.push(AchievementCatalog.of('badge_week', '七日恒心', '连续记录 7 天'))
    list.push(AchievementCatalog.of('badge_half_month', '半月见证', '连续记录 15 天'))
    list.push(AchievementCatalog.of('badge_month', '整月成长', '连续记录 30 天'))
    list.push(AchievementCatalog.of('badge_goal', '目标达成', '完成第一个成长目标'))
    list.push(AchievementCatalog.of('badge_double_goal', '双目标星', '累计完成两个目标'))
    list.push(AchievementCatalog.of('badge_records_50', '记录达人', '累计 50 条成长记录'))
    list.push(AchievementCatalog.of('badge_annual', '年度旅人', '查看年度成长报告'))
    return list
  }

  static of(badgeId: string, title: string, summary: string): AchievementBadgeItem {
    const item = new AchievementBadgeItem()
    item.badgeId = badgeId
    item.title = title
    item.summary = summary
    return item
  }

  static titleOf(badgeId: string): string {
    for (const b of AchievementCatalog.all()) {
      if (b.badgeId === badgeId) {
        return b.title
      }
    }
    return '成长徽章'
  }
}
