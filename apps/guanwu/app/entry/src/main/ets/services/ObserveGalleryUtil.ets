import { ObserveRecord } from '../models/ObserveModels'
import { DateHelper } from './DateHelper'

export class GalleryCell {
  recordId: string = ''
  path: string = ''
  label: string = ''
}

export class ObserveGalleryUtil {
  static buildCells(records: ObserveRecord[]): GalleryCell[] {
    const out: GalleryCell[] = []
    for (const r of records) {
      for (const p of r.imagePaths) {
        if (p.length === 0) {
          continue
        }
        const c = new GalleryCell()
        c.recordId = r.id
        c.path = p
        c.label = `${DateHelper.displayDate(r.dateKey)} · ${r.itemName.length > 0 ? r.itemName : r.kindLabel()}`
        out.push(c)
      }
    }
    return out
  }
}
