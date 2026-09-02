export class IdiomQuestion {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  idiom: string = ''
  pinyin: string = ''
  category: string = ''
  categoryLabel: string = ''
  theme: string = ''
  difficulty: string = '初级'
  questionType: string = 'choice'
  question: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  answerIndex: number = 0
  hint: string = ''
  explanation: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'cat_intro'
  chapterIndex: number = 1
  levelIndex: number = 1
}

export class IdiomListData {
  list: IdiomQuestion[] = []
}

export class ChapterItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  difficulty: string = '初级'
  coverKey: string = 'cat_intro'
  category: string = ''
  categoryLabel: string = ''
  chapterIndex: number = 1
}

export class ChapterListData {
  list: ChapterItem[] = []
}

export class ThemeItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'cat_history'
  category: string = ''
  categoryLabel: string = ''
  theme: string = ''
  difficulty: string = '中级'
}

export class ThemeListData {
  list: ThemeItem[] = []
}

export class BadgeItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  rule: string = ''
  coverKey: string = 'hero_seal'
}

export class BadgeListData {
  list: BadgeItem[] = []
}

export class OptionIndex {
  i: number = 0

  static four(): OptionIndex[] {
    const list: OptionIndex[] = []
    for (let n = 0; n < 4; n++) {
      const o = new OptionIndex()
      o.i = n
      list.push(o)
    }
    return list
  }
}

export class LevelIndex {
  n: number = 1

  static ten(): LevelIndex[] {
    const list: LevelIndex[] = []
    for (let i = 1; i <= 10; i++) {
      const o = new LevelIndex()
      o.n = i
      list.push(o)
    }
    return list
  }
}

export class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
}

export class MsgListData {
  list: MsgItem[] = []
}
