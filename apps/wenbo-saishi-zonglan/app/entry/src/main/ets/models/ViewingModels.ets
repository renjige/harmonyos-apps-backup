export class ViewingPlanMeta {
  matchIds: string[] = []
  targetCount: number = 1
  completedCount: number = 0
  startDate: string = ''
  endDate: string = ''
  note: string = ''

  static parse(raw: string): ViewingPlanMeta {
    const meta = new ViewingPlanMeta()
    if (raw.length === 0) {
      return meta
    }
    try {
      const obj = JSON.parse(raw) as Record<string, Object>
      if (obj.matchIds !== undefined && obj.matchIds !== null) {
        const ids = obj.matchIds as string[]
        for (const id of ids) {
          meta.matchIds.push(id)
        }
      }
      if (obj.targetCount !== undefined) {
        meta.targetCount = obj.targetCount as number
      }
      if (obj.completedCount !== undefined) {
        meta.completedCount = obj.completedCount as number
      }
      if (obj.startDate !== undefined) {
        meta.startDate = obj.startDate as string
      }
      if (obj.endDate !== undefined) {
        meta.endDate = obj.endDate as string
      }
      if (obj.note !== undefined) {
        meta.note = obj.note as string
      }
    } catch {
    }
    return meta
  }
}

export class ViewingPlanWire {
  id: string = ''
  title: string = ''
  sport: string = ''
  leagueName: string = ''
  status: string = ''
  body: string = ''
  summary: string = ''
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class ViewingPlanItem {
  id: string = ''
  title: string = ''
  sport: string = ''
  leagueName: string = ''
  status: string = ''
  meta: ViewingPlanMeta = new ViewingPlanMeta()
  summary: string = ''
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''

  static fromWire(w: ViewingPlanWire): ViewingPlanItem {
    const item = new ViewingPlanItem()
    item.id = w.id
    item.title = w.title ?? ''
    item.sport = w.sport ?? ''
    item.leagueName = w.leagueName ?? ''
    item.status = w.status ?? 'active'
    item.meta = ViewingPlanMeta.parse(w.body ?? '')
    item.summary = w.summary ?? ''
    item.userId = w.userId ?? ''
    item.createdAt = w.createdAt ?? ''
    item.updatedAt = w.updatedAt ?? ''
    return item
  }

  progressPercent(): number {
    if (this.meta.targetCount <= 0) {
      return 0
    }
    const pct = Math.floor((this.meta.completedCount / this.meta.targetCount) * 100)
    if (pct > 100) {
      return 100
    }
    return pct
  }

  progressLabel(): string {
    return `${this.meta.completedCount}/${this.meta.targetCount} 场`
  }
}

export class CreateViewingPlanBody {
  title: string = ''
  sport: string = ''
  leagueName: string = ''
  matchIds: string[] = []
  targetCount: number = 1
  startDate: string = ''
  endDate: string = ''
  note: string = ''
  username: string = ''

  toJsonString(): string {
    const ids: string[] = []
    for (const id of this.matchIds) {
      ids.push(id)
    }
    return JSON.stringify({
      title: this.title,
      sport: this.sport,
      leagueName: this.leagueName,
      matchIds: ids,
      targetCount: this.targetCount,
      startDate: this.startDate,
      endDate: this.endDate,
      note: this.note,
      username: this.username
    })
  }
}

export class ViewingNoteMeta {
  rating: number = 0
  tags: string[] = []
  mood: string = ''

  static parse(raw: string): ViewingNoteMeta {
    const meta = new ViewingNoteMeta()
    if (raw.length === 0) {
      return meta
    }
    try {
      const obj = JSON.parse(raw) as Record<string, Object>
      if (obj.rating !== undefined) {
        meta.rating = obj.rating as number
      }
      if (obj.tags !== undefined && obj.tags !== null) {
        const tags = obj.tags as string[]
        for (const t of tags) {
          meta.tags.push(t)
        }
      }
      if (obj.mood !== undefined) {
        meta.mood = obj.mood as string
      }
    } catch {
    }
    return meta
  }
}

export class ViewingNoteWire {
  id: string = ''
  title: string = ''
  targetId: string = ''
  targetTitle: string = ''
  body: string = ''
  remark: string = ''
  summary: string = ''
  userId: string = ''
  status: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class ViewingNoteItem {
  id: string = ''
  matchId: string = ''
  matchTitle: string = ''
  content: string = ''
  meta: ViewingNoteMeta = new ViewingNoteMeta()
  summary: string = ''
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''

  static fromWire(w: ViewingNoteWire): ViewingNoteItem {
    const item = new ViewingNoteItem()
    item.id = w.id
    item.matchId = w.targetId ?? ''
    item.matchTitle = w.targetTitle ?? w.title ?? ''
    item.content = w.body ?? ''
    item.meta = ViewingNoteMeta.parse(w.remark ?? '')
    item.summary = w.summary ?? ''
    item.userId = w.userId ?? ''
    item.createdAt = w.createdAt ?? ''
    item.updatedAt = w.updatedAt ?? ''
    return item
  }
}

export class CreateViewingNoteBody {
  matchId: string = ''
  matchTitle: string = ''
  content: string = ''
  rating: number = 0
  mood: string = ''
  username: string = ''

  toJsonString(): string {
    return JSON.stringify({
      matchId: this.matchId,
      matchTitle: this.matchTitle,
      content: this.content,
      rating: this.rating,
      mood: this.mood,
      username: this.username
    })
  }
}

export class WatchCheckinWire {
  id: string = ''
  title: string = ''
  targetId: string = ''
  targetTitle: string = ''
  startAt: string = ''
  remark: string = ''
  userId: string = ''
  status: string = ''
  createdAt: string = ''
}

export class WatchCheckinItem {
  id: string = ''
  matchId: string = ''
  matchTitle: string = ''
  watchedAt: string = ''
  planId: string = ''
  noteId: string = ''
  userId: string = ''

  static fromWire(w: WatchCheckinWire): WatchCheckinItem {
    const item = new WatchCheckinItem()
    item.id = w.id
    item.matchId = w.targetId ?? ''
    item.matchTitle = w.targetTitle ?? w.title ?? ''
    item.watchedAt = w.startAt ?? w.createdAt ?? ''
    item.userId = w.userId ?? ''
    try {
      const meta = JSON.parse(w.remark ?? '{}') as Record<string, string>
      item.planId = meta.planId ?? ''
      item.noteId = meta.noteId ?? ''
    } catch {
    }
    return item
  }
}

export class CreateWatchCheckinBody {
  matchId: string = ''
  matchTitle: string = ''
  watchedAt: string = ''
  planId: string = ''
  noteId: string = ''
  username: string = ''

  toJsonString(): string {
    return JSON.stringify({
      matchId: this.matchId,
      matchTitle: this.matchTitle,
      watchedAt: this.watchedAt,
      planId: this.planId,
      noteId: this.noteId,
      username: this.username
    })
  }
}

export class ViewingPlanListPayload {
  list: ViewingPlanWire[] = []
}

export class ViewingNoteListPayload {
  list: ViewingNoteWire[] = []
}

export class WatchCheckinListPayload {
  list: WatchCheckinWire[] = []
}

export class UserStatsPayload {
  watchedCount: number = 0
  noteCount: number = 0
  planCount: number = 0
  activePlanCount: number = 0
  favoriteCount: number = 0
  reminderCount: number = 0
  planCompletedCount: number = 0
  planTargetCount: number = 0
  watchStreakDays: number = 0
  sportBreakdown: Record<string, number> = {}
}

export class ActivityFeedWire {
  id: string = ''
  type: string = ''
  title: string = ''
  subtitle: string = ''
  targetId: string = ''
  timestamp: string = ''
}

export class ActivityFeedListPayload {
  list: ActivityFeedWire[] = []
}

export class ActivityFeedItem {
  id: string = ''
  type: string = ''
  title: string = ''
  subtitle: string = ''
  targetId: string = ''
  timestamp: string = ''

  static fromWire(w: ActivityFeedWire): ActivityFeedItem {
    const item = new ActivityFeedItem()
    item.id = w.id
    item.type = w.type ?? ''
    item.title = w.title ?? ''
    item.subtitle = w.subtitle ?? ''
    item.targetId = w.targetId ?? ''
    item.timestamp = w.timestamp ?? ''
    return item
  }

  typeLabel(): string {
    if (this.type === 'checkin') {
      return '打卡'
    }
    if (this.type === 'note') {
      return '笔记'
    }
    if (this.type === 'plan') {
      return '计划'
    }
    if (this.type === 'favorite') {
      return '关注'
    }
    if (this.type === 'reminder') {
      return '提醒'
    }
    return '动态'
  }

  timeLabel(): string {
    if (this.timestamp.length >= 16) {
      return this.timestamp.slice(0, 16).replace('T', ' ')
    }
    if (this.timestamp.length >= 10) {
      return this.timestamp.slice(0, 10)
    }
    return ''
  }
}

export class SearchResultPayload {
  matches: Object[] = []
  teams: Object[] = []
  leagues: Object[] = []
}
