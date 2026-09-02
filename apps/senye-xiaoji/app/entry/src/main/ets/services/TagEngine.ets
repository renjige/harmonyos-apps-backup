import { NoteItem } from '../models/NoteModels'

class TagRule {
  keywords: string[] = []
  tag: string = ''
}

export class TagEngine {
  private static rules(): TagRule[] {
    const list: TagRule[] = []
    const r1 = new TagRule()
    r1.keywords = ['工作', '项目', '会议', '灵感', '方案', '客户']
    r1.tag = '工作灵感'
    list.push(r1)
    const r2 = new TagRule()
    r2.keywords = ['生活', '日常', '做饭', '散步', '购物', '家务']
    r2.tag = '生活随笔'
    list.push(r2)
    const r3 = new TagRule()
    r3.keywords = ['读', '书', '文章', '章节', '笔记']
    r3.tag = '阅读笔记'
    list.push(r3)
    const r4 = new TagRule()
    r4.keywords = ['自然', '森林', '山', '野', '花', '树', '湖']
    r4.tag = '森野随记'
    list.push(r4)
    const r5 = new TagRule()
    r5.keywords = ['旅行', '出行', '路', '风景']
    r5.tag = '出行见闻'
    list.push(r5)
    return list
  }

  static suggest(body: string): string[] {
    const out: string[] = []
    const text = body.trim()
    if (text.length === 0) {
      return out
    }
    for (const rule of TagEngine.rules()) {
      let hit = false
      for (const kw of rule.keywords) {
        if (text.indexOf(kw) >= 0) {
          hit = true
        }
      }
      if (hit) {
        let exists = false
        for (const t of out) {
          if (t === rule.tag) {
            exists = true
          }
        }
        if (!exists) {
          out.push(rule.tag)
        }
      }
    }
    if (out.length === 0) {
      out.push('日常随记')
    }
    return out
  }

  static search(notes: NoteItem[], query: string): NoteItem[] {
    const q = query.trim().toLowerCase()
    if (q.length === 0) {
      return notes
    }
    const out: NoteItem[] = []
    for (const n of notes) {
      if (n.body.toLowerCase().indexOf(q) >= 0) {
        out.push(n)
        continue
      }
      for (const t of n.tagList()) {
        if (t.toLowerCase().indexOf(q) >= 0) {
          out.push(n)
          break
        }
      }
    }
    return out
  }

  static similarGroups(notes: NoteItem[]): string[] {
    const counts: string[] = []
    const freq: number[] = []
    for (const n of notes) {
      for (const t of n.tagList()) {
        let idx = -1
        for (let i = 0; i < counts.length; i++) {
          if (counts[i] === t) {
            idx = i
          }
        }
        if (idx >= 0) {
          freq[idx] += 1
        } else {
          counts.push(t)
          freq.push(1)
        }
      }
    }
    const tags: string[] = []
    const used: boolean[] = []
    for (let i = 0; i < counts.length; i++) {
      used.push(false)
    }
    while (tags.length < counts.length) {
      let best = -1
      for (let i = 0; i < counts.length; i++) {
        if (used[i]) {
          continue
        }
        if (best < 0 || freq[i] > freq[best]) {
          best = i
        }
      }
      if (best < 0) {
        break
      }
      used[best] = true
      if (freq[best] >= 2) {
        tags.push(counts[best])
      }
    }
    return tags
  }
}
