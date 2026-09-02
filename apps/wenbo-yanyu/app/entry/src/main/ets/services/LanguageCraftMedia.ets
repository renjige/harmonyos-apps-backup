/** 每个 coverMedia key 映射独立 media 资源，禁止共图。 */
export class LanguageCraftMedia {
  static cover(key: string): Resource {
    if (key === 'cover_meeting') {
      return $r('app.media.cover_meeting')
    }
    if (key === 'cover_email') {
      return $r('app.media.cover_email')
    }
    if (key === 'cover_workplace') {
      return $r('app.media.cover_workplace')
    }
    if (key === 'cover_academic') {
      return $r('app.media.cover_academic')
    }
    if (key === 'cover_essay') {
      return $r('app.media.cover_essay')
    }
    if (key === 'cover_library') {
      return $r('app.media.cover_library')
    }
    if (key === 'cover_daily') {
      return $r('app.media.cover_daily')
    }
    if (key === 'cover_cafe') {
      return $r('app.media.cover_cafe')
    }
    if (key === 'cover_letter') {
      return $r('app.media.cover_letter')
    }
    if (key === 'cover_creative') {
      return $r('app.media.cover_creative')
    }
    if (key === 'cover_copy') {
      return $r('app.media.cover_copy')
    }
    if (key === 'cover_story') {
      return $r('app.media.cover_story')
    }
    if (key === 'hero_desk') {
      return $r('app.media.hero_desk')
    }
    if (key === 'banner_polish') {
      return $r('app.media.banner_polish')
    }
    if (key === 'banner_summary') {
      return $r('app.media.banner_summary')
    }
    return $r('app.media.cover_daily')
  }
}
