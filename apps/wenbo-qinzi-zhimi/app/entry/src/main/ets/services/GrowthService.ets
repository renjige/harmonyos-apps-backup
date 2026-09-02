import { FavoriteCollection, PlanGoal, TimelineEvent, AchievementItem, TopicPack, WeeklyReview, CategoryStatItem } from '../models/GrowthModels'
import { ProgressStore } from './ProgressStore'
import { QuizBizService } from './QuizBizService'
import { PuzzleItem } from '../models/PuzzleModels'

export class GrowthService {
  static weekCorrectCount(): number {
    const wk = ProgressStore.currentWeekKey()
    let n = 0
    for (const r of ProgressStore.snapshot().records) {
      if (r.correct && ProgressStore.dateInWeek(r.at, wk)) {
        n++
      }
    }
    return n
  }

  static weekFamilyCount(): number {
    const wk = ProgressStore.currentWeekKey()
    let n = 0
    for (const e of ProgressStore.timelineEvents()) {
      if (e.type === 'family_play' && ProgressStore.dateInWeek(e.at, wk)) {
        n++
      }
    }
    return n
  }

  static planGoal(): PlanGoal {
    const pg = ProgressStore.planSnapshot()
    const g = new PlanGoal()
    g.weekKey = pg.weekKey
    g.targetCorrect = pg.targetCorrect
    g.targetFamily = pg.targetFamily
    g.note = pg.note
    return g
  }

  static topicPack(puzzles: PuzzleItem[]): TopicPack {
    const cats: string[] = ['animal', 'riddle', 'math', 'visual', 'logic', 'life']
    const labels: string[] = ['动物世界', '脑筋急转弯', '趣味数学', '图形观察', '逻辑推理', '生活常识']
    const d = new Date()
    const idx = Math.abs(d.getDate() + d.getMonth() * 7) % cats.length
    const pack = new TopicPack()
    pack.categoryId = cats[idx]
    pack.title = `本周主题：${labels[idx]}`
    pack.weekKey = ProgressStore.currentWeekKey()
    let total = 0
    let done = 0
    const doneIds = ProgressStore.snapshot().completedIds
    for (const p of puzzles) {
      if (p.category === pack.categoryId) {
        total++
        if (doneIds.indexOf(p.id) >= 0) {
          done++
        }
      }
    }
    pack.total = total
    pack.done = done
    return pack
  }

  static timeline(limit: number): TimelineEvent[] {
    const all = ProgressStore.timelineEvents()
    const out: TimelineEvent[] = []
    let n = 0
    for (const e of all) {
      if (n >= limit) {
        break
      }
      out.push(e)
      n++
    }
    return out
  }

  static monthlyCheckIns(): number[] {
    const out: number[] = []
    const today = new Date()
    const year = today.getFullYear()
    const month = today.getMonth()
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    for (let day = 1; day <= daysInMonth; day++) {
      const d = new Date(year, month, day)
      const key = ProgressStore.keyOfDatePublic(d)
      let count = 0
      for (const r of ProgressStore.snapshot().records) {
        if (r.at === key && r.correct) {
          count++
        }
      }
      out.push(count)
    }
    return out
  }

  static categoryStats(puzzles: PuzzleItem[]): CategoryStatItem[] {
    const ids: string[] = ['riddle', 'math', 'visual', 'life', 'logic', 'animal']
    const labels: string[] = ['脑筋急转弯', '趣味数学', '图形观察', '生活常识', '逻辑推理', '动物世界']
    const doneIds = ProgressStore.snapshot().completedIds
    const out: CategoryStatItem[] = []
    for (let i = 0; i < ids.length; i++) {
      const item = new CategoryStatItem()
      item.id = ids[i]
      item.label = labels[i]
      item.total = 0
      item.done = 0
      for (const p of puzzles) {
        if (p.category === ids[i]) {
          item.total++
          if (doneIds.indexOf(p.id) >= 0) {
            item.done++
          }
        }
      }
      out.push(item)
    }
    return out
  }

  static weeklyReview(): WeeklyReview {
    const rev = new WeeklyReview()
    rev.weekKey = ProgressStore.currentWeekKey()
    rev.correctCount = GrowthService.weekCorrectCount()
    rev.familyCount = GrowthService.weekFamilyCount()
    rev.newFavorites = GrowthService.weekFavoriteCount()
    rev.streakDays = ProgressStore.displayStreak()
    return rev
  }

  static achievements(): AchievementItem[] {
    const s = ProgressStore.snapshot()
    const out: AchievementItem[] = []
    out.push(GrowthService.makeAch('ach_first', '初次答对', '完成第一道题', s.completedIds.length, 1))
    out.push(GrowthService.makeAch('ach_streak7', '连续 7 天', '坚持一周动脑', s.streak, 7))
    out.push(GrowthService.makeAch('ach_streak30', '连续 30 天', '养成好习惯', s.streak, 30))
    out.push(GrowthService.makeAch('ach_done10', '答对 10 题', '小小学霸', s.completedIds.length, 10))
    out.push(GrowthService.makeAch('ach_done50', '答对 50 题', '谜题达人', s.completedIds.length, 50))
    out.push(GrowthService.makeAch('ach_fav5', '收藏 5 题', '建立题单', s.favorites.length, 5))
    out.push(GrowthService.makeAch('ach_family3', '亲子 3 轮', '家庭默契', s.familyRounds, 3))
    out.push(GrowthService.makeAch('ach_custom1', '家庭出题', '创建第一题', s.customJson.length > 4 ? 1 : 0, 1))
    return out
  }

  static collections(): FavoriteCollection[] {
    return ProgressStore.collections()
  }

  private static weekFavoriteCount(): number {
    const wk = ProgressStore.currentWeekKey()
    let n = 0
    for (const e of ProgressStore.timelineEvents()) {
      if (e.type === 'favorite' && ProgressStore.dateInWeek(e.at, wk)) {
        n++
      }
    }
    return n
  }

  private static makeAch(id: string, title: string, rule: string, current: number, target: number): AchievementItem {
    const a = new AchievementItem()
    a.id = id
    a.title = title
    a.rule = rule
    a.current = current > target ? target : current
    a.target = target
    a.unlocked = current >= target
    return a
  }
}
