import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { MicroEssay } from '../models/EssayModels'

const STORE = 'weiguan_practice_v1'
const KEY_DONE = 'done_csv'

export class PracticeDay {
  index: number = 0
  title: string = ''
  hint: string = ''
  done: boolean = false
}

export class PracticeStore {
  private static pref: preferences.Preferences | null = null
  private static doneCsv: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PracticeStore.pref = await preferences.getPreferences(context, STORE)
      const raw = await PracticeStore.pref.get(KEY_DONE, '')
      PracticeStore.doneCsv = `${raw}`
    } catch {
      PracticeStore.pref = null
    }
  }

  static lessons(): PracticeDay[] {
    const titles: string[] = ['光', '声', '味', '触', '色', '人', '空']
    const hints: string[] = [
      '只写光线落在何处，不写心情。',
      '记下一种没有名字的声音。',
      '空气里有没有一种说不清的气味。',
      '手指碰到的第一个表面是冷还是暖。',
      '把眼前三种颜色按远近排成一行。',
      '谁从身边走过，留下了什么痕迹。',
      '一个不值得拍照、但值得写下的空白。'
    ]
    const done = PracticeStore.doneSet()
    const out: PracticeDay[] = []
    for (let i = 0; i < 7; i++) {
      const d = new PracticeDay()
      d.index = i
      d.title = titles[i]
      d.hint = hints[i]
      d.done = done.has(`${i}`)
      out.push(d)
    }
    return out
  }

  static senseKeyOf(index: number): string {
    const keys: string[] = ['light', 'sound', 'scent', 'touch', 'color', 'people', 'space']
    if (index < 0 || index >= keys.length) {
      return ''
    }
    return keys[index]
  }

  static applyWeekDone(base: PracticeDay[], week: MicroEssay[]): PracticeDay[] {
    for (const d of base) {
      const key = PracticeStore.senseKeyOf(d.index)
      d.done = false
      for (const e of week) {
        if (e.senseKey === key) {
          d.done = true
          break
        }
      }
    }
    return base
  }

  static writtenCount(lessons: PracticeDay[]): number {
    let n = 0
    for (const d of lessons) {
      if (d.done) {
        n++
      }
    }
    return n
  }

  static async toggle(index: number): Promise<void> {
    const set = PracticeStore.doneSet()
    const key = `${index}`
    if (set.has(key)) {
      set.delete(key)
    } else {
      set.add(key)
    }
    const parts: string[] = []
    set.forEach((v) => { parts.push(v) })
    PracticeStore.doneCsv = parts.join(',')
    if (PracticeStore.pref !== null) {
      try {
        await PracticeStore.pref.put(KEY_DONE, PracticeStore.doneCsv)
        await PracticeStore.pref.flush()
      } catch {
      }
    }
    const cur = AppStorage.get<number>('practiceEpoch') ?? 0
    AppStorage.setOrCreate('practiceEpoch', cur + 1)
  }

  private static doneSet(): Set<string> {
    const set = new Set<string>()
    if (PracticeStore.doneCsv.length === 0) {
      return set
    }
    const parts = PracticeStore.doneCsv.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        set.add(p)
      }
    }
    return set
  }
}
