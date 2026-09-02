import { ManualTrackDraft, TrackRecord } from '../models/TrackModels'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

export class ManualTrackResult {
  ok: boolean = false
  message: string = ''
  record: TrackRecord = new TrackRecord()
}

export class ManualTrackService {
  static create(draft: ManualTrackDraft): ManualTrackResult {
    const out = new ManualTrackResult()
    const title = draft.title.trim()
    if (title.length === 0) {
      out.message = '请填写足迹标题'
      return out
    }
    const rec = new TrackRecord()
    rec.id = `fp_${Date.now()}`
    rec.title = title
    rec.placeName = draft.placeName.trim()
    rec.note = draft.note.trim()
    if (draft.recordDate.length > 0) {
      rec.startedAt = `${draft.recordDate}T08:00:00.000Z`
    } else {
      rec.startedAt = new Date().toISOString()
    }
    rec.endedAt = rec.startedAt
    const kmText = draft.distanceKm.trim()
    if (kmText.length > 0) {
      const km = Number.parseFloat(kmText)
      rec.distanceM = Number.isNaN(km) ? 0 : Math.max(0, km * 1000)
    }
    const minText = draft.durationMin.trim()
    if (minText.length > 0) {
      const min = Number.parseInt(minText, 10)
      rec.durationSec = Number.isNaN(min) ? 0 : Math.max(0, min * 60)
    }
    rec.status = 'manual'
    out.ok = true
    out.record = rec
    return out
  }

  static emptyDraft(): ManualTrackDraft {
    const d = new ManualTrackDraft()
    d.recordDate = DateFormatUtil.formatDate(new Date())
    return d
  }
}
