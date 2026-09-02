import { NoteItem } from '../models/NoteModels'
import { MoodCatalog } from './MoodCatalog'

export class MoodCount {
  id: string = ''
  label: string = ''
  color: string = ''
  count: number = 0
}

export class ReviewStats {
  static moodCounts(notes: NoteItem[]): MoodCount[] {
    const out: MoodCount[] = []
    for (const opt of MoodCatalog.all()) {
      const row = new MoodCount()
      row.id = opt.id
      row.label = opt.label
      row.color = opt.color
      row.count = 0
      for (const n of notes) {
        if (n.mood === opt.id) {
          row.count += 1
        }
      }
      out.push(row)
    }
    return out
  }

  static topMoodLabel(rows: MoodCount[]): string {
    let best: MoodCount | undefined = undefined
    for (const row of rows) {
      if (best === undefined || row.count > best.count) {
        best = row
      }
    }
    if (best === undefined || best.count === 0) {
      return '还没有留下心情'
    }
    return best.label
  }

  static topTag(notes: NoteItem[]): string {
    const names: string[] = []
    const counts: number[] = []
    for (const n of notes) {
      for (const tag of n.tagList()) {
        let idx = -1
        let i = 0
        for (const name of names) {
          if (name === tag) {
            idx = i
          }
          i += 1
        }
        if (idx < 0) {
          names.push(tag)
          counts.push(1)
        } else {
          const next: number[] = []
          let j = 0
          for (const c of counts) {
            if (j === idx) {
              next.push(c + 1)
            } else {
              next.push(c)
            }
            j += 1
          }
          counts.length = 0
          for (const c of next) {
            counts.push(c)
          }
        }
      }
    }
    let bestName = ''
    let bestCount = 0
    let k = 0
    for (const name of names) {
      let c = 0
      let p = 0
      for (const v of counts) {
        if (p === k) {
          c = v
        }
        p += 1
      }
      if (c > bestCount) {
        bestCount = c
        bestName = name
      }
      k += 1
    }
    return bestName.length > 0 ? bestName : '还没有标签'
  }

  static pickThree(notes: NoteItem[]): NoteItem[] {
    const work: NoteItem[] = []
    for (const n of notes) {
      work.push(n)
    }
    const result: NoteItem[] = []
    while (work.length > 0 && result.length < 3) {
      let best: NoteItem | undefined = undefined
      for (const n of work) {
        if (best === undefined || n.body.length > best.body.length) {
          best = n
        }
      }
      if (best === undefined) {
        break
      }
      result.push(best)
      const next: NoteItem[] = []
      for (const n of work) {
        if (n.id !== best.id) {
          next.push(n)
        }
      }
      work.length = 0
      for (const n of next) {
        work.push(n)
      }
    }
    return result
  }

  static barWidth(count: number): number {
    if (count <= 0) {
      return 8
    }
    const w = 24 + count * 22
    if (w > 220) {
      return 220
    }
    return w
  }

  static uniqueMonths(all: NoteItem[]): string[] {
    const monthSet: string[] = []
    for (const n of all) {
      const key = n.noteDate.length >= 7 ? n.noteDate.substring(0, 7) : n.noteDate
      let seen = false
      for (const m of monthSet) {
        if (m === key) {
          seen = true
        }
      }
      if (!seen && key.length > 0) {
        monthSet.push(key)
      }
    }
    return monthSet
  }
}
