import { MicroEssay } from '../models/EssayModels'
import { ObserveBadge, ObserveTheme } from '../models/GrowthModels'
import { SenseCardService } from './SenseCardService'

export class BadgeService {
  static mergeCatalog(saved: ObserveBadge[]): ObserveBadge[] {
    const catalog = ObserveBadge.catalog()
    for (const c of catalog) {
      for (const s of saved) {
        if (s.id === c.id && s.unlockedAt > 0) {
          c.unlockedAt = s.unlockedAt
        }
      }
    }
    return catalog
  }

  static newlyUnlocked(list: MicroEssay[], themes: ObserveTheme[], streak: number,
    previous: ObserveBadge[]): ObserveBadge[] {
    const merged = BadgeService.mergeCatalog(previous)
    const now = Date.now()
    const fresh: ObserveBadge[] = []
    for (const b of merged) {
      if (b.unlockedAt > 0) {
        continue
      }
      if (BadgeService.met(b.id, list, themes, streak)) {
        b.unlockedAt = now
        fresh.push(b)
      }
    }
    return fresh
  }

  static applyUnlocks(merged: ObserveBadge[], fresh: ObserveBadge[]): ObserveBadge[] {
    for (const f of fresh) {
      for (const m of merged) {
        if (m.id === f.id) {
          m.unlockedAt = f.unlockedAt
        }
      }
    }
    return merged
  }

  private static met(id: string, list: MicroEssay[], themes: ObserveTheme[], streak: number): boolean {
    if (id === 'first_card') {
      return BadgeService.hasCard(list)
    }
    if (id === 'first_contrast') {
      return BadgeService.hasContrast(list)
    }
    if (id === 'streak_7') {
      return streak >= 7
    }
    if (id === 'fav_10') {
      return BadgeService.favCount(list) >= 10
    }
    if (id === 'theme_done') {
      return BadgeService.hasDoneTheme(themes)
    }
    if (id === 'all_senses') {
      return BadgeService.hasAllSenses(list)
    }
    return false
  }

  private static hasCard(list: MicroEssay[]): boolean {
    for (const it of list) {
      if (it.kind === 'card' || SenseCardService.looksLikeCard(it.body)) {
        return true
      }
    }
    return false
  }

  private static hasContrast(list: MicroEssay[]): boolean {
    for (const it of list) {
      if (it.kind === 'contrast' || it.tagsCsv.indexOf('对照') >= 0) {
        return true
      }
    }
    return false
  }

  private static favCount(list: MicroEssay[]): number {
    let n = 0
    for (const it of list) {
      if (it.favorite) {
        n++
      }
    }
    return n
  }

  private static hasDoneTheme(themes: ObserveTheme[]): boolean {
    for (const t of themes) {
      if (t.status === 'done') {
        return true
      }
    }
    return false
  }

  private static hasAllSenses(list: MicroEssay[]): boolean {
    const need: string[] = ['light', 'sound', 'scent', 'touch', 'color', 'people', 'space']
    for (const key of need) {
      let hit = false
      for (const it of list) {
        if (it.senseKey === key) {
          hit = true
          break
        }
      }
      if (!hit) {
        return false
      }
    }
    return true
  }
}
