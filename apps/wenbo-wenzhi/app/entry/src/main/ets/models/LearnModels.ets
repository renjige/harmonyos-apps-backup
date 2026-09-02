/** 问知学习闭环本地模型 */

export class AskHistoryItem {
  id: string = ''
  question: string = ''
  insightId: string = ''
  title: string = ''
  category: string = ''
  createdAt: number = 0
}

export class QuizWrongItem {
  id: string = ''
  insightId: string = ''
  title: string = ''
  picked: string = ''
  correct: string = ''
  createdAt: number = 0
}

export class KnowledgeCardItem {
  id: string = ''
  insightId: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = ''
  createdAt: number = 0
}

export class LearnCatalog {
  static categories(): string[] {
    return ['全部', '生活百科', '科普知识', '历史文化', '学习知识', '健康常识', '趣味知识']
  }

  static folders(): string[] {
    return ['生活百科', '科普知识', '历史文化', '学习知识', '健康常识', '趣味知识']
  }

  static topics(): string[] {
    return ['历史专题', '科学专题', '生活技巧专题', '文化专题']
  }

  static userTags(): string[] {
    return ['已学习', '待了解', '重点收藏']
  }

  static goalOptions(): number[] {
    return [3, 5, 8]
  }
}
