import { AchievementItem } from '../models/ZhiweiModels'

export class AchievementCatalog {
  static all(): AchievementItem[] {
    const list: AchievementItem[] = []
    list.push(AchievementCatalog.make('ach_first', '初次记录', '写下第一条微知识'))
    list.push(AchievementCatalog.make('ach_cap10', '积累十知', '累计记录 10 条微知识'))
    list.push(AchievementCatalog.make('ach_cap50', '半百微知', '累计记录 50 条微知识'))
    list.push(AchievementCatalog.make('ach_streak7', '连续七天', '连续 7 天有记录'))
    list.push(AchievementCatalog.make('ach_learn7', '学习一周', '累计学习打卡 7 天'))
    list.push(AchievementCatalog.make('ach_master10', '掌握十条', '标记 10 条为已掌握'))
    list.push(AchievementCatalog.make('ach_fav5', '收藏达人', '收藏 5 条微知识'))
    list.push(AchievementCatalog.make('ach_folder3', '专题整理', '创建 3 个知识库专题'))
    list.push(AchievementCatalog.make('ach_digest5', '消化五条', '累计消化 5 条微知识'))
    list.push(AchievementCatalog.make('ach_plan_done', '计划达成', '完成一次学习计划'))
    return list
  }

  private static make(id: string, title: string, desc: string): AchievementItem {
    const row = new AchievementItem()
    row.id = id
    row.title = title
    row.desc = desc
    return row
  }
}
