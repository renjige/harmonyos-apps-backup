import { CustomExpr, MathQuestion, WrongItem } from '../models/MathModels'
import { MathQuestionFactory } from './MathQuestionFactory'

export class MathEngine {
  static opLabel(op: string): string {
    if (op === 'sub' || op === 'sub2') {
      return '−'
    }
    if (op === 'mul' || op === 'table_mul') {
      return '×'
    }
    if (op === 'div' || op === 'table_div') {
      return '÷'
    }
    return '+'
  }

  static generate(mode: string, count: number, difficulty: string): MathQuestion[] {
    const out: MathQuestion[] = []
    const used: string[] = []
    const n = count > 0 ? count : 10
    let guard = 0
    while (out.length < n && guard < n * 40) {
      guard += 1
      const op = MathEngine.pickOp(mode, out.length)
      const q = MathEngine.one(op, difficulty, out.length)
      if (!MathEngine.hasExpr(used, q.expression)) {
        used.push(q.expression)
        out.push(q)
      }
    }
    while (out.length < n) {
      const filler = MathEngine.one('add', difficulty, out.length)
      out.push(filler)
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
      q.qType = w.qType.length > 0 ? w.qType : 'fill'
      q.story = w.story
      q.answerLabel = w.answerLabel.length > 0 ? w.answerLabel : w.correctAnswer
      q.choiceA = w.choiceA
      q.choiceB = w.choiceB
      q.choiceC = w.choiceC
      if (q.choiceA.length > 0) {
        if (q.choiceA === w.answerLabel || q.choiceA === w.correctAnswer) {
          q.answer = 0
        } else if (q.choiceB === w.answerLabel || q.choiceB === w.correctAnswer) {
          q.answer = 1
        } else if (q.choiceC === w.answerLabel || q.choiceC === w.correctAnswer) {
          q.answer = 2
        }
      }
      if (q.qType === 'compare' && q.choiceA.length === 0) {
        q.choiceA = '小于'
        q.choiceB = '等于'
        q.choiceC = '大于'
      }
      if (q.qType === 'judge') {
        q.choiceA = '是这样'
        q.choiceB = '再想想'
      }
      out.push(q)
    }
    return out
  }

  static gradeMode(grade: string): string {
    if (grade === 'age35') {
      return 'age35'
    }
    if (grade === 'age912' || grade === 'g3') {
      return 'age912'
    }
    if (grade === 'g2') {
      return 'g2'
    }
    return 'age68'
  }

  static tableDrill(left: number, count: number): MathQuestion[] {
    const n = count > 0 ? count : 8
    const out: MathQuestion[] = []
    let r = 1
    while (out.length < n) {
      const q = new MathQuestion()
      q.id = `td_${left}_${r}_${out.length}`
      q.opLabel = out.length % 3 === 2 ? '÷' : '×'
      if (out.length % 3 === 2) {
        q.op = 'table_div'
        q.qType = 'fill'
        q.left = left * r
        q.right = left
        q.answer = r
        q.expression = `${q.left} ÷ ${q.right} = ?`
        q.hint = `${left} 的口诀反过来`
      } else {
        q.op = 'table_mul'
        q.qType = 'fill'
        q.left = left
        q.right = r
        q.answer = left * r
        q.expression = `${left} × ${r} = ?`
        q.hint = `${left} 的口诀`
      }
      q.answerLabel = `${q.answer}`
      out.push(q)
      r += 1
      if (r > 9) {
        r = 1
      }
    }
    return out
  }

  static fromCustom(items: CustomExpr[]): MathQuestion[] {
    const out: MathQuestion[] = []
    let i = 0
    for (const it of items) {
      const q = new MathQuestion()
      q.id = `cu_${it.id}_${i}`
      q.left = it.left
      q.right = it.right
      q.op = it.op
      q.opLabel = MathEngine.opLabel(it.op)
      q.expression = it.expression
      q.answer = it.answer
      q.qType = 'fill'
      q.answerLabel = `${it.answer}`
      out.push(q)
      i += 1
    }
    return out
  }

  static generateOps(ops: string[], count: number, difficulty: string): MathQuestion[] {
    if (ops.length === 0) {
      return MathEngine.generate('add', count, difficulty)
    }
    const out: MathQuestion[] = []
    const used: string[] = []
    const n = count > 0 ? count : 10
    let guard = 0
    while (out.length < n && guard < n * 40) {
      guard += 1
      const op = MathEngine.pickFrom(ops, out.length)
      const q = MathEngine.one(op, difficulty, out.length)
      if (!MathEngine.hasExpr(used, q.expression)) {
        used.push(q.expression)
        out.push(q)
      }
    }
    while (out.length < n) {
      let first = 'add'
      for (const op of ops) {
        first = op
        break
      }
      const filler = MathEngine.one(first, difficulty, out.length)
      out.push(filler)
    }
    return out
  }

  static displayAnswer(q: MathQuestion): string {
    if (q.answerLabel.length > 0) {
      return q.answerLabel
    }
    return `${q.answer}`
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

  private static pickOp(mode: string, index: number): string {
    if (mode === 'mix') {
      return MathEngine.randBasicOp(index)
    }
    if (mode === 'mix_adv') {
      return MathEngine.randAdvOp(index)
    }
    if (mode === 'g1' || mode === 'age68') {
      return MathEngine.pickFrom(['add', 'sub', 'make10', 'compose', 'compare', 'odd_even', 'story'], index)
    }
    if (mode === 'age35') {
      return MathEngine.pickFrom(['compose', 'odd_even', 'compare', 'sort', 'shape', 'link', 'add'], index)
    }
    if (mode === 'g3' || mode === 'age912') {
      return MathEngine.pickFrom(['mul', 'div', 'add2', 'sub2', 'table_mul', 'place', 'choice', 'story'], index)
    }
    if (mode === 'game') {
      return MathEngine.pickFrom(['sort', 'shape', 'link', 'sequence', 'odd_even'], index)
    }
    if (mode === 'addsub') {
      return MathEngine.pickFrom(['add', 'sub', 'make10', 'chain'], index)
    }
    if (mode === 'muldiv') {
      return MathEngine.pickFrom(['mul', 'div', 'table_mul', 'table_div'], index)
    }
    if (mode === 'g2') {
      return MathEngine.pickFrom(['add', 'sub', 'add2', 'blank', 'chain', 'sequence', 'compare', 'story'], index)
    }
    if (mode === 'sense') {
      return MathEngine.pickFrom(['compare', 'compose', 'sequence', 'odd_even', 'place'], index)
    }
    if (mode === 'think') {
      return MathEngine.pickFrom(['choice', 'judge', 'compare', 'blank'], index)
    }
    return mode
  }

  private static one(op: string, difficulty: string, idx: number): MathQuestion {
    if (op === 'make10') {
      return MathEngine.makeTen(idx)
    }
    if (op === 'blank') {
      return MathEngine.blankAdd(difficulty, idx)
    }
    if (op === 'chain') {
      return MathEngine.chainAdd(difficulty, idx)
    }
    if (op === 'add2') {
      return MathEngine.twoDigitAdd(difficulty, idx)
    }
    if (op === 'sub2') {
      return MathEngine.twoDigitSub(difficulty, idx)
    }
    if (op === 'table_mul') {
      return MathEngine.tableMul(difficulty, idx)
    }
    if (op === 'table_div') {
      return MathEngine.tableDiv(difficulty, idx)
    }
    if (op === 'compare' || op === 'compose' || op === 'sequence' || op === 'odd_even' ||
      op === 'place' || op === 'story' || op === 'choice' || op === 'judge' ||
      op === 'sort' || op === 'shape' || op === 'link') {
      return MathQuestionFactory.make(op, difficulty, idx)
    }
    return MathEngine.basic(op, difficulty, idx)
  }

  private static basic(op: string, difficulty: string, idx: number): MathQuestion {
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
    return q
  }

  private static makeTen(idx: number): MathQuestion {
    const q = new MathQuestion()
    q.id = `q10_${Date.now()}_${idx}`
    q.op = 'make10'
    q.opLabel = '+'
    q.left = MathEngine.rand(1, 9)
    q.right = 10 - q.left
    q.answer = 10
    q.expression = `${q.left} + ${q.right} = ?`
    return q
  }

  private static blankAdd(difficulty: string, idx: number): MathQuestion {
    const q = new MathQuestion()
    q.id = `qb_${Date.now()}_${idx}`
    q.op = 'blank'
    q.opLabel = '+'
    const max = MathEngine.maxNum(difficulty)
    q.answer = MathEngine.rand(1, max)
    q.right = MathEngine.rand(1, max)
    q.left = q.answer + q.right
    q.expression = `? + ${q.right} = ${q.left}`
    return q
  }

  private static chainAdd(difficulty: string, idx: number): MathQuestion {
    const q = new MathQuestion()
    q.id = `qc_${Date.now()}_${idx}`
    q.op = 'chain'
    q.opLabel = '+'
    const max = difficulty === 'hard' ? 15 : (difficulty === 'medium' ? 10 : 6)
    const a = MathEngine.rand(1, max)
    const b = MathEngine.rand(1, max)
    const c = MathEngine.rand(1, max)
    q.left = a
    q.right = b
    q.answer = a + b + c
    q.expression = `${a} + ${b} + ${c} = ?`
    return q
  }

  private static twoDigitAdd(difficulty: string, idx: number): MathQuestion {
    const q = new MathQuestion()
    q.id = `q2a_${Date.now()}_${idx}`
    q.op = 'add2'
    q.opLabel = '+'
    if (difficulty === 'easy') {
      q.left = MathEngine.rand(10, 39)
      q.right = MathEngine.rand(10, 39)
    } else if (difficulty === 'medium') {
      q.left = MathEngine.rand(10, 69)
      q.right = MathEngine.rand(10, 59)
    } else {
      q.left = MathEngine.rand(20, 99)
      q.right = MathEngine.rand(10, 99)
    }
    q.answer = q.left + q.right
    q.expression = `${q.left} + ${q.right} = ?`
    return q
  }

  private static twoDigitSub(difficulty: string, idx: number): MathQuestion {
    const q = new MathQuestion()
    q.id = `q2s_${Date.now()}_${idx}`
    q.op = 'sub2'
    q.opLabel = '−'
    if (difficulty === 'easy') {
      q.left = MathEngine.rand(20, 59)
      q.right = MathEngine.rand(10, q.left - 1)
    } else if (difficulty === 'medium') {
      q.left = MathEngine.rand(30, 89)
      q.right = MathEngine.rand(10, q.left - 1)
    } else {
      q.left = MathEngine.rand(50, 99)
      q.right = MathEngine.rand(10, q.left - 1)
    }
    q.answer = q.left - q.right
    q.expression = `${q.left} − ${q.right} = ?`
    return q
  }

  private static tableMul(difficulty: string, idx: number): MathQuestion {
    const q = new MathQuestion()
    q.id = `qm_${Date.now()}_${idx}`
    q.op = 'table_mul'
    q.opLabel = '×'
    const hi = difficulty === 'hard' ? 12 : (difficulty === 'medium' ? 9 : 5)
    q.left = MathEngine.rand(1, hi)
    q.right = MathEngine.rand(1, hi)
    q.answer = q.left * q.right
    q.expression = `${q.left} × ${q.right} = ?`
    return q
  }

  private static tableDiv(difficulty: string, idx: number): MathQuestion {
    const q = new MathQuestion()
    q.id = `qd_${Date.now()}_${idx}`
    q.op = 'table_div'
    q.opLabel = '÷'
    const hi = difficulty === 'hard' ? 12 : (difficulty === 'medium' ? 9 : 5)
    q.right = MathEngine.rand(1, hi)
    const quot = MathEngine.rand(1, hi)
    q.left = q.right * quot
    q.answer = quot
    q.expression = `${q.left} ÷ ${q.right} = ?`
    return q
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

  private static pickFrom(ops: string[], seed: number): string {
    if (ops.length === 0) {
      return 'add'
    }
    let i = 0
    let n = seed
    while (n >= ops.length) {
      n = n - ops.length
    }
    for (const op of ops) {
      if (i === n) {
        return op
      }
      i += 1
    }
    for (const first of ops) {
      return first
    }
    return 'add'
  }

  private static randBasicOp(seed: number): string {
    return MathEngine.pickFrom(['add', 'sub', 'mul', 'div'], seed)
  }

  private static randAdvOp(seed: number): string {
    return MathEngine.pickFrom(['add', 'sub', 'mul', 'div', 'add2', 'sub2', 'blank', 'chain', 'make10'], seed)
  }

  private static hasExpr(list: string[], expr: string): boolean {
    for (const e of list) {
      if (e === expr) {
        return true
      }
    }
    return false
  }

  private static rand(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min
  }
}
