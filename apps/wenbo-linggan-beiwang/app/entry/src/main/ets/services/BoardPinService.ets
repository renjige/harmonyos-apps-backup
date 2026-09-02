import { CreateBoardRequest, InspirationItem, UpdateBoardRequest } from '../models/InspirationModels'
import { InspirationBizService } from './InspirationBizService'

export class BoardPinService {
  static isOwnBoard(item: InspirationItem, uid: string): boolean {
    if (item.kind === 'showcase') {
      return false
    }
    return item.userId === uid
  }

  static async listOwnBoards(userId: string): Promise<InspirationItem[]> {
    const all = await InspirationBizService.loadMoodBoards(userId)
    const out: InspirationItem[] = []
    for (const b of all) {
      if (BoardPinService.isOwnBoard(b, userId)) {
        out.push(b)
      }
    }
    return out
  }

  static nextY(cardsJson: string): number {
    let count = 0
    let idx = 0
    while (true) {
      const found = cardsJson.indexOf('"type"', idx)
      if (found < 0) {
        break
      }
      count += 1
      idx = found + 5
    }
    return 20 + count * 72
  }

  static appendTextCard(cardsJson: string, text: string): string {
    const y = BoardPinService.nextY(cardsJson)
    const card = `{"type":"text","text":${JSON.stringify(text)},"x":16,"y":${y}}`
    const raw = cardsJson.trim()
    if (raw.length === 0 || raw === '[]') {
      return `[${card}]`
    }
    if (raw.endsWith(']')) {
      const inner = raw.substring(1, raw.length - 1).trim()
      if (inner.length === 0) {
        return `[${card}]`
      }
      return `[${inner},${card}]`
    }
    return `[${card}]`
  }

  static decodeJsonText(raw: string): string {
    let out = ''
    let i = 0
    while (i < raw.length) {
      const ch = raw.substring(i, i + 1)
      if (ch === '\\' && i + 1 < raw.length) {
        const next = raw.substring(i + 1, i + 2)
        if (next === 'n') {
          out += '\n'
          i += 2
          continue
        }
        if (next === 't') {
          out += '\t'
          i += 2
          continue
        }
        if (next === '"') {
          out += '"'
          i += 2
          continue
        }
        if (next === '\\') {
          out += '\\'
          i += 2
          continue
        }
      }
      out += ch
      i += 1
    }
    return out
  }

  static extractCardTexts(cardsJson: string): string[] {
    const out: string[] = []
    const raw = cardsJson
    let idx = 0
    while (true) {
      const key = raw.indexOf('"text":', idx)
      if (key < 0) {
        break
      }
      let start = key + 7
      while (start < raw.length) {
        const ch = raw.substring(start, start + 1)
        if (ch === ' ' || ch === ':') {
          start += 1
        } else {
          break
        }
      }
      if (raw.substring(start, start + 1) !== '"') {
        idx = key + 7
        continue
      }
      start += 1
      let end = start
      let escaped = false
      while (end < raw.length) {
        const ch = raw.substring(end, end + 1)
        if (escaped) {
          escaped = false
          end += 1
          continue
        }
        if (ch === '\\') {
          escaped = true
          end += 1
          continue
        }
        if (ch === '"') {
          break
        }
        end += 1
      }
      out.push(BoardPinService.decodeJsonText(raw.substring(start, end)))
      idx = end + 1
    }
    return out
  }

  static async pinToBoard(board: InspirationItem, text: string): Promise<boolean> {
    const base = board.cardsJson.length > 0 ? board.cardsJson : board.body
    const nextJson = BoardPinService.appendTextCard(base, text)
    const upd = new UpdateBoardRequest()
    upd.cardsJson = nextJson
    upd.body = nextJson
    const saved = await InspirationBizService.updateMoodBoard(board.id, upd)
    return saved !== undefined
  }

  static async pinToWorkbench(text: string, coverKey: string, userId: string): Promise<boolean> {
    const own = await BoardPinService.listOwnBoards(userId)
    let target: InspirationItem | undefined = undefined
    for (const b of own) {
      if (b.title === '灵感工作台') {
        target = b
        break
      }
      if (target === undefined) {
        target = b
      }
    }
    if (target === undefined) {
      const req = new CreateBoardRequest()
      req.title = '灵感工作台'
      req.description = '从记录与详情一键钉入的灵感卡片'
      req.coverKey = coverKey.length > 0 ? coverKey : 'board_default'
      req.cardsJson = BoardPinService.appendTextCard('[]', text)
      req.body = req.cardsJson
      req.userId = userId
      const created = await InspirationBizService.createMoodBoard(req)
      return created !== undefined
    }
    return await BoardPinService.pinToBoard(target, text)
  }
}
