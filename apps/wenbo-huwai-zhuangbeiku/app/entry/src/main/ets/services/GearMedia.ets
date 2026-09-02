/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class GearMedia {
  static resource(key: string): Resource {
    if (key === 'hero_ridge') {
      return $r('app.media.hero_ridge')
    }
    if (key === 'banner_ledger') {
      return $r('app.media.banner_ledger')
    }
    if (key === 'banner_ready') {
      return $r('app.media.banner_ready')
    }
    if (key === 'cat_camp') {
      return $r('app.media.cat_camp')
    }
    if (key === 'cat_hike') {
      return $r('app.media.cat_hike')
    }
    if (key === 'cat_climb') {
      return $r('app.media.cat_climb')
    }
    if (key === 'cat_water') {
      return $r('app.media.cat_water')
    }
    if (key === 'gear_tent') {
      return $r('app.media.gear_tent')
    }
    if (key === 'gear_sleepbag') {
      return $r('app.media.gear_sleepbag')
    }
    if (key === 'gear_pack') {
      return $r('app.media.gear_pack')
    }
    if (key === 'gear_pole') {
      return $r('app.media.gear_pole')
    }
    if (key === 'gear_lamp') {
      return $r('app.media.gear_lamp')
    }
    if (key === 'gear_harness') {
      return $r('app.media.gear_harness')
    }
    if (key === 'gear_helm') {
      return $r('app.media.gear_helm')
    }
    if (key === 'gear_pfd') {
      return $r('app.media.gear_pfd')
    }
    if (key === 'trail_wugong') {
      return $r('app.media.trail_wugong')
    }
    if (key === 'trail_siguniang') {
      return $r('app.media.trail_siguniang')
    }
    if (key === 'trail_huangshan') {
      return $r('app.media.trail_huangshan')
    }
    if (key === 'trail_nanling') {
      return $r('app.media.trail_nanling')
    }
    if (key === 'trail_taibai') {
      return $r('app.media.trail_taibai')
    }
    if (key === 'trail_yangshuo') {
      return $r('app.media.trail_yangshuo')
    }
    if (key === 'note_weight') {
      return $r('app.media.note_weight')
    }
    if (key === 'note_ready') {
      return $r('app.media.note_ready')
    }
    if (key === 'note_condition') {
      return $r('app.media.note_condition')
    }
    if (key === 'note_ridge') {
      return $r('app.media.note_ridge')
    }
    if (key === 'note_water') {
      return $r('app.media.note_water')
    }
    if (key === 'note_lamp') {
      return $r('app.media.note_lamp')
    }
    return $r('app.media.hero_ridge')
  }
}
