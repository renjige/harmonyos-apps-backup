import { ArticleItem } from '../models/PavilionModels'

export class QuizQuestion {
  prompt: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  correct: number = 0
  explain: string = ''
}

export class QuizService {
  static build(article: ArticleItem): QuizQuestion[] {
    const out: QuizQuestion[] = []
    out.push(QuizService.categoryQuestion(article))
    out.push(QuizService.titleQuestion(article))
    out.push(QuizService.summaryQuestion(article))
    return out
  }

  private static categoryQuestion(article: ArticleItem): QuizQuestion {
    const q = new QuizQuestion()
    q.prompt = `「${article.title}」主要属于哪个兴趣分类？`
    const right = article.categoryLabel()
    const distract = QuizService.otherCategory(article.category)
    const extra = QuizService.otherCategory2(article.category)
    q.correct = 0
    q.optionA = right
    q.optionB = distract
    q.optionC = extra
    q.explain = `本篇栏目为${right}。`
    return q
  }

  private static titleQuestion(article: ArticleItem): QuizQuestion {
    const q = new QuizQuestion()
    q.prompt = '下面哪一句更接近本篇标题要讲的事？'
    q.optionA = article.title
    q.optionB = '如何快速赚钱的投资教程'
    q.optionC = '今日天气预报与穿衣指数'
    q.correct = 0
    q.explain = '趣味问答根据当前趣知标题生成，不调用大模型。'
    return q
  }

  private static summaryQuestion(article: ArticleItem): QuizQuestion {
    const q = new QuizQuestion()
    q.prompt = '本篇导语的核心意思更接近？'
    const sum = article.summary
    q.optionA = sum.length > 0 ? sum : article.title
    q.optionB = '这是一条与内容无关的广告优惠券说明。'
    q.optionC = '这是一份需要付费解锁的课程大纲。'
    q.correct = 0
    q.explain = '识趣阁问答用于巩固刚读过的内容，便于养成每日探索习惯。'
    return q
  }

  private static otherCategory(cat: string): string {
    if (cat === 'history') {
      return '科普百科'
    }
    if (cat === 'science') {
      return '历史文化'
    }
    if (cat === 'nature') {
      return '艺术欣赏'
    }
    if (cat === 'art') {
      return '自然探索'
    }
    if (cat === 'fun') {
      return '生活技巧'
    }
    return '趣味知识'
  }

  private static otherCategory2(cat: string): string {
    if (cat === 'life' || cat === 'fun') {
      return '历史文化'
    }
    return '生活技巧'
  }
}
