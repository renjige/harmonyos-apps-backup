import { MathQuestion } from '../models/MathModels'

/** 数感、应用题、选择/判断等题型工厂 */
export class MathQuestionFactory {
  static make(op: string, difficulty: string, idx: number): MathQuestion {
    if (op === 'compare') {
      return MathQuestionFactory.compare(difficulty, idx)
    }
    if (op === 'compose') {
      return MathQuestionFactory.compose(idx)
    }
    if (op === 'sequence') {
      return MathQuestionFactory.sequence(difficulty, idx)
    }
    if (op === 'odd_even') {
      return MathQuestionFactory.oddEven(idx)
    }
    if (op === 'sort') {
      return MathQuestionFactory.sortNum(idx)
    }
    if (op === 'shape') {
      return MathQuestionFactory.shape(idx)
    }
    if (op === 'link') {
      return MathQuestionFactory.linkNext(difficulty, idx)
    }
    if (op === 'place') {
      return MathQuestionFactory.place(difficulty, idx)
    }
    if (op === 'story') {
      return MathQuestionFactory.story(difficulty, idx)
    }
    if (op === 'choice') {
      return MathQuestionFactory.choiceAdd(difficulty, idx)
    }
    if (op === 'judge') {
      return MathQuestionFactory.judge(difficulty, idx)
    }
    return MathQuestionFactory.compare(difficulty, idx)
  }

  private static compare(difficulty: string, idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'compare', 'compare')
    const max = difficulty === 'hard' ? 80 : (difficulty === 'medium' ? 30 : 12)
    q.left = MathQuestionFactory.rand(1, max)
    q.right = MathQuestionFactory.rand(1, max)
    q.expression = `${q.left}  ○  ${q.right}`
    q.hint = '选出合适的关系'
    q.choiceA = '小于'
    q.choiceB = '等于'
    q.choiceC = '大于'
    if (q.left < q.right) {
      q.answer = 0
      q.answerLabel = '小于'
    } else if (q.left === q.right) {
      q.answer = 1
      q.answerLabel = '等于'
    } else {
      q.answer = 2
      q.answerLabel = '大于'
    }
    return q
  }

  private static compose(idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'compose', 'fill')
    const whole = MathQuestionFactory.rand(6, 10)
    q.left = whole
    q.right = MathQuestionFactory.rand(1, whole - 1)
    q.answer = whole - q.right
    q.answerLabel = `${q.answer}`
    q.expression = `${whole} 可以分成 ${q.right} 和 ？`
    q.hint = '分与合'
    return q
  }

  private static sequence(difficulty: string, idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'sequence', 'fill')
    const step = difficulty === 'hard' ? MathQuestionFactory.rand(3, 6) : MathQuestionFactory.rand(1, 3)
    const start = MathQuestionFactory.rand(1, 12)
    const a = start
    const b = start + step
    const c = start + step * 2
    q.left = c
    q.right = step
    q.answer = start + step * 3
    q.answerLabel = `${q.answer}`
    q.expression = `${a}，${b}，${c}，？`
    q.hint = '找规律，填下一个数'
    return q
  }

  private static oddEven(idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'odd_even', 'odd_even')
    const n = MathQuestionFactory.rand(1, 20)
    q.left = n
    q.expression = `${n} 是什么数？`
    q.hint = '单数是 1、3、5… 双数是 2、4、6…'
    q.choiceA = `${n} 是单数`
    q.choiceB = `${n} 是双数`
    q.choiceC = ''
    if (n % 2 === 1) {
      q.answer = 0
      q.answerLabel = `${n} 是单数`
    } else {
      q.answer = 1
      q.answerLabel = `${n} 是双数`
    }
    return q
  }

  private static sortNum(idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'sort', 'choice')
    let a = MathQuestionFactory.rand(1, 9)
    let b = MathQuestionFactory.rand(1, 9)
    let c = MathQuestionFactory.rand(1, 9)
    if (a === b) {
      b = a + 1
    }
    if (c === a || c === b) {
      c = a + 2
    }
    q.expression = `从小到大排，中间的数是？`
    q.hint = '数字排序'
    q.choiceA = `${a}`
    q.choiceB = `${b}`
    q.choiceC = `${c}`
    const lo = Math.min(a, Math.min(b, c))
    const hi = Math.max(a, Math.max(b, c))
    const mid = a + b + c - lo - hi
    q.answerLabel = `${mid}`
    if (`${a}` === `${mid}`) {
      q.answer = 0
    } else if (`${b}` === `${mid}`) {
      q.answer = 1
    } else {
      q.answer = 2
    }
    q.left = mid
    return q
  }

  private static shape(idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'shape', 'choice')
    const kind = idx % 3
    if (kind === 0) {
      q.expression = '三角形有几条边？'
      q.choiceA = '3 条'
      q.choiceB = '4 条'
      q.choiceC = '5 条'
      q.answer = 0
      q.answerLabel = '3 条'
    } else if (kind === 1) {
      q.expression = '正方形有几条边？'
      q.choiceA = '3 条'
      q.choiceB = '4 条'
      q.choiceC = '5 条'
      q.answer = 1
      q.answerLabel = '4 条'
    } else {
      q.expression = '五边形有几条边？'
      q.choiceA = '3 条'
      q.choiceB = '4 条'
      q.choiceC = '5 条'
      q.answer = 2
      q.answerLabel = '5 条'
    }
    q.hint = '图形认知'
    return q
  }

  private static linkNext(difficulty: string, idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'link', 'choice')
    const step = difficulty === 'hard' ? 3 : 1
    const start = MathQuestionFactory.rand(1, 8)
    const a = start
    const b = start + step
    const next = start + step * 2
    q.expression = `${a} 后面接着 ${b}，再接着是？`
    q.hint = '数字连线'
    q.choiceA = `${next}`
    q.choiceB = `${next + 1}`
    q.choiceC = `${next + 2}`
    q.answer = 0
    q.answerLabel = `${next}`
    q.left = next
    return q
  }

  private static place(difficulty: string, idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'place', 'fill')
    const n = difficulty === 'easy' ? MathQuestionFactory.rand(10, 49) : MathQuestionFactory.rand(10, 99)
    q.left = n
    const tens = Math.floor(n / 10)
    const ones = n % 10
    if (idx % 2 === 0) {
      q.answer = tens
      q.expression = `${n} 的十位是？`
    } else {
      q.answer = ones
      q.expression = `${n} 的个位是？`
    }
    q.answerLabel = `${q.answer}`
    q.hint = '十位在左边，个位在右边'
    return q
  }

  private static story(difficulty: string, idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'story', 'fill')
    const max = difficulty === 'hard' ? 20 : (difficulty === 'medium' ? 12 : 8)
    const a = MathQuestionFactory.rand(2, max)
    const b = MathQuestionFactory.rand(1, a)
    const kind = idx % 4
    if (kind === 0) {
      q.story = `小鹿有 ${a} 颗糖，又得到 ${b} 颗。一共有几颗？`
      q.op = 'add'
      q.opLabel = '+'
      q.left = a
      q.right = b
      q.answer = a + b
      q.expression = `${a} + ${b} = ?`
    } else if (kind === 1) {
      q.story = `篮子里有 ${a} 个苹果，吃掉 ${b} 个。还剩几个？`
      q.op = 'sub'
      q.opLabel = '−'
      q.left = a
      q.right = b
      q.answer = a - b
      q.expression = `${a} − ${b} = ?`
    } else if (kind === 2) {
      const m = MathQuestionFactory.rand(2, difficulty === 'easy' ? 4 : 6)
      const n = MathQuestionFactory.rand(2, difficulty === 'easy' ? 5 : 8)
      q.story = `每盒有 ${m} 支铅笔，一共 ${n} 盒。共有多少支？`
      q.op = 'mul'
      q.opLabel = '×'
      q.left = m
      q.right = n
      q.answer = m * n
      q.expression = `${m} × ${n} = ?`
    } else {
      const groups = MathQuestionFactory.rand(2, 5)
      const each = MathQuestionFactory.rand(2, 6)
      const total = groups * each
      q.story = `${total} 颗糖平均分给 ${groups} 个小朋友，每人几颗？`
      q.op = 'div'
      q.opLabel = '÷'
      q.left = total
      q.right = groups
      q.answer = each
      q.expression = `${total} ÷ ${groups} = ?`
    }
    q.answerLabel = `${q.answer}`
    q.hint = '先读题，再列式'
    return q
  }

  private static choiceAdd(difficulty: string, idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'choice', 'choice')
    const max = difficulty === 'hard' ? 40 : (difficulty === 'medium' ? 18 : 10)
    q.left = MathQuestionFactory.rand(1, max)
    q.right = MathQuestionFactory.rand(1, max)
    const correct = q.left + q.right
    q.answerLabel = `${correct}`
    q.expression = `${q.left} + ${q.right} = ?`
    q.hint = '选出正确答案'
    const w1 = correct + MathQuestionFactory.rand(1, 4)
    let w2 = Math.max(0, correct - MathQuestionFactory.rand(1, 3))
    if (w2 === correct) {
      w2 = correct + 5
    }
    MathQuestionFactory.shuffleChoices(q, `${correct}`, `${w1}`, `${w2}`, `${correct}`)
    return q
  }

  private static judge(difficulty: string, idx: number): MathQuestion {
    const q = MathQuestionFactory.base(idx, 'judge', 'judge')
    const max = difficulty === 'hard' ? 30 : 12
    q.left = MathQuestionFactory.rand(1, max)
    q.right = MathQuestionFactory.rand(1, max)
    const real = q.left + q.right
    const shown = idx % 2 === 0 ? real : real + MathQuestionFactory.rand(1, 3)
    q.expression = `${q.left} + ${q.right} = ${shown}`
    q.hint = '这个算式对不对？'
    q.choiceA = '是这样'
    q.choiceB = '再想想'
    q.choiceC = ''
    if (shown === real) {
      q.answer = 0
      q.answerLabel = '是这样'
    } else {
      q.answer = 1
      q.answerLabel = '再想想'
    }
    return q
  }

  private static shuffleChoices(q: MathQuestion, a: string, b: string, c: string, correct: string): void {
    let x: string = a
    let y: string = b
    let z: string = c
    const s = q.left + q.right
    if (s % 3 === 1) {
      const t = x
      x = y
      y = t
    } else if (s % 3 === 2) {
      const t = x
      x = z
      z = t
    }
    q.choiceA = x
    q.choiceB = y
    q.choiceC = z
    if (x === correct) {
      q.answer = 0
    } else if (y === correct) {
      q.answer = 1
    } else {
      q.answer = 2
    }
  }

  private static base(idx: number, op: string, qType: string): MathQuestion {
    const q = new MathQuestion()
    q.id = `qf_${op}_${idx}_${Date.now()}`
    q.op = op
    q.qType = qType
    return q
  }

  private static rand(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min
  }
}
