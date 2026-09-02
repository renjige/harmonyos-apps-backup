export class CyclePlan {
  id: string = ''
  title: string = ''
  goalText: string = ''
  periodDays: number = 30
  startKey: string = ''
  note: string = ''
}

export class LibraryAction {
  id: string = ''
  category: string = 'warm'
  name: string = ''
  desc: string = ''
  purpose: string = ''
  caution: string = ''
  coverKey: string = 'atlas_warm'
  favorited: boolean = false
}

export class PrepLine {
  listId: string = ''
  index: number = 0
  text: string = ''
  done: boolean = false
}

export class PrepList {
  id: string = ''
  title: string = ''
  itemsText: string = ''
  doneMask: string = ''
  lines: PrepLine[] = []

  rebuildLines(): void {
    this.lines = this.lineItems()
  }

  lineItems(): PrepLine[] {
    const parts = this.itemsText.split('|')
    const out: PrepLine[] = []
    for (let i = 0; i < parts.length; i++) {
      const ln = new PrepLine()
      ln.listId = this.id
      ln.index = i
      ln.text = parts[i]
      ln.done = i < this.doneMask.length && this.doneMask.substring(i, i + 1) === '1'
      out.push(ln)
    }
    return out
  }
}

export class InsightFav {
  id: string = ''
  title: string = ''
  body: string = ''
}

export class GoalChallenge {
  id: string = ''
  title: string = ''
  kind: string = 'count'
  target: number = 21
  done: boolean = false
}

export class ActionCategory {
  key: string = ''
  label: string = ''

  static all(): ActionCategory[] {
    const out: ActionCategory[] = []
    const rows: string[][] = [
      ['warm', '热身动作'],
      ['stretch', '拉伸动作'],
      ['strength', '力量动作'],
      ['balance', '平衡训练'],
      ['relax', '放松训练']
    ]
    for (const row of rows) {
      const o = new ActionCategory()
      o.key = row[0]
      o.label = row[1]
      out.push(o)
    }
    return out
  }

  static labelFor(key: string): string {
    for (const o of ActionCategory.all()) {
      if (o.key === key) {
        return o.label
      }
    }
    return '训练'
  }
}

export class ArchiveDraft {
  mode: string = ''
  title: string = ''
  extra: string = ''
  extraNum: string = '30'
  category: string = 'warm'
  kind: string = 'count'
}

export class BodyNote {
  dateKey: string = ''
  energy: string = ''
  drive: string = ''
  text: string = ''
}

export class MoodOption {
  key: string = ''
  label: string = ''

  static energy(): MoodOption[] {
    return MoodOption.fromRows([
      ['full', '充沛'],
      ['steady', '平稳'],
      ['low', '疲惫']
    ])
  }

  static drive(): MoodOption[] {
    return MoodOption.fromRows([
      ['high', '较高'],
      ['mid', '一般'],
      ['low', '偏低']
    ])
  }

  static fromRows(rows: string[][]): MoodOption[] {
    const out: MoodOption[] = []
    for (const row of rows) {
      const o = new MoodOption()
      o.key = row[0]
      o.label = row[1]
      out.push(o)
    }
    return out
  }
}

export class Milestone {
  id: string = ''
  whenKey: string = ''
  title: string = ''
  detail: string = ''
}

export class ThemeSpaceOption {
  key: string = ''
  label: string = ''
  tag: string = ''
  hint: string = ''

  static all(): ThemeSpaceOption[] {
    const out: ThemeSpaceOption[] = []
    const rows: string[][] = [
      ['morning', '活力晨练', 'morning', '适合起床后 20 分钟轻量启动'],
      ['weekend', '周末运动', 'weekend', '把长一点的训练放在周末'],
      ['power', '力量提升', 'power', '以徒手力量为主题的一周'],
      ['flex', '柔韧改善', 'flex', '拉伸与活动度优先'],
      ['ease', '放松恢复', 'ease', '低强度、呼吸与放松']
    ]
    for (const row of rows) {
      const o = new ThemeSpaceOption()
      o.key = row[0]
      o.label = row[1]
      o.tag = row[2]
      o.hint = row[3]
      out.push(o)
    }
    return out
  }
}

export class ChallengeCatalog {
  id: string = ''
  title: string = ''
  kind: string = 'streak'
  target: number = 7
  badge: string = ''
  hint: string = ''

  static all(): ChallengeCatalog[] {
    const out: ChallengeCatalog[] = []
    const rows: string[][] = [
      ['tpl-ch-7', '7天坚持挑战', 'streak', '7', '坚持达人', '连续 7 天打卡或记录训练'],
      ['tpl-ch-21', '21天习惯挑战', 'streak', '21', '自律训练者', '连续 21 天把训练变成习惯'],
      ['tpl-ch-month', '月度训练挑战', 'count', '12', '活力先锋', '本自然月完成 12 次训练记录']
    ]
    for (const row of rows) {
      const c = new ChallengeCatalog()
      c.id = row[0]
      c.title = row[1]
      c.kind = row[2]
      c.target = parseInt(row[3], 10)
      c.badge = row[4]
      c.hint = row[5]
      out.push(c)
    }
    return out
  }
}

export class PlanCatalog {
  static vitalityTitle(): string {
    return '7天活力计划'
  }

  static vitalityDays(): string[] {
    return ['基础训练', '柔韧训练', '恢复训练', '力量训练', '有氧训练', '平衡训练', '轻松散步或休息']
  }
}

export class TrainingProgram {
  id: string = ''
  title: string = ''
  level: string = ''
  weeks: number = 1
  summary: string = ''
  focus: string = ''
  days: string[] = []

  static fromRow(row: string[]): TrainingProgram {
    const p = new TrainingProgram()
    p.id = row[0]
    p.title = row[1]
    p.level = row[2]
    p.weeks = parseInt(row[3], 10)
    p.summary = row[4]
    p.focus = row[5]
    p.days = row[6].split('|')
    return p
  }
}

export class ProgramCatalog {
  static all(): TrainingProgram[] {
    const out: TrainingProgram[] = []
    const rows: string[][] = [
      ['prog-starter', '入门 4 周体能', '新手', '4',
        '从低强度起步，逐步建立每周 3–4 次训练节奏，适合久未运动或刚恢复训练的用户。',
        '基础有氧 + 核心激活 + 拉伸恢复',
        '快走 20 分|核心 15 分|拉伸恢复|慢跑 25 分|力量入门|户外徒步|完全休息'],
      ['prog-run', '跑步进阶 3 周', '进阶', '3',
        '围绕跑量与恢复平衡设计，帮助已有跑步习惯的用户提升耐力与节奏感。',
        '间歇跑 + 长距离 + 交叉训练',
        '轻松跑 30 分|节奏跑 25 分|交叉骑行|长距离 45 分|力量下肢|轻松跑 20 分|主动恢复'],
      ['prog-home', '居家力量 2 周', '居家', '2',
        '无需器械的徒手力量循环，适合在家或出差时维持肌肉激活与体态稳定。',
        '徒手力量 + 平衡 + 放松',
        '上肢循环|核心稳定|下肢力量|全身 HIIT|平衡训练|拉伸放松|休息']
    ]
    for (const row of rows) {
      out.push(TrainingProgram.fromRow(row))
    }
    return out
  }

  static find(id: string): TrainingProgram | undefined {
    for (const p of ProgramCatalog.all()) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }
}

export class QuickTemplate {
  id: string = ''
  title: string = ''
  typeKey: string = 'other'
  durationMinutes: number = 30
  sessionTitle: string = ''
  lastUsedAt: number = 0

  displayLine(): string {
    const name = this.sessionTitle.length > 0 ? this.sessionTitle : this.title
    return `${name} · ${this.durationMinutes} 分钟`
  }
}
