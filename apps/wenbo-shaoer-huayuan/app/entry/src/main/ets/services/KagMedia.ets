export class KagMedia {
  static cover(key: string): Resource {
    if (key === 'hero_gallery') {
      return $r('app.media.hero_gallery')
    }
    if (key === 'banner_timeline') {
      return $r('app.media.banner_timeline')
    }
    if (key === 'banner_share') {
      return $r('app.media.banner_share')
    }
    if (key === 'theme_watercolor') {
      return $r('app.media.theme_watercolor')
    }
    if (key === 'theme_doodle') {
      return $r('app.media.theme_doodle')
    }
    if (key === 'theme_family') {
      return $r('app.media.theme_family')
    }
    if (key === 'theme_portrait') {
      return $r('app.media.theme_portrait')
    }
    if (key === 'theme_season') {
      return $r('app.media.theme_season')
    }
    if (key === 'theme_animals') {
      return $r('app.media.theme_animals')
    }
    if (key === 'hall_warm') {
      return $r('app.media.hall_warm')
    }
    if (key === 'hall_white') {
      return $r('app.media.hall_white')
    }
    if (key === 'hall_window') {
      return $r('app.media.hall_window')
    }
    if (key === 'hall_night') {
      return $r('app.media.hall_night')
    }
    if (key === 'ms_grip') {
      return $r('app.media.ms_grip')
    }
    if (key === 'ms_circle') {
      return $r('app.media.ms_circle')
    }
    if (key === 'ms_person') {
      return $r('app.media.ms_person')
    }
    if (key === 'ms_watercolor') {
      return $r('app.media.ms_watercolor')
    }
    if (key === 'ms_sign') {
      return $r('app.media.ms_sign')
    }
    if (key === 'ms_story') {
      return $r('app.media.ms_story')
    }
    if (key === 'guide_photo') {
      return $r('app.media.guide_photo')
    }
    if (key === 'guide_story') {
      return $r('app.media.guide_story')
    }
    if (key === 'guide_album') {
      return $r('app.media.guide_album')
    }
    if (key === 'guide_exhibit') {
      return $r('app.media.guide_exhibit')
    }
    if (key === 'guide_siblings') {
      return $r('app.media.guide_siblings')
    }
    return $r('app.media.empty_easel')
  }
}
