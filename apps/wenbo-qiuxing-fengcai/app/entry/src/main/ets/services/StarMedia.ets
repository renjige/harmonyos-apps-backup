/** coverKey → app.media 资源；一 key 一图 */
export class StarMedia {
  static coverMedia(key: string): Resource {
    if (key === 'hero_sports_discovery') {
      return $r('app.media.hero_sports_discovery')
    }
    if (key === 'athlete_football_1') {
      return $r('app.media.athlete_football_1')
    }
    if (key === 'athlete_football_2') {
      return $r('app.media.athlete_football_2')
    }
    if (key === 'athlete_football_3') {
      return $r('app.media.athlete_football_3')
    }
    if (key === 'athlete_basketball_1') {
      return $r('app.media.athlete_basketball_1')
    }
    if (key === 'athlete_basketball_2') {
      return $r('app.media.athlete_basketball_2')
    }
    if (key === 'athlete_basketball_3') {
      return $r('app.media.athlete_basketball_3')
    }
    if (key === 'athlete_tennis_1') {
      return $r('app.media.athlete_tennis_1')
    }
    if (key === 'athlete_tennis_2') {
      return $r('app.media.athlete_tennis_2')
    }
    if (key === 'athlete_racing_1') {
      return $r('app.media.athlete_racing_1')
    }
    if (key === 'athlete_racing_2') {
      return $r('app.media.athlete_racing_2')
    }
    if (key === 'athlete_other_1') {
      return $r('app.media.athlete_other_1')
    }
    if (key === 'athlete_other_2') {
      return $r('app.media.athlete_other_2')
    }
    if (key === 'event_football_1') {
      return $r('app.media.event_football_1')
    }
    if (key === 'event_football_2' || key === 'event_football_3') {
      return $r('app.media.event_football_1')
    }
    if (key === 'event_basketball_1') {
      return $r('app.media.event_basketball_1')
    }
    if (key === 'event_basketball_2' || key === 'event_basketball_3') {
      return $r('app.media.event_basketball_1')
    }
    if (key === 'event_tennis_1') {
      return $r('app.media.event_tennis_1')
    }
    if (key === 'event_tennis_2') {
      return $r('app.media.event_tennis_1')
    }
    if (key === 'event_racing_1') {
      return $r('app.media.event_racing_1')
    }
    if (key === 'event_other_1') {
      return $r('app.media.event_other_1')
    }
    if (key === 'cat_football') {
      return $r('app.media.athlete_football_1')
    }
    if (key === 'cat_basketball') {
      return $r('app.media.athlete_basketball_1')
    }
    if (key === 'cat_tennis') {
      return $r('app.media.athlete_tennis_1')
    }
    if (key === 'cat_racing') {
      return $r('app.media.athlete_racing_1')
    }
    return $r('app.media.hero_sports_discovery')
  }
}
