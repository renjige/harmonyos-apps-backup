/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class MxMedia {
  static resource(key: string): Resource {
    if (key === 'hero_ridge_compass') {
      return $r('app.media.hero_ridge_compass')
    }
    if (key === 'trail_ridge_dawn') {
      return $r('app.media.trail_ridge_dawn')
    }
    if (key === 'trail_highland_meadow') {
      return $r('app.media.trail_highland_meadow')
    }
    if (key === 'trail_stone_steps') {
      return $r('app.media.trail_stone_steps')
    }
    if (key === 'trail_bamboo_gorge') {
      return $r('app.media.trail_bamboo_gorge')
    }
    if (key === 'trail_ridge_loop') {
      return $r('app.media.trail_ridge_loop')
    }
    if (key === 'trail_coastal_ridge') {
      return $r('app.media.trail_coastal_ridge')
    }
    if (key === 'trail_valley_bike') {
      return $r('app.media.trail_valley_bike')
    }
    if (key === 'trail_forest_creek') {
      return $r('app.media.trail_forest_creek')
    }
    if (key === 'tip_layer_clothing') {
      return $r('app.media.tip_layer_clothing')
    }
    if (key === 'tip_leave_no_trace') {
      return $r('app.media.tip_leave_no_trace')
    }
    if (key === 'tip_water_filter') {
      return $r('app.media.tip_water_filter')
    }
    if (key === 'tip_weather_window') {
      return $r('app.media.tip_weather_window')
    }
    if (key === 'tip_night_sky') {
      return $r('app.media.tip_night_sky')
    }
    if (key === 'wiki_pine_needle') {
      return $r('app.media.wiki_pine_needle')
    }
    if (key === 'wiki_moss_bamboo') {
      return $r('app.media.wiki_moss_bamboo')
    }
    if (key === 'wiki_alpine_flower') {
      return $r('app.media.wiki_alpine_flower')
    }
    if (key === 'wiki_red_fox') {
      return $r('app.media.wiki_red_fox')
    }
    if (key === 'wiki_woodpecker') {
      return $r('app.media.wiki_woodpecker')
    }
    if (key === 'wiki_macaque') {
      return $r('app.media.wiki_macaque')
    }
    if (key === 'wiki_granite_fold') {
      return $r('app.media.wiki_granite_fold')
    }
    if (key === 'wiki_quartz_sandstone') {
      return $r('app.media.wiki_quartz_sandstone')
    }
    if (key === 'wiki_danxia_bed') {
      return $r('app.media.wiki_danxia_bed')
    }
    if (key === 'wiki_glacial_erratic') {
      return $r('app.media.wiki_glacial_erratic')
    }
    if (key === 'wiki_orographic_cloud') {
      return $r('app.media.wiki_orographic_cloud')
    }
    if (key === 'wiki_polaris') {
      return $r('app.media.wiki_polaris')
    }
    if (key === 'wiki_orion') {
      return $r('app.media.wiki_orion')
    }
    if (key === 'wiki_milky_way') {
      return $r('app.media.wiki_milky_way')
    }
    return $r('app.media.hero_ridge_compass')
  }
}
