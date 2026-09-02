import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SportRecord } from '../models/SportRecord'
import { WatchStatus } from '../models/CollectModels'

const STORE = 'saichang_shilu_v1'
const KEY_RECORDS = 'records'

export class RecordStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      RecordStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      RecordStore.pref = null
    }
  }

  static async loadAll(): Promise<SportRecord[]> {
    const raw = await RecordStore.getString(KEY_RECORDS, '')
    return RecordStore.parseRecords(raw)
  }

  static async saveRecord(record: SportRecord): Promise<void> {
    const copy = SportRecord.cloneFrom(record)
    copy.status = WatchStatus.normalize(copy.status)
    copy.updatedAt = Date.now()
    const list = await RecordStore.loadAll()
    const next: SportRecord[] = []
    let found = false
    for (const it of list) {
      if (it.id === copy.id) {
        next.push(copy)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(copy)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    await RecordStore.persistRecords(next)
  }

  static async deleteRecord(id: string): Promise<void> {
    const list = await RecordStore.loadAll()
    const next: SportRecord[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await RecordStore.persistRecords(next)
  }

  static async findById(id: string): Promise<SportRecord | undefined> {
    const list = await RecordStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return SportRecord.cloneFrom(it)
      }
    }
    return undefined
  }

  static async exportCsv(): Promise<string> {
    const list = await RecordStore.loadAll()
    const lines: string[] = []
    lines.push('赛场拾录 — CSV 导出')
    lines.push('id,运动类型,标题,日期,时间,地点,对手,时长(分),距离(km),成绩,心率,备注')
    for (const it of list) {
      const row = [
        it.id,
        it.sportType,
        it.title,
        it.date,
        it.time,
        it.location,
        it.opponent,
        `${it.duration}`,
        `${it.distance}`,
        it.score,
        it.heartRate,
        it.note.replace(/,/g, '，').replace(/\n/g, ' ')
      ]
      lines.push(row.join(','))
    }
    return lines.join('\n')
  }

  static async exportText(): Promise<string> {
    const list = await RecordStore.loadAll()
    const lines: string[] = []
    lines.push('赛场拾录 — 文本导出')
    lines.push(`共 ${list.length} 场记录`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(`${it.date} ${it.time} · ${it.title}`)
      lines.push(`类型: ${it.sportType} · 地点: ${it.location}`)
      if (it.duration > 0) {
        lines.push(`时长: ${it.duration} 分钟`)
      }
      if (it.note.length > 0) {
        lines.push(it.note)
      }
      lines.push('')
    }
    return lines.join('\n')
  }

  private static async persistRecords(items: SportRecord[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(RecordStore.serialize(it))
    }
    await RecordStore.putString(KEY_RECORDS, lines.join('\n'))
  }

  private static serialize(it: SportRecord): string {
    const note = it.note.replace(/\n/g, '\\n')
    const recap = it.recapSummary.replace(/\n/g, '\\n')
    const photos = it.photos.join('|')
    return [
      it.id, it.sportType, it.title, it.date, it.time, it.location, it.opponent,
      `${it.duration}`, `${it.distance}`, it.score, it.heartRate, note, photos,
      `${it.createdAt}`, `${it.updatedAt}`,
      it.result, it.momentsPacked, recap, it.recapScore,
      it.status, `${it.rating}`, it.season, it.tagsPacked, it.homeTeam,
      it.recapPhases.replace(/\n/g, '\\n'),
      it.mvpName, it.prediction, it.checklistPacked, it.pinned ? '1' : '0',
      `${it.rateQuality}`, `${it.rateIntensity}`, `${it.rateAtmosphere}`,
      it.watchPlan.replace(/\n/g, '\\n')
    ].join('\t')
  }

  private static parseRecords(raw: string): SportRecord[] {
    const out: SportRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 15) {
        continue
      }
      const r = new SportRecord()
      r.id = parts[0]
      r.sportType = parts[1]
      r.title = parts[2]
      r.date = parts[3]
      r.time = parts[4]
      r.location = parts[5]
      r.opponent = parts[6]
      r.duration = parseInt(parts[7], 10)
      r.distance = parseFloat(parts[8])
      r.score = parts[9]
      r.heartRate = parts[10]
      r.note = parts[11].replace(/\\n/g, '\n')
      if (parts[12].length > 0) {
        r.photos = parts[12].split('|')
      }
      r.createdAt = parseInt(parts[13], 10)
      r.updatedAt = parseInt(parts[14], 10)
      if (parts.length >= 16) {
        r.result = parts[15]
      }
      if (parts.length >= 17) {
        r.momentsPacked = parts[16]
      }
      if (parts.length >= 18) {
        r.recapSummary = parts[17].replace(/\\n/g, '\n')
      }
      if (parts.length >= 19) {
        r.recapScore = parts[18]
      }
      if (parts.length >= 20) {
        r.status = WatchStatus.normalize(parts[19])
      } else {
        r.status = 'want'
      }
      if (parts.length >= 21) {
        r.rating = parseInt(parts[20], 10) || 0
      }
      if (parts.length >= 22) {
        r.season = parts[21]
      }
      if (parts.length >= 23) {
        r.tagsPacked = parts[22]
      }
      if (parts.length >= 24) {
        r.homeTeam = parts[23]
      }
      if (parts.length >= 25) {
        r.recapPhases = parts[24].replace(/\\n/g, '\n')
      }
      if (parts.length >= 26) {
        r.mvpName = parts[25]
      }
      if (parts.length >= 27) {
        r.prediction = parts[26]
      }
      if (parts.length >= 28) {
        r.checklistPacked = parts[27]
      }
      if (parts.length >= 29) {
        r.pinned = parts[28] === '1'
      }
      if (parts.length >= 30) {
        r.rateQuality = parseInt(parts[29], 10) || 0
      }
      if (parts.length >= 31) {
        r.rateIntensity = parseInt(parts[30], 10) || 0
      }
      if (parts.length >= 32) {
        r.rateAtmosphere = parseInt(parts[31], 10) || 0
      }
      if (parts.length >= 33) {
        r.watchPlan = parts[32].replace(/\\n/g, '\n')
      }
      out.push(r)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (RecordStore.pref === null) {
      return fallback
    }
    try {
      const v = await RecordStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (RecordStore.pref === null) {
      return
    }
    try {
      await RecordStore.pref.put(key, value)
      await RecordStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
