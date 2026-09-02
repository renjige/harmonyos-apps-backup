import { FactItem } from '../models/CommonSenseModels'
import { QuizOption, QuizQuestion } from '../models/CommonSenseToolModels'

/** 根据常识正文生成选择题（规则模板，不调用大模型）。 */
export class QuizService {
  static buildPaper(facts: FactItem[], count: number, salt: number = Date.now()): QuizQuestion[] {
    const pool: FactItem[] = []
    for (const item of facts) {
      if (item.id.length > 0 && item.summary.length > 0) {
        pool.push(item)
      }
    }
    if (pool.length === 0) {
      return []
    }
    const shuffled = QuizService.shuffleFacts(pool, salt)
    const size = shuffled.length < count ? shuffled.length : count
    const questions: QuizQuestion[] = []
    for (let i = 0; i < size; i++) {
      questions.push(QuizService.oneQuestion(shuffled[i], pool, salt + i))
    }
    return questions
  }

  private static oneQuestion(fact: FactItem, pool: FactItem[], salt: number): QuizQuestion {
    const q = new QuizQuestion()
    q.factId = fact.id
    q.title = fact.title
    q.prompt = `关于「${fact.title}」，哪一项说法更准确？`
    const distractors = QuizService.otherSummaries(fact.id, fact.summary, pool, 3, salt)
    const opts: QuizOption[] = []
    const correct = new QuizOption()
    correct.id = `${fact.id}_correct`
    correct.text = fact.summary
    correct.correct = true
    opts.push(correct)
    for (let i = 0; i < distractors.length; i++) {
      const opt = new QuizOption()
      opt.id = `${fact.id}_d${i}`
      opt.text = distractors[i]
      opt.correct = false
      opts.push(opt)
    }
    q.options = QuizService.rotate(opts, salt + fact.id.length)
    return q
  }

  private static otherSummaries(
    skipId: string,
    skipSummary: string,
    pool: FactItem[],
    need: number,
    salt: number
  ): string[] {
    const out: string[] = []
    const start = salt % pool.length
    for (let i = 0; i < pool.length && out.length < need; i++) {
      const item = pool[(start + i) % pool.length]
      if (item.id === skipId) {
        continue
      }
      if (item.summary.length === 0) {
        continue
      }
      if (item.summary === skipSummary) {
        continue
      }
      let dup = false
      for (const row of out) {
        if (row === item.summary) {
          dup = true
        }
      }
      if (!dup) {
        out.push(item.summary)
      }
    }
    return out
  }

  private static shuffleFacts(pool: FactItem[], salt: number): FactItem[] {
    const out: FactItem[] = []
    for (const item of pool) {
      out.push(item)
    }
    let seed = salt % 2147483647
    if (seed <= 0) {
      seed = seed + 2147483646
    }
    for (let i = out.length - 1; i > 0; i--) {
      seed = (seed * 48271) % 2147483647
      const j = seed % (i + 1)
      const tmp = out[i]
      out[i] = out[j]
      out[j] = tmp
    }
    return out
  }

  private static rotate(opts: QuizOption[], n: number): QuizOption[] {
    if (opts.length === 0) {
      return opts
    }
    const k = n % opts.length
    const out: QuizOption[] = []
    for (let i = 0; i < opts.length; i++) {
      out.push(opts[(i + k) % opts.length])
    }
    return out
  }
}
