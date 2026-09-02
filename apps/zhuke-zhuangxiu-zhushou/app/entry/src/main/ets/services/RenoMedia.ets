export class RenoMedia {
  static cover(key: string): Resource {
    if (key === 'sug_demolish') {
      return $r('app.media.sug_demolish')
    }
    if (key === 'sug_masonry') {
      return $r('app.media.sug_masonry')
    }
    if (key === 'sug_hydro_layout') {
      return $r('app.media.sug_hydro_layout')
    }
    if (key === 'sug_outlet') {
      return $r('app.media.sug_outlet')
    }
    if (key === 'sug_pressure') {
      return $r('app.media.sug_pressure')
    }
    if (key === 'sug_circuit') {
      return $r('app.media.sug_circuit')
    }
    if (key === 'sug_weak') {
      return $r('app.media.sug_weak')
    }
    if (key === 'sug_waterproof') {
      return $r('app.media.sug_waterproof')
    }
    if (key === 'sug_tile') {
      return $r('app.media.sug_tile')
    }
    if (key === 'sug_drain') {
      return $r('app.media.sug_drain')
    }
    if (key === 'sug_ceiling') {
      return $r('app.media.sug_ceiling')
    }
    if (key === 'sug_putty') {
      return $r('app.media.sug_putty')
    }
    if (key === 'sug_primer') {
      return $r('app.media.sug_primer')
    }
    if (key === 'sug_paint') {
      return $r('app.media.sug_paint')
    }
    if (key === 'sug_wall_look') {
      return $r('app.media.sug_wall_look')
    }
    if (key === 'sug_sanitary') {
      return $r('app.media.sug_sanitary')
    }
    if (key === 'sug_switch') {
      return $r('app.media.sug_switch')
    }
    if (key === 'sug_cabinet') {
      return $r('app.media.sug_cabinet')
    }
    if (key === 'sug_accept_hydro') {
      return $r('app.media.sug_accept_hydro')
    }
    if (key === 'sug_accept_water') {
      return $r('app.media.sug_accept_water')
    }
    if (key === 'sug_accept_wood') {
      return $r('app.media.sug_accept_wood')
    }
    if (key === 'sug_accept_paint') {
      return $r('app.media.sug_accept_paint')
    }
    if (key === 'stage_demo') {
      return $r('app.media.stage_demo')
    }
    if (key === 'stage_hydro') {
      return $r('app.media.stage_hydro')
    }
    if (key === 'stage_wood') {
      return $r('app.media.stage_wood')
    }
    if (key === 'stage_paint') {
      return $r('app.media.stage_paint')
    }
    if (key === 'stage_install') {
      return $r('app.media.stage_install')
    }
    if (key === 'stage_accept') {
      return $r('app.media.stage_accept')
    }
    if (key === 'empty_idle') {
      return $r('app.media.empty_idle')
    }
    return $r('app.media.home_hero')
  }

  static coverKeyForSuggestion(id: string, coverKey: string): string {
    if (id === 'ra_sug_1') {
      return 'sug_demolish'
    }
    if (id === 'ra_sug_2') {
      return 'sug_masonry'
    }
    if (id === 'ra_sug_3') {
      return 'sug_hydro_layout'
    }
    if (id === 'ra_sug_4') {
      return 'sug_outlet'
    }
    if (id === 'ra_sug_5') {
      return 'sug_pressure'
    }
    if (id === 'ra_sug_6') {
      return 'sug_circuit'
    }
    if (id === 'ra_sug_7') {
      return 'sug_weak'
    }
    if (id === 'ra_sug_8') {
      return 'sug_waterproof'
    }
    if (id === 'ra_sug_9') {
      return 'sug_tile'
    }
    if (id === 'ra_sug_10') {
      return 'sug_drain'
    }
    if (id === 'ra_sug_11') {
      return 'sug_ceiling'
    }
    if (id === 'ra_sug_12') {
      return 'sug_putty'
    }
    if (id === 'ra_sug_13') {
      return 'sug_primer'
    }
    if (id === 'ra_sug_14') {
      return 'sug_paint'
    }
    if (id === 'ra_sug_15') {
      return 'sug_wall_look'
    }
    if (id === 'ra_sug_16') {
      return 'sug_sanitary'
    }
    if (id === 'ra_sug_17') {
      return 'sug_switch'
    }
    if (id === 'ra_sug_18') {
      return 'sug_cabinet'
    }
    if (id === 'ra_sug_19') {
      return 'sug_accept_hydro'
    }
    if (id === 'ra_sug_20') {
      return 'sug_accept_water'
    }
    if (id === 'ra_sug_21') {
      return 'sug_accept_wood'
    }
    if (id === 'ra_sug_22') {
      return 'sug_accept_paint'
    }
    if (coverKey.length > 0) {
      return coverKey
    }
    return 'home_hero'
  }
}
