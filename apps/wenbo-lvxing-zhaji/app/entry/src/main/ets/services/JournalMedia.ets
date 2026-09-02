/** coverKey → app.media 资源；一 key 一图；本地沙箱路径走 file:// */
import { ImagePathUtil } from './ImagePathUtil'

export class JournalMedia {
  static isLocalKey(key: string): boolean {
    return key.startsWith('file://') || key.startsWith('datashare://') ||
      key.startsWith('content://') || key.startsWith('/')
  }

  static resolveImage(key: string): Resource | string {
    if (JournalMedia.isLocalKey(key)) {
      return ImagePathUtil.toDisplayUri(key)
    }
    return JournalMedia.coverMedia(key)
  }

  static coverMedia(key: string): Resource {
    if (key === 'hero_mountain_lake') {
      return $r('app.media.hero_mountain_lake')
    }
    if (key === 'hero_coastal_sunset') {
      return $r('app.media.hero_coastal_sunset')
    }
    if (key === 'hero_ancient_city') {
      return $r('app.media.hero_ancient_city')
    }
    if (key === 'hero_forest_path') {
      return $r('app.media.hero_forest_path')
    }
    if (key === 'hero_snow_mountain') {
      return $r('app.media.hero_snow_mountain')
    }
    if (key === 'hero_desert_dunes') {
      return $r('app.media.hero_desert_dunes')
    }
    if (key === 'hero_travel_home') {
      return $r('app.media.hero_travel_home')
    }
    if (key === 'album_sakura_temple') {
      return $r('app.media.album_sakura_temple')
    }
    if (key === 'album_mediterranean') {
      return $r('app.media.album_mediterranean')
    }
    if (key === 'album_aurora') {
      return $r('app.media.album_aurora')
    }
    if (key === 'album_tropical_island') {
      return $r('app.media.album_tropical_island')
    }
    if (key === 'album_default') {
      return $r('app.media.album_default')
    }
    return $r('app.media.hero_travel_home')
  }

  /** 精选相册无 imageKeys 时，用封面对应的一组旅行图展示网格 */
  static showcasePhotos(coverKey: string): string[] {
    if (coverKey === 'album_sakura_temple') {
      return ['album_sakura_temple', 'hero_ancient_city', 'hero_forest_path']
    }
    if (coverKey === 'album_mediterranean') {
      return ['album_mediterranean', 'hero_coastal_sunset', 'album_tropical_island']
    }
    if (coverKey === 'album_aurora') {
      return ['album_aurora', 'hero_snow_mountain', 'hero_mountain_lake']
    }
    if (coverKey === 'album_tropical_island') {
      return ['album_tropical_island', 'hero_coastal_sunset', 'hero_desert_dunes']
    }
    if (coverKey.length > 0) {
      return [coverKey]
    }
    return []
  }
}
