/** 自然探索志 — 本地探索记录模型 */

export class ExploreRecord {
  id: string = ''
  title: string = ''
  location: string = ''
  date: string = ''
  weather: string = ''
  body: string = ''
  photoPaths: string = ''
  lat: number = 0
  lng: number = 0
  createdAt: number = 0

  static createNew(): ExploreRecord {
    const r = new ExploreRecord()
    r.id = `rec_${Date.now()}`
    r.createdAt = Date.now()
    const d = new Date()
    r.date = `${d.getFullYear()}-${ExploreRecord.pad2(d.getMonth() + 1)}-${ExploreRecord.pad2(d.getDate())}`
    return r
  }

  private static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  photoList(): string[] {
    const out: string[] = []
    if (this.photoPaths.length === 0) {
      return out
    }
    const parts = this.photoPaths.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }
}

export class ExploreStats {
  recordCount: number = 0
  locationCount: number = 0
  mileageKm: number = 0
}
