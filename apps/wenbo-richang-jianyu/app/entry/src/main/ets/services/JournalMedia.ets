/** coverKey → app.media 资源；一 key 一图 */
export class JournalMedia {
  static coverMedia(key: string): Resource {
    if (key === 'hero_morning_coffee') {
      return $r('app.media.hero_morning_coffee')
    }
    if (key === 'hero_rain_walk') {
      return $r('app.media.hero_rain_walk')
    }
    if (key === 'hero_kitchen') {
      return $r('app.media.hero_kitchen')
    }
    if (key === 'hero_bookstore') {
      return $r('app.media.hero_bookstore')
    }
    if (key === 'hero_plants') {
      return $r('app.media.hero_plants')
    }
    if (key === 'hero_postcard') {
      return $r('app.media.hero_postcard')
    }
    if (key === 'album_season_table') {
      return $r('app.media.album_season_table')
    }
    if (key === 'album_city_walk') {
      return $r('app.media.album_city_walk')
    }
    if (key === 'album_nature') {
      return $r('app.media.album_nature')
    }
    if (key === 'album_scrapbook') {
      return $r('app.media.album_scrapbook')
    }
    if (key === 'album_default') {
      return $r('app.media.album_default')
    }
    return $r('app.media.hero_morning_coffee')
  }
}
