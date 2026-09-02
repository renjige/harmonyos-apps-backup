/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class NqMedia {
  static resource(key: string): Resource {
    if (key === 'hero_forest_path') {
      return $r('app.media.hero_forest_path')
    }
    if (key === 'banner_season_leaf') {
      return $r('app.media.banner_season_leaf')
    }
    if (key === 'banner_stargazing') {
      return $r('app.media.banner_stargazing')
    }
    if (key === 'cat_forest') {
      return $r('app.media.cat_forest')
    }
    if (key === 'cat_mountain') {
      return $r('app.media.cat_mountain')
    }
    if (key === 'cat_lake') {
      return $r('app.media.cat_lake')
    }
    if (key === 'cat_star') {
      return $r('app.media.cat_star')
    }
    if (key === 'cat_park') {
      return $r('app.media.cat_park')
    }
    if (key === 'spot_wetland') {
      return $r('app.media.spot_wetland')
    }
    if (key === 'spot_ridge') {
      return $r('app.media.spot_ridge')
    }
    if (key === 'wiki_oak') {
      return $r('app.media.wiki_oak')
    }
    if (key === 'wiki_heron') {
      return $r('app.media.wiki_heron')
    }
    if (key === 'empty_trail') {
      return $r('app.media.empty_trail')
    }
    if (key === 'hero_ridge_compass') {
      return $r('app.media.hero_forest_path')
    }
    if (key === 'trail_ridge_dawn') {
      return $r('app.media.spot_ridge')
    }
    if (key === 'trail_highland_meadow') {
      return $r('app.media.cat_mountain')
    }
    if (key === 'trail_stone_steps') {
      return $r('app.media.cat_mountain')
    }
    if (key === 'trail_bamboo_gorge') {
      return $r('app.media.cat_forest')
    }
    if (key === 'trail_ridge_loop') {
      return $r('app.media.spot_ridge')
    }
    if (key === 'trail_coastal_ridge') {
      return $r('app.media.cat_mountain')
    }
    if (key === 'trail_valley_bike') {
      return $r('app.media.cat_park')
    }
    if (key === 'trail_forest_creek') {
      return $r('app.media.cat_lake')
    }
    if (key === 'tip_layer_clothing') {
      return $r('app.media.banner_season_leaf')
    }
    if (key === 'tip_leave_no_trace') {
      return $r('app.media.cat_forest')
    }
    if (key === 'tip_water_filter') {
      return $r('app.media.cat_lake')
    }
    if (key === 'tip_weather_window') {
      return $r('app.media.banner_season_leaf')
    }
    if (key === 'tip_night_sky') {
      return $r('app.media.banner_stargazing')
    }
    if (key === 'wiki_pine_needle') {
      return $r('app.media.wiki_oak')
    }
    if (key === 'wiki_moss_bamboo') {
      return $r('app.media.cat_forest')
    }
    if (key === 'wiki_alpine_flower') {
      return $r('app.media.wiki_oak')
    }
    if (key === 'wiki_red_fox') {
      return $r('app.media.wiki_heron')
    }
    if (key === 'wiki_woodpecker') {
      return $r('app.media.wiki_heron')
    }
    if (key === 'wiki_macaque') {
      return $r('app.media.wiki_heron')
    }
    if (key === 'wiki_granite_fold') {
      return $r('app.media.cat_mountain')
    }
    if (key === 'wiki_quartz_sandstone') {
      return $r('app.media.cat_mountain')
    }
    if (key === 'wiki_danxia_bed') {
      return $r('app.media.cat_mountain')
    }
    if (key === 'wiki_glacial_erratic') {
      return $r('app.media.cat_mountain')
    }
    if (key === 'wiki_orographic_cloud') {
      return $r('app.media.banner_stargazing')
    }
    if (key === 'wiki_polaris') {
      return $r('app.media.banner_stargazing')
    }
    if (key === 'wiki_orion') {
      return $r('app.media.banner_stargazing')
    }
    if (key === 'wiki_milky_way') {
      return $r('app.media.banner_stargazing')
    }
    return $r('app.media.hero_forest_path')
  }

  static categoryCover(cat: string): Resource {
    if (cat === 'forest') {
      return NqMedia.resource('cat_forest')
    }
    if (cat === 'lake') {
      return NqMedia.resource('cat_lake')
    }
    if (cat === 'star') {
      return NqMedia.resource('cat_star')
    }
    if (cat === 'park') {
      return NqMedia.resource('cat_park')
    }
    return NqMedia.resource('cat_mountain')
  }
}
