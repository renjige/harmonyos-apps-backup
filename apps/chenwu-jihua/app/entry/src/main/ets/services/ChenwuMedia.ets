export class ChenwuMedia {
  static heroMistDawn(): Resource {
    return $r('app.media.hero_mist_dawn')
  }

  static bannerPlanPath(): Resource {
    return $r('app.media.banner_plan_path')
  }

  static ambientJournal(): Resource {
    return $r('app.media.ambient_journal')
  }

  static coverGoalLearn(): Resource {
    return $r('app.media.cover_goal_learn')
  }

  static coverGoalLife(): Resource {
    return $r('app.media.cover_goal_life')
  }

  static coverGoalHealth(): Resource {
    return $r('app.media.cover_goal_health')
  }

  static coverGoalHobby(): Resource {
    return $r('app.media.cover_goal_hobby')
  }

  static coverGoalWork(): Resource {
    return $r('app.media.cover_goal_work')
  }

  static coverReview(): Resource {
    return $r('app.media.cover_review')
  }

  static coverOf(key: string): Resource {
    if (key === 'hero_mist_dawn') {
      return ChenwuMedia.heroMistDawn()
    }
    if (key === 'banner_plan_path') {
      return ChenwuMedia.bannerPlanPath()
    }
    if (key === 'ambient_journal') {
      return ChenwuMedia.ambientJournal()
    }
    if (key === 'cover_goal_learn') {
      return ChenwuMedia.coverGoalLearn()
    }
    if (key === 'cover_goal_life') {
      return ChenwuMedia.coverGoalLife()
    }
    if (key === 'cover_goal_health') {
      return ChenwuMedia.coverGoalHealth()
    }
    if (key === 'cover_goal_hobby') {
      return ChenwuMedia.coverGoalHobby()
    }
    if (key === 'cover_goal_work') {
      return ChenwuMedia.coverGoalWork()
    }
    if (key === 'cover_review') {
      return ChenwuMedia.coverReview()
    }
    return ChenwuMedia.heroMistDawn()
  }
}
