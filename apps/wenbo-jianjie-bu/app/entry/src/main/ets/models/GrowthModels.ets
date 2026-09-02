export class ActivityItem {
  id: string = ''
  kind: string = ''
  refId: string = ''
  title: string = ''
  dateKey: string = ''
  createdAt: number = 0
}

export class ThinkingPlanWeek {
  weekKey: string = ''
  goal1: string = '今日落笔写一条见解'
  goal2: string = '验收一条待验证判断'
  goal3: string = '完成本周三问'
  done1: boolean = false
  done2: boolean = false
  done3: boolean = false
  updatedAt: number = 0

  doneCount(): number {
    let c = 0
    if (this.done1) { c++ }
    if (this.done2) { c++ }
    if (this.done3) { c++ }
    return c
  }
}

export class CheckInRecord {
  dateKey: string = ''
  note: string = ''
  entryCount: number = 0
}

export class AchievementDef {
  id: string = ''
  name: string = ''
  hint: string = ''

  static all(): AchievementDef[] {
    const list: AchievementDef[] = []
    list.push(AchievementDef.make('first_entry', '初启思考', '写下第一条见解'))
    list.push(AchievementDef.make('streak_3', '连续三天', '连续 3 天有记录'))
    list.push(AchievementDef.make('streak_7', '一周坚持', '连续 7 天有记录'))
    list.push(AchievementDef.make('star_5', '星标收藏家', '星标满 5 条'))
    list.push(AchievementDef.make('judge_3', '判断学徒', '判断台账满 3 条'))
    list.push(AchievementDef.make('verdict_1', '首次验收', '完成一次判断验收'))
    list.push(AchievementDef.make('week_review', '周度复盘', '完成一次本周三问'))
    list.push(AchievementDef.make('entries_10', '十卷成章', '累计 10 条见解'))
    return list
  }

  static make(id: string, name: string, hint: string): AchievementDef {
    const d = new AchievementDef()
    d.id = id
    d.name = name
    d.hint = hint
    return d
  }
}

export class WorkbenchStats {
  total: number = 0
  pendingJudge: number = 0
  starCount: number = 0
  weekWrite: number = 0
  streak: number = 0
  planDone: number = 0
  planTotal: number = 3
  todayWritten: boolean = false
  checkedIn: boolean = false
  hitRate: number = 0
  achievementCount: number = 0
}

export class AdvancedFilter {
  keyword: string = ''
  frameKind: string = ''
  notebookId: string = ''
  monthKey: string = ''
  verdict: string = ''
  starredOnly: boolean = false
}
