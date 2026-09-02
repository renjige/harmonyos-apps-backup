import { AthleteItem, QuizChoice, QuizQuestion } from '../models/StarModels'

/** 根据球星资料生成知识挑战题，非资讯浏览。 */
export class QuizBuilder {
  static build(athletes: AthleteItem[]): QuizQuestion[] {
    const out: QuizQuestion[] = []
    if (athletes.length < 4) {
      return out
    }
    const max = athletes.length >= 5 ? 5 : athletes.length
    let i = 0
    while (i < max) {
      const q = QuizBuilder.oneQuestion(athletes, i)
      if (q !== undefined) {
        out.push(q)
      }
      i += 1
    }
    return out
  }

  private static oneQuestion(athletes: AthleteItem[], index: number): QuizQuestion | undefined {
    const target = athletes[index]
    if (target === undefined) {
      return undefined
    }
    const kind = index % 3
    const q = new QuizQuestion()
    q.id = `q_${index}_${target.id}`
    q.athleteId = target.id
    if (kind === 0) {
      q.prompt = `「${target.title}」目前所属队伍是？`
      q.choices = QuizBuilder.choices(athletes, index, target.team.length > 0 ? target.team : '独立选手', 'team')
    } else if (kind === 1) {
      q.prompt = `「${target.title}」的运动项目是？`
      q.choices = QuizBuilder.choices(athletes, index, target.sportLabel(), 'sport')
    } else {
      q.prompt = `「${target.title}」的国籍/地区是？`
      q.choices = QuizBuilder.choices(athletes, index, target.nationality.length > 0 ? target.nationality : '未公开', 'nation')
    }
    if (q.choices.length < 2) {
      return undefined
    }
    return q
  }

  private static fieldOf(item: AthleteItem, field: string): string {
    if (field === 'team') {
      return item.team.length > 0 ? item.team : '独立选手'
    }
    if (field === 'sport') {
      return item.sportLabel()
    }
    return item.nationality.length > 0 ? item.nationality : '未公开'
  }

  private static choices(athletes: AthleteItem[], index: number, correct: string, field: string): QuizChoice[] {
    const texts: string[] = []
    texts.push(correct)
    let i = 0
    while (i < athletes.length && texts.length < 4) {
      const other = athletes[(index + 1 + i) % athletes.length]
      const val = QuizBuilder.fieldOf(other, field)
      let exists = false
      for (const t of texts) {
        if (t === val) {
          exists = true
          break
        }
      }
      if (!exists && val.length > 0) {
        texts.push(val)
      }
      i += 1
    }
    const out: QuizChoice[] = []
    let c = 0
    while (c < texts.length) {
      const choice = new QuizChoice()
      choice.id = `${field}_${index}_${c}`
      choice.text = texts[c]
      choice.correct = texts[c] === correct
      out.push(choice)
      c += 1
    }
    return QuizBuilder.rotate(out, index)
  }

  private static rotate(list: QuizChoice[], offset: number): QuizChoice[] {
    if (list.length === 0) {
      return list
    }
    const start = offset % list.length
    const out: QuizChoice[] = []
    let i = 0
    while (i < list.length) {
      out.push(list[(start + i) % list.length])
      i += 1
    }
    return out
  }
}
