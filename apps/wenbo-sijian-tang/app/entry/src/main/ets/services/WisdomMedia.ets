/** coverKey → 本机影像；一 key 一图 */

export class WisdomMedia {
  static resource(key: string): Resource {
    if (key === 'hero_today') {
      return $r('app.media.hero_today')
    }
    if (key === 'cover_wisdom' || key === 'cover_wisdom_ink') {
      return $r('app.media.cover_wisdom_ink')
    }
    if (key === 'cover_reading') {
      return $r('app.media.cover_reading')
    }
    if (key === 'cover_read_wang') {
      return $r('app.media.cover_read_wang')
    }
    if (key === 'cover_read_lao') {
      return $r('app.media.cover_read_lao')
    }
    if (key === 'cover_read_calm') {
      return $r('app.media.cover_read_calm')
    }
    if (key === 'cover_read_classic') {
      return $r('app.media.cover_read_classic')
    }
    if (key === 'cover_read_heart') {
      return $r('app.media.cover_read_heart')
    }
    if (key === 'cover_read_inspire') {
      return $r('app.media.cover_read_inspire')
    }
    if (key === 'cover_topic_daily') {
      return $r('app.media.cover_topic_daily')
    }
    if (key === 'cover_circle') {
      return $r('app.media.cover_circle')
    }
    if (key === 'cover_circle_1') {
      return $r('app.media.cover_circle_1')
    }
    if (key === 'cover_circle_2') {
      return $r('app.media.cover_circle_2')
    }
    if (key === 'cover_circle_3') {
      return $r('app.media.cover_circle_3')
    }
    if (key === 'cover_circle_4') {
      return $r('app.media.cover_circle_4')
    }
    if (key === 'cover_circle_5') {
      return $r('app.media.cover_circle_5')
    }
    if (key === 'cover_circle_6') {
      return $r('app.media.cover_circle_6')
    }
    if (key === 'cover_circle_7') {
      return $r('app.media.cover_circle_7')
    }
    if (key === 'cover_circle_8') {
      return $r('app.media.cover_circle_8')
    }
    if (key === 'cover_tag_wisdom') {
      return $r('app.media.cover_tag_wisdom')
    }
    if (key === 'avatar_friend_1') {
      return $r('app.media.avatar_friend_1')
    }
    if (key === 'avatar_friend_2') {
      return $r('app.media.avatar_friend_2')
    }
    if (key === 'avatar_friend_3') {
      return $r('app.media.avatar_friend_3')
    }
    if (key === 'avatar_friend_4') {
      return $r('app.media.avatar_friend_4')
    }
    if (key === 'avatar_friend_5') {
      return $r('app.media.avatar_friend_5')
    }
    return $r('app.media.cover_wisdom')
  }
}
