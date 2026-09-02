/** 结构化学习路径 — 多节课程 + 进度 */

export class PathStep {
  id: string = ''
  insightId: string = ''
  title: string = ''
  summary: string = ''
  order: number = 0
  done: boolean = false
}

export class LearningPath {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  coverKey: string = ''
  steps: PathStep[] = []

  doneCount(): number {
    let n = 0
    for (const s of this.steps) {
      if (s.done) {
        n += 1
      }
    }
    return n
  }

  totalCount(): number {
    return this.steps.length
  }

  progressPercent(): number {
    const t = this.totalCount()
    if (t <= 0) {
      return 0
    }
    return Math.floor(this.doneCount() * 100 / t)
  }
}

export class PathDef {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  coverKey: string = ''
  topic: string = ''
  category: string = ''
}
