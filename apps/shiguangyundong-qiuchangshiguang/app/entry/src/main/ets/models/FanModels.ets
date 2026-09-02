/** 球迷本机记录（无系统权限、不拉实时赛程接口） */
export class FanKind {
  static readonly MATCH: string = 'match'
  static readonly JOURNAL: string = 'journal'
  static readonly TEAM: string = 'team'
  static readonly REVIEW: string = 'review'
  static readonly HIGHLIGHT: string = 'highlight'
  static readonly WATCHLIST: string = 'watchlist'
  static readonly PLAYER: string = 'player'
  static readonly KNOWLEDGE: string = 'knowledge'
  static readonly CHALLENGE: string = 'challenge'
  static readonly EVENT: string = 'event'
  static readonly ALBUM: string = 'album'

  static all(): string[] {
    return [
      FanKind.MATCH, FanKind.JOURNAL, FanKind.TEAM, FanKind.REVIEW,
      FanKind.HIGHLIGHT, FanKind.WATCHLIST, FanKind.PLAYER, FanKind.KNOWLEDGE,
      FanKind.CHALLENGE, FanKind.EVENT, FanKind.ALBUM
    ]
  }

  static primary(): string[] {
    return [FanKind.MATCH, FanKind.JOURNAL, FanKind.TEAM, FanKind.REVIEW, FanKind.HIGHLIGHT]
  }

  static tools(): string[] {
    return [FanKind.WATCHLIST, FanKind.PLAYER, FanKind.KNOWLEDGE, FanKind.EVENT, FanKind.ALBUM, FanKind.CHALLENGE]
  }

  static titleOf(kind: string): string {
    if (kind === FanKind.MATCH) {
      return '观赛记录'
    }
    if (kind === FanKind.JOURNAL) {
      return '球迷日志'
    }
    if (kind === FanKind.TEAM) {
      return '球队收藏'
    }
    if (kind === FanKind.REVIEW) {
      return '复盘笔记'
    }
    if (kind === FanKind.HIGHLIGHT) {
      return '精彩瞬间'
    }
    if (kind === FanKind.WATCHLIST) {
      return '比赛清单'
    }
    if (kind === FanKind.PLAYER) {
      return '球员档案'
    }
    if (kind === FanKind.KNOWLEDGE) {
      return '球场知识'
    }
    if (kind === FanKind.CHALLENGE) {
      return '球迷挑战'
    }
    if (kind === FanKind.EVENT) {
      return '赛事日历'
    }
    if (kind === FanKind.ALBUM) {
      return '体育收藏册'
    }
    return '球迷拾光'
  }

  static hintOf(kind: string): string {
    if (kind === FanKind.MATCH) {
      return '比赛名称、日期与观赛心得'
    }
    if (kind === FanKind.JOURNAL) {
      return '看球感受、分析与球迷故事'
    }
    if (kind === FanKind.TEAM) {
      return '喜欢 / 关注 / 经典球队备注'
    }
    if (kind === FanKind.REVIEW) {
      return '过程、战术观察与个人评价'
    }
    if (kind === FanKind.HIGHLIGHT) {
      return '绝杀、逆转等文字回忆'
    }
    if (kind === FanKind.WATCHLIST) {
      return '待观看 / 已观看 / 已收藏'
    }
    if (kind === FanKind.PLAYER) {
      return '特点、表现与关注原因'
    }
    if (kind === FanKind.KNOWLEDGE) {
      return '规则、球队历史与球员故事'
    }
    if (kind === FanKind.CHALLENGE) {
      return '自订任务，勾选完成'
    }
    if (kind === FanKind.EVENT) {
      return '手动添加关注赛事日期与观赛计划'
    }
    if (kind === FanKind.ALBUM) {
      return '世界杯记忆、经典决赛等专题合集'
    }
    return '球迷拾光'
  }

  static coverOf(kind: string): string {
    if (kind === FanKind.MATCH) {
      return 'banner_today'
    }
    if (kind === FanKind.JOURNAL) {
      return 'hero_court'
    }
    if (kind === FanKind.TEAM) {
      return 'cat_basketball'
    }
    if (kind === FanKind.REVIEW) {
      return 'banner_hot'
    }
    if (kind === FanKind.HIGHLIGHT) {
      return 'venue_basketball_01'
    }
    if (kind === FanKind.WATCHLIST) {
      return 'cat_football'
    }
    if (kind === FanKind.PLAYER) {
      return 'venue_tennis_01'
    }
    if (kind === FanKind.KNOWLEDGE) {
      return 'cat_badminton'
    }
    if (kind === FanKind.EVENT) {
      return 'cat_tennis'
    }
    if (kind === FanKind.ALBUM) {
      return 'case_weekend'
    }
    return 'venue_mixed_01'
  }

  static titlePlaceholder(kind: string): string {
    if (kind === FanKind.MATCH) {
      return '例如：世界杯决赛 / 德比战'
    }
    if (kind === FanKind.JOURNAL) {
      return '例如：今晚看台随笔'
    }
    if (kind === FanKind.TEAM) {
      return '球队名称'
    }
    if (kind === FanKind.REVIEW) {
      return '复盘哪一场'
    }
    if (kind === FanKind.HIGHLIGHT) {
      return '例如：最后一分钟绝杀'
    }
    if (kind === FanKind.WATCHLIST) {
      return '赛事名称'
    }
    if (kind === FanKind.PLAYER) {
      return '球员姓名'
    }
    if (kind === FanKind.KNOWLEDGE) {
      return '知识点标题'
    }
    if (kind === FanKind.EVENT) {
      return '例如：周日晚德比 / 半决赛'
    }
    if (kind === FanKind.ALBUM) {
      return '例如：我的世界杯记忆'
    }
    return '挑战名称'
  }

  static bodyPlaceholder(kind: string): string {
    if (kind === FanKind.MATCH) {
      return '比赛信息、精彩瞬间与个人评价'
    }
    if (kind === FanKind.JOURNAL) {
      return '看球感受、比赛分析或球迷故事'
    }
    if (kind === FanKind.TEAM) {
      return '关注原因、队史印象或备注'
    }
    if (kind === FanKind.REVIEW) {
      return '比赛过程、战术观察、个人评价'
    }
    if (kind === FanKind.HIGHLIGHT) {
      return '用文字记下那个瞬间'
    }
    if (kind === FanKind.WATCHLIST) {
      return '为什么想看、看点备忘'
    }
    if (kind === FanKind.PLAYER) {
      return '特点、精彩表现、关注原因'
    }
    if (kind === FanKind.KNOWLEDGE) {
      return '规则说明、球队历史或球员故事'
    }
    if (kind === FanKind.EVENT) {
      return '看点备忘、和谁一起看'
    }
    if (kind === FanKind.ALBUM) {
      return '这本合集收录哪些经典比赛、为什么珍藏'
    }
    return '完成标准（例如观看 10 场）'
  }

  static defaultStatus(kind: string): string {
    if (kind === FanKind.WATCHLIST) {
      return 'pending'
    }
    if (kind === FanKind.TEAM) {
      return 'like'
    }
    if (kind === FanKind.CHALLENGE) {
      return 'todo'
    }
    if (kind === FanKind.KNOWLEDGE) {
      return 'rule'
    }
    if (kind === FanKind.JOURNAL) {
      return 'feel'
    }
    return ''
  }
}

export class FanEntry {
  id: string = ''
  kind: string = FanKind.MATCH
  title: string = ''
  subtitle: string = ''
  dateLabel: string = ''
  body: string = ''
  extra: string = ''
  rating: number = 0
  status: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class FanStats {
  matchCount: number = 0
  journalCount: number = 0
  teamCount: number = 0
  reviewCount: number = 0
  highlightCount: number = 0
  watchCount: number = 0
  playerCount: number = 0
  knowledgeCount: number = 0
  challengeDone: number = 0
  challengeTotal: number = 0
  eventCount: number = 0
  albumCount: number = 0
  streakDays: number = 0
  totalRecords: number = 0
}

export class FanHubItem {
  kind: string = ''
  title: string = ''
  hint: string = ''
  count: number = 0
  coverKey: string = ''
}

/** 成长里程碑（由本机统计动态计算，非假数据） */
export class FanMilestone {
  id: string = ''
  title: string = ''
  hint: string = ''
  unlocked: boolean = false
  progress: string = ''
}

/** 记忆类型分布（供图表展示） */
export class FanTypeCount {
  label: string = ''
  value: number = 0
}

/** 场景化创作入口 */
export class FanScenario {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  coverKey: string = ''
}
