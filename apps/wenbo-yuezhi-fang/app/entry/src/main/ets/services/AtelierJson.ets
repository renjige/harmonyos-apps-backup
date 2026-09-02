import { CardItem, DailyItem } from '../models/AtelierModels'

/**
 * HarmonyOS 上 JSON.parse 成 class 时常丢字段。按原文扫描 list[]，不依赖实例水合。
 */
export class AtelierJson {
  static readField(obj: string, key: string): string {
    return AtelierJson.strField(obj, key)
  }

  static listObjects(raw: string): string[] {
    return AtelierJson.splitObjects(AtelierJson.listBlob(raw))
  }

  static parseCards(raw: string): CardItem[] {
    const out: CardItem[] = []
    if (raw.length === 0) {
      return out
    }
    const blobs = AtelierJson.splitObjects(AtelierJson.listBlob(raw))
    for (const obj of blobs) {
      const item = AtelierJson.toCard(obj)
      if (item.id.length > 0 && item.title.length > 0 && item.kind !== 'post' && item.type !== 'user') {
        out.push(item)
      }
    }
    return out
  }

  static parseDaily(raw: string): DailyItem[] {
    const out: DailyItem[] = []
    if (raw.length === 0) {
      return out
    }
    const blobs = AtelierJson.splitObjects(AtelierJson.listBlob(raw))
    for (const obj of blobs) {
      const item = AtelierJson.toDaily(obj)
      if (item.id.length > 0 && item.title.length > 0) {
        out.push(item)
      }
    }
    return out
  }

  static parseOneCard(raw: string): CardItem | undefined {
    const fromList = AtelierJson.parseCards(raw)
    if (fromList.length > 0) {
      return fromList[0]
    }
    const obj = AtelierJson.dataObject(raw)
    if (obj.length === 0) {
      return undefined
    }
    const item = AtelierJson.toCard(obj)
    if (item.id.length === 0 || item.title.length === 0) {
      return undefined
    }
    return item
  }

  static parseOneDaily(raw: string): DailyItem | undefined {
    const fromList = AtelierJson.parseDaily(raw)
    if (fromList.length > 0) {
      return fromList[0]
    }
    const obj = AtelierJson.dataObject(raw)
    if (obj.length === 0) {
      return undefined
    }
    const item = AtelierJson.toDaily(obj)
    if (item.id.length === 0) {
      return undefined
    }
    return item
  }

  private static toCard(obj: string): CardItem {
    let category = AtelierJson.strField(obj, 'category')
    if (category.length === 0) {
      category = 'life'
    }
    let cover = AtelierJson.firstField(obj, 'coverMedia', 'coverKey')
    if (cover.length === 0) {
      cover = 'cover_life_01'
    }
    let mins = AtelierJson.numField(obj, 'readMinutes')
    if (mins <= 0) {
      mins = 2
    }
    const item = CardItem.create(
      AtelierJson.strField(obj, 'id'),
      AtelierJson.strField(obj, 'title'),
      AtelierJson.firstField(obj, 'summary', 'description'),
      AtelierJson.firstField(obj, 'body', 'description'),
      category,
      cover,
      mins,
      AtelierJson.strField(obj, 'publishDate')
    )
    const kind = AtelierJson.strField(obj, 'kind')
    if (kind.length > 0) {
      item.kind = kind
    }
    const typ = AtelierJson.strField(obj, 'type')
    if (typ.length > 0) {
      item.type = typ
    }
    const author = AtelierJson.strField(obj, 'authorName')
    if (author.length > 0) {
      item.authorName = author
    }
    return item
  }

  private static toDaily(obj: string): DailyItem {
    let cover = AtelierJson.firstField(obj, 'coverMedia', 'coverKey')
    if (cover.length === 0) {
      cover = 'cover_daily_01'
    }
    return DailyItem.create(
      AtelierJson.strField(obj, 'id'),
      AtelierJson.strField(obj, 'title'),
      AtelierJson.firstField(obj, 'quote', 'summary'),
      AtelierJson.firstField(obj, 'body', 'description'),
      AtelierJson.strField(obj, 'dateKey'),
      cover
    )
  }

  private static listBlob(raw: string): string {
    const idx = raw.indexOf('"list"')
    if (idx < 0) {
      return ''
    }
    const bracket = raw.indexOf('[', idx)
    if (bracket < 0) {
      return ''
    }
    const end = AtelierJson.matchPair(raw, bracket, '[', ']')
    if (end < 0) {
      return ''
    }
    return raw.substring(bracket + 1, end)
  }

  private static dataObject(raw: string): string {
    const idx = raw.indexOf('"data"')
    if (idx < 0) {
      return ''
    }
    const brace = raw.indexOf('{', idx)
    if (brace < 0) {
      return ''
    }
    const end = AtelierJson.matchPair(raw, brace, '{', '}')
    if (end < 0) {
      return ''
    }
    return raw.substring(brace, end + 1)
  }

  private static splitObjects(inner: string): string[] {
    const out: string[] = []
    let depth = 0
    let start = -1
    let inStr = false
    let escape = false
    for (let i = 0; i < inner.length; i++) {
      const c = inner.charAt(i)
      if (inStr) {
        if (escape) {
          escape = false
        } else if (c === '\\') {
          escape = true
        } else if (c === '"') {
          inStr = false
        }
        continue
      }
      if (c === '"') {
        inStr = true
        continue
      }
      if (c === '{') {
        if (depth === 0) {
          start = i
        }
        depth++
      } else if (c === '}') {
        depth--
        if (depth === 0 && start >= 0) {
          out.push(inner.substring(start, i + 1))
          start = -1
        }
      }
    }
    return out
  }

  private static matchPair(src: string, openAt: number, openCh: string, closeCh: string): number {
    let depth = 0
    let inStr = false
    let escape = false
    for (let i = openAt; i < src.length; i++) {
      const c = src.charAt(i)
      if (inStr) {
        if (escape) {
          escape = false
        } else if (c === '\\') {
          escape = true
        } else if (c === '"') {
          inStr = false
        }
        continue
      }
      if (c === '"') {
        inStr = true
        continue
      }
      if (c === openCh) {
        depth++
      } else if (c === closeCh) {
        depth--
        if (depth === 0) {
          return i
        }
      }
    }
    return -1
  }

  private static firstField(obj: string, a: string, b: string): string {
    const left = AtelierJson.strField(obj, a)
    if (left.length > 0) {
      return left
    }
    return AtelierJson.strField(obj, b)
  }

  private static strField(obj: string, key: string): string {
    const after = AtelierJson.rawAfterKey(obj, key)
    if (after.length === 0) {
      return ''
    }
    if (after.charAt(0) === '"') {
      return AtelierJson.readQuoted(after, 1)
    }
    return AtelierJson.readBare(after)
  }

  private static numField(obj: string, key: string): number {
    const s = AtelierJson.strField(obj, key)
    if (s.length === 0) {
      return 0
    }
    const n = Number(s)
    if (n !== n) {
      return 0
    }
    return n
  }

  private static rawAfterKey(obj: string, key: string): string {
    const needle = `"${key}"`
    const idx = obj.indexOf(needle)
    if (idx < 0) {
      return ''
    }
    let p = idx + needle.length
    while (p < obj.length) {
      const c = obj.charAt(p)
      if (c === ' ' || c === '\n' || c === '\r' || c === '\t' || c === ':') {
        p++
      } else {
        break
      }
    }
    return obj.substring(p)
  }

  private static readQuoted(src: string, start: number): string {
    let out = ''
    let escape = false
    for (let i = start; i < src.length; i++) {
      const c = src.charAt(i)
      if (escape) {
        if (c === 'n') {
          out += '\n'
        } else if (c === 't') {
          out += '\t'
        } else if (c === 'r') {
          out += '\r'
        } else {
          out += c
        }
        escape = false
      } else if (c === '\\') {
        escape = true
      } else if (c === '"') {
        return out
      } else {
        out += c
      }
    }
    return out
  }

  private static readBare(src: string): string {
    let out = ''
    for (let i = 0; i < src.length; i++) {
      const c = src.charAt(i)
      if (c === ',' || c === '}' || c === ']' || c === ' ' || c === '\n' || c === '\r') {
        break
      }
      out += c
    }
    if (out === 'null' || out === 'undefined') {
      return ''
    }
    return out
  }
}
