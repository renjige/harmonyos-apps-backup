import { MathQuestion, WrongItem } from '../models/MathModels'

export class MathEngine {
  static opLabel(op: string): string {
    if (op === 'sub') {
      return '−'
    }
    if (op === 'mul') {
      return '×'
    }
    if (op === 'div') {
      return '÷'
    }
    return '+'
  }

  static generate(mode: string, count: number, difficulty: string): MathQuestion[] {
    const out: MathQuestion[] = []
    const n = count > 0 ? count : 10
    for (let i = 0; i < n; i++) {
      const op = mode === 'mix' ? MathEngine.randOp() : mode
      out.push(MathEngine.one(op, difficulty, i))
    }
    return out
  }

  static fromWrong(items: WrongItem[]): MathQuestion[] {
    const out: MathQuestion[] = []
    for (let i = 0; i < items.length; i++) {
      const w = items[i]
      const q = new MathQuestion()
      q.id = `retry_${w.id}_${i}`
      q.left = w.left
      q.right = w.right
      q.op = w.op
      q.opLabel = MathEngine.opLabel(w.op)
      q.expression = w.expression
      q.answer = Number.parseInt(w.correctAnswer)
      MathEngine.fillOptions(q)
      out.push(q)
    }
    return out
  }

  static stars(correct: number, total: number): number {
    if (total <= 0) {
      return 0
    }
    const rate = correct / total
    if (rate >= 0.999) {
      return 3
    }
    if (rate >= 0.8) {
      return 2
    }
    return 1
  }

  private static one(op: string, difficulty: string, idx: number): MathQuestion {
    const q = new MathQuestion()
    q.id = `q_${Date.now()}_${idx}`
    q.op = op
    q.opLabel = MathEngine.opLabel(op)
    const max = MathEngine.maxNum(difficulty)
    if (op === 'sub') {
      const a = MathEngine.rand(1, max)
      const b = MathEngine.rand(0, a)
      q.left = a
      q.right = b
      q.answer = a - b
    } else if (op === 'mul') {
      const hi = difficulty === 'hard' ? 12 : (difficulty === 'medium' ? 9 : 5)
      q.left = MathEngine.rand(1, hi)
      q.right = MathEngine.rand(1, hi)
      q.answer = q.left * q.right
    } else if (op === 'div') {
      const hi = difficulty === 'hard' ? 12 : (difficulty === 'medium' ? 9 : 5)
      q.right = MathEngine.rand(1, hi)
      const quot = MathEngine.rand(1, hi)
      q.left = q.right * quot
      q.answer = quot
    } else {
      q.left = MathEngine.rand(0, max)
      q.right = MathEngine.rand(0, max)
      q.answer = q.left + q.right
    }
    q.expression = `${q.left} ${q.opLabel} ${q.right} = ?`
    MathEngine.fillOptions(q)
    return q
  }

  static fillOptions(q: MathQuestion): void {
    const opts: number[] = []
    opts.push(q.answer)
    let guard = 0
    while (opts.length < 4 && guard < 40) {
      guard += 1
      const delta = MathEngine.rand(1, Math.max(3, Math.floor(q.answer * 0.35) + 2))
      const sign = guard % 2 === 0 ? 1 : -1
      let candidate = q.answer + sign * delta
      if (candidate < 0) {
        candidate = q.answer + delta
      }
      let dup = false
      for (const o of opts) {
        if (o === candidate) {
          dup = true
          break
        }
      }
      if (!dup) {
        opts.push(candidate)
      }
    }
    while (opts.length < 4) {
      opts.push(q.answer + opts.length)
    }
    MathEngine.shuffle(opts)
    q.options = opts
    q.correctIndex = opts.indexOf(q.answer)
  }

  private static shuffle(arr: number[]): void {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = MathEngine.rand(0, i)
      const tmp = arr[i]
      arr[i] = arr[j]
      arr[j] = tmp
    }
  }

  private static maxNum(difficulty: string): number {
    if (difficulty === 'hard') {
      return 50
    }
    if (difficulty === 'medium') {
      return 20
    }
    return 10
  }

  private static randOp(): string {
    const n = MathEngine.rand(0, 3)
    if (n === 1) {
      return 'sub'
    }
    if (n === 2) {
      return 'mul'
    }
    if (n === 3) {
      return 'div'
    }
    return 'add'
  }

  private static rand(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min
  }
}
