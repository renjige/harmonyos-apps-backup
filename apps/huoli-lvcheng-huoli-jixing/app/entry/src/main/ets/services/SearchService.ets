import { VitalityRecord, VitalityNote } from '../models/VitalityModels'
import { VitalityStore } from './VitalityStore'
import { DimensionOption } from '../models/VitalityModels'

export class SearchFilter {
  keyword: string = ''
  moodKey: string = ''
  exerciseKey: string = ''
  energyKey: string = ''
  pinnedOnly: boolean = false
  searchNotes: boolean = false
}

export class SearchService {
  static async searchRecords(keyword: string, moodKey: string): Promise<VitalityRecord[]> {
    const f = new SearchFilter()
    f.keyword = keyword
    f.moodKey = moodKey
    return SearchService.searchWithFilter(f)
  }

  static async searchWithFilter(filter: SearchFilter): Promise<VitalityRecord[]> {
    const list = await VitalityStore.loadAll()
    const pins = await VitalityStore.loadPins()
    const out: VitalityRecord[] = []
    const q = filter.keyword.trim().toLowerCase()
    for (const r of list) {
      if (!r.isComplete()) {
        continue
      }
      if (filter.moodKey.length > 0 && r.moodKey !== filter.moodKey) {
        continue
      }
      if (filter.exerciseKey.length > 0 && r.exerciseKey !== filter.exerciseKey) {
        continue
      }
      if (filter.energyKey.length > 0 && r.energyKey !== filter.energyKey) {
        continue
      }
      if (filter.pinnedOnly) {
        let pinned = false
        for (const p of pins) {
          if (p === r.dateKey) {
            pinned = true
          }
        }
        if (!pinned) {
          continue
        }
      }
      if (q.length === 0) {
        out.push(r)
        continue
      }
      const mood = DimensionOption.labelFor('mood', r.moodKey).toLowerCase()
      const ex = DimensionOption.labelFor('exercise', r.exerciseKey).toLowerCase()
      const en = DimensionOption.labelFor('energy', r.energyKey).toLowerCase()
      const note = r.note.toLowerCase()
      const date = r.dateKey
      const tags = r.tagKeys.toLowerCase()
      if (note.indexOf(q) >= 0 || mood.indexOf(q) >= 0 || ex.indexOf(q) >= 0 ||
        en.indexOf(q) >= 0 || date.indexOf(q) >= 0 || tags.indexOf(q) >= 0) {
        out.push(r)
      }
    }
    return out
  }

  static async searchNotes(keyword: string): Promise<VitalityNote[]> {
    const list = await VitalityStore.loadNotes()
    const out: VitalityNote[] = []
    const q = keyword.trim().toLowerCase()
    for (const n of list) {
      if (q.length === 0) {
        out.push(n)
        continue
      }
      const hay = `${n.title} ${n.body} ${n.dateKey} ${n.tagKeys}`.toLowerCase()
      if (hay.indexOf(q) >= 0) {
        out.push(n)
      }
    }
    return out
  }
}
