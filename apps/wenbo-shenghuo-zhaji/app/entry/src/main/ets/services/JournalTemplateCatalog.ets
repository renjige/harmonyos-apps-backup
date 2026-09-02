/** 生活主题模板 + 分类 */

export class JournalTemplate {
  key: string = ''
  label: string = ''
  hint: string = ''
  titleHint: string = ''
  tags: string[] = []
  lifeClass: string = ''
  coverKey: string = ''
}

export class JournalTemplateCatalog {
  static all(): JournalTemplate[] {
    return [
      JournalTemplateCatalog.make('mood', '今日心情', '写下此刻情绪与一件小事', '今天的心情是…',
        ['心情', '生活感悟'], '生活感悟', 'hero_morning_coffee'),
      JournalTemplateCatalog.make('food', '美食记录', '记录一道菜、一家店或一次下厨', '今天吃到了…',
        ['美食', '兴趣收藏'], '兴趣收藏', 'hero_kitchen'),
      JournalTemplateCatalog.make('travel', '旅行见闻', '把路上的风景和感受收进札记', '这一站想记住…',
        ['旅行', '旅行足迹'], '旅行足迹', 'hero_postcard'),
      JournalTemplateCatalog.make('reading', '阅读笔记', '摘录一句触动你的话', '读到这里时…',
        ['阅读', '学习心得'], '学习心得', 'hero_bookstore'),
      JournalTemplateCatalog.make('idea', '灵感想法', '快速记下突然冒出的念头', '一个忽然想到的点子…',
        ['灵感', '工作成长'], '工作成长', 'hero_rain_walk'),
      JournalTemplateCatalog.make('family', '家庭时光', '记下和家人在一起的片段', '和家人一起…',
        ['家庭', '家庭记录'], '家庭记录', 'hero_plants')
    ]
  }

  static lifeClasses(): string[] {
    return ['生活感悟', '兴趣收藏', '家庭记录', '工作成长', '学习心得', '旅行足迹']
  }

  static isUtilityKind(kind: string): boolean {
    return kind === 'habit' || kind === 'checkin' || kind === 'list' || kind === 'moodlog'
  }

  static isJournalKind(kind: string): boolean {
    return !JournalTemplateCatalog.isUtilityKind(kind)
  }

  static find(key: string): JournalTemplate | undefined {
    const all = JournalTemplateCatalog.all()
    for (let i = 0; i < all.length; i++) {
      if (all[i].key === key) {
        return all[i]
      }
    }
    return undefined
  }

  private static make(
    key: string,
    label: string,
    hint: string,
    titleHint: string,
    tags: string[],
    lifeClass: string,
    coverKey: string
  ): JournalTemplate {
    const t = new JournalTemplate()
    t.key = key
    t.label = label
    t.hint = hint
    t.titleHint = titleHint
    t.tags = tags
    t.lifeClass = lifeClass
    t.coverKey = coverKey
    return t
  }
}
