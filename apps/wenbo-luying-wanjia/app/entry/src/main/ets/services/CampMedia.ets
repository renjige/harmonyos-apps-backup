/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class CampMedia {
  static resource(key: string): Resource {
    if (key === 'hero_camp_night') {
      return $r('app.media.hero_camp_night')
    }
    if (key === 'banner_pack') {
      return $r('app.media.banner_pack')
    }
    if (key === 'camp_mogan') {
      return $r('app.media.camp_mogan')
    }
    if (key === 'camp_qinghai') {
      return $r('app.media.camp_qinghai')
    }
    if (key === 'camp_dali') {
      return $r('app.media.camp_dali')
    }
    if (key === 'camp_changbai') {
      return $r('app.media.camp_changbai')
    }
    if (key === 'camp_yangshuo') {
      return $r('app.media.camp_yangshuo')
    }
    if (key === 'camp_ejina') {
      return $r('app.media.camp_ejina')
    }
    if (key === 'camp_xiamen') {
      return $r('app.media.camp_xiamen')
    }
    if (key === 'camp_xinduqiao') {
      return $r('app.media.camp_xinduqiao')
    }
    if (key === 'guide_tent') {
      return $r('app.media.guide_tent')
    }
    if (key === 'guide_rain') {
      return $r('app.media.guide_rain')
    }
    if (key === 'guide_cook') {
      return $r('app.media.guide_cook')
    }
    if (key === 'guide_stars') {
      return $r('app.media.guide_stars')
    }
    if (key === 'guide_kids') {
      return $r('app.media.guide_kids')
    }
    if (key === 'guide_altitude') {
      return $r('app.media.guide_altitude')
    }
    if (key === 'tpl_newbie') {
      return $r('app.media.tpl_newbie')
    }
    if (key === 'tpl_ultralight') {
      return $r('app.media.tpl_ultralight')
    }
    if (key === 'tpl_family') {
      return $r('app.media.tpl_family')
    }
    return $r('app.media.hero_camp_night')
  }
}
