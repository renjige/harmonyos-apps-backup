export class CategoryEmojiUtil {
  static normalize(category: string): string {
    if (category === 'work' || category === 'work_tip') {
      return 'work_tip'
    }
    if (category === 'life' || category === 'life_wiki') {
      return 'life_wiki'
    }
    if (category === 'study' || category === 'growth') {
      return 'growth'
    }
    if (category === 'spark' || category === 'interest') {
      return 'interest'
    }
    if (category === 'science' || category === 'culture') {
      return category
    }
    return 'interest'
  }

  static allIds(): string[] {
    const ids: string[] = []
    ids.push('life_wiki')
    ids.push('science')
    ids.push('culture')
    ids.push('growth')
    ids.push('interest')
    ids.push('work_tip')
    return ids
  }

  static learnTagIds(): string[] {
    const ids: string[] = []
    ids.push('todo')
    ids.push('mastered')
    ids.push('useful')
    ids.push('spark')
    return ids
  }

  static markFor(category: string): string {
    const id = CategoryEmojiUtil.normalize(category)
    if (id === 'life_wiki') {
      return '🌿'
    }
    if (id === 'science') {
      return '🔬'
    }
    if (id === 'culture') {
      return '🏯'
    }
    if (id === 'growth') {
      return '📖'
    }
    if (id === 'work_tip') {
      return '🛠️'
    }
    return '✨'
  }

  static chipLabel(category: string): string {
    return `${CategoryEmojiUtil.markFor(category)} ${CategoryEmojiUtil.nameOf(category)}`
  }

  static nameOf(category: string): string {
    const id = CategoryEmojiUtil.normalize(category)
    if (id === 'life_wiki') {
      return '生活百科'
    }
    if (id === 'science') {
      return '科普知识'
    }
    if (id === 'culture') {
      return '历史文化'
    }
    if (id === 'growth') {
      return '学习成长'
    }
    if (id === 'work_tip') {
      return '工作技巧'
    }
    return '兴趣探索'
  }

  static learnLabel(tag: string): string {
    if (tag === 'todo') {
      return '待学习'
    }
    if (tag === 'mastered') {
      return '已掌握'
    }
    if (tag === 'useful') {
      return '常用技巧'
    }
    if (tag === 'spark') {
      return '灵感'
    }
    return '未标标签'
  }

  static statusLabel(status: string): string {
    if (status === 'follow') {
      return '跟进中'
    }
    if (status === 'done') {
      return '已消化'
    }
    return '待消化'
  }

  static priorityLabel(priority: string): string {
    if (priority === 'high') {
      return '高'
    }
    if (priority === 'low') {
      return '低'
    }
    return '中'
  }
}
