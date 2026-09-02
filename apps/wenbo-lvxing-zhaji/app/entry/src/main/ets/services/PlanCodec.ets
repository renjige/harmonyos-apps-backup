/** 出行计划清单编解码（body 纯文本，避免 JSON 字面量限制） */

export class PlanTaskItem {
  id: string = ''
  title: string = ''
  done: boolean = false
}

export class PlanCodec {
  static encodeTasks(tasks: PlanTaskItem[]): string {
    let lines = ''
    for (const t of tasks) {
      const mark = t.done ? '[x]' : '[ ]'
      lines += `${mark} ${t.title}\n`
    }
    return lines.trim()
  }

  static decodeTasks(body: string): PlanTaskItem[] {
    const out: PlanTaskItem[] = []
    const lines = body.split('\n')
    let idx = 0
    for (const line of lines) {
      const trimmed = line.trim()
      if (trimmed.length === 0) {
        continue
      }
      const task = new PlanTaskItem()
      task.id = String(idx)
      idx += 1
      if (trimmed.startsWith('[x]')) {
        task.done = true
        task.title = trimmed.substring(3).trim()
      } else if (trimmed.startsWith('[ ]')) {
        task.done = false
        task.title = trimmed.substring(3).trim()
      } else {
        task.title = trimmed
      }
      if (task.title.length > 0) {
        out.push(task)
      }
    }
    return out
  }

  static defaultTasks(): PlanTaskItem[] {
    const titles: string[] = ['订交通', '订住宿', '整理行李']
    const out: PlanTaskItem[] = []
    for (let i = 0; i < titles.length; i++) {
      const t = new PlanTaskItem()
      t.id = String(i)
      t.title = titles[i]
      t.done = false
      out.push(t)
    }
    return out
  }

  static isPlanBody(body: string): boolean {
    return body.indexOf('[ ]') >= 0 || body.indexOf('[x]') >= 0
  }

  static progressPercent(tasks: PlanTaskItem[]): number {
    if (tasks.length === 0) {
      return 0
    }
    let done = 0
    for (const t of tasks) {
      if (t.done) {
        done += 1
      }
    }
    return Math.round((done * 100) / tasks.length)
  }

  static doneCount(tasks: PlanTaskItem[]): number {
    let done = 0
    for (const t of tasks) {
      if (t.done) {
        done += 1
      }
    }
    return done
  }
}
