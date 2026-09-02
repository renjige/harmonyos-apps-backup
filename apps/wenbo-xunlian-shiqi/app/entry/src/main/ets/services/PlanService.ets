import { PlanDraft, PlanTask, TrainPlan } from '../models/TrainingModels'

export class PlanService {
  static pack(tasks: PlanTask[]): string {
    const lines: string[] = []
    for (const t of tasks) {
      const flag = t.done ? '1' : '0'
      lines.push(`${t.title}|${flag}`)
    }
    return lines.join('\n')
  }

  static unpack(packed: string): PlanTask[] {
    const out: PlanTask[] = []
    if (packed.length === 0) {
      return out
    }
    const lines = packed.split('\n')
    let seq = 0
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const t = new PlanTask()
      t.seq = seq
      seq += 1
      const sep = line.lastIndexOf('|')
      if (sep <= 0) {
        t.title = line
        t.done = false
      } else {
        t.title = line.substring(0, sep)
        t.done = line.substring(sep + 1) === '1'
      }
      out.push(t)
    }
    return out
  }

  static doneCount(plan: TrainPlan): number {
    let n = 0
    for (const t of PlanService.unpack(plan.tasksPacked)) {
      if (t.done) {
        n += 1
      }
    }
    return n
  }

  static totalCount(plan: TrainPlan): number {
    return PlanService.unpack(plan.tasksPacked).length
  }

  static toggle(plan: TrainPlan, index: number): TrainPlan {
    const tasks = PlanService.unpack(plan.tasksPacked)
    const flipped: PlanTask[] = []
    let i = 0
    for (const t of tasks) {
      const n = new PlanTask()
      n.title = t.title
      n.done = i === index ? !t.done : t.done
      flipped.push(n)
      i += 1
    }
    const next = PlanService.copyPlan(plan)
    next.tasksPacked = PlanService.pack(flipped)
    const total = flipped.length
    const done = PlanService.doneCount(next)
    next.status = (total > 0 && done >= total) ? 'done' : 'active'
    return next
  }

  static copyPlan(src: TrainPlan): TrainPlan {
    const p = new TrainPlan()
    p.id = src.id
    p.title = src.title
    p.summary = src.summary
    p.templateKey = src.templateKey
    p.tasksPacked = src.tasksPacked
    p.status = src.status
    p.createdAt = src.createdAt
    return p
  }

  static newId(): string {
    return `pl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  static fromCustom(draft: PlanDraft): TrainPlan {
    const p = new TrainPlan()
    p.id = PlanService.newId()
    p.title = draft.title.trim()
    p.summary = draft.summary.trim()
    p.templateKey = 'custom'
    p.createdAt = new Date().toISOString()
    p.status = 'active'
    const tasks: PlanTask[] = []
    for (let i = 1; i <= 5; i++) {
      const t = new PlanTask()
      t.title = `自定义任务 ${i}`
      t.done = false
      tasks.push(t)
    }
    p.tasksPacked = PlanService.pack(tasks)
    return p
  }

  static fromTemplate(key: string): TrainPlan {
    const p = new TrainPlan()
    p.id = PlanService.newId()
    p.templateKey = key
    p.createdAt = new Date().toISOString()
    p.status = 'active'
    const titles: string[] = []
    if (key === 'vitality7' || key === 'stretch7') {
      p.title = '活力7日计划'
      p.summary = '七天换节奏：基础、柔韧、恢复轮换，勾选即完成当天。'
      titles.push('Day1 基础训练')
      titles.push('Day2 柔韧提升')
      titles.push('Day3 恢复训练')
      titles.push('Day4 核心小循环')
      titles.push('Day5 拉伸专区组合')
      titles.push('Day6 轻松有氧或散步记录')
      titles.push('Day7 复盘心得并收藏喜欢的动作')
    } else if (key === 'newbie') {
      p.title = '新手入门计划'
      p.summary = '从热身和拉伸开始，不追求强度，先把记录变成习惯。'
      titles.push('了解热身专区并收藏 1 个动作')
      titles.push('完成一次拉伸训练记录')
      titles.push('完成一次核心或力量记录')
      titles.push('写下第一条训练心得')
      titles.push('加入一个 7 天挑战')
    } else if (key === 'discipline' || key === 'base30') {
      p.title = '自律挑战计划'
      p.summary = '按里程碑推进，不必每天打卡传感器，勾选完成即可。'
      titles.push('建立热身习惯')
      titles.push('连续两天都有训练记录')
      titles.push('累计 8 次训练')
      titles.push('完成一套计划任务过半')
      titles.push('领取一次挑战完成')
      titles.push('阶段总结：写下最适合自己的方式')
    } else if (key === 'morning') {
      p.title = '我的晨练组合'
      p.summary = '方案库模板：热身 → 拉伸 → 核心，可改成你自己的顺序。'
      titles.push('① 热身')
      titles.push('② 拉伸')
      titles.push('③ 核心训练')
      titles.push('④ 放松记录')
    } else {
      p.title = '周末运动计划'
      p.summary = '只用周末也能保持节奏：有氧、力量、拉伸、放松。'
      titles.push('周六 有氧或晨间活力')
      titles.push('周六 训练后拉伸')
      titles.push('周日 力量或核心')
      titles.push('周日 放松与心得')
    }
    const tasks: PlanTask[] = []
    for (const title of titles) {
      const t = new PlanTask()
      t.title = title
      t.done = false
      tasks.push(t)
    }
    p.tasksPacked = PlanService.pack(tasks)
    return p
  }
}
