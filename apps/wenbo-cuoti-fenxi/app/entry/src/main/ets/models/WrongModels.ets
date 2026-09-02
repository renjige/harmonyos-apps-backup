export class CatalogItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  subjectCode: string = ''
  causeCode: string = ''
  knowledgeTag: string = ''
  readMinutes: number = 0
}

export class CatalogListData {
  list: CatalogItem[] = []
}

export class WrongEntry {
  id: string = ''
  title: string = ''
  stem: string = ''
  correctAnswer: string = ''
  wrongAnswer: string = ''
  subjectCode: string = ''
  knowledgeTag: string = ''
  causeCode: string = ''
  status: string = 'pending'
  photoUri: string = ''
  remark: string = ''
  coverKey: string = ''
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class EntryListData {
  list: WrongEntry[] = []
}

export class WrongEntryWrite {
  userId: string = ''
  stem: string = ''
  correctAnswer: string = ''
  wrongAnswer: string = ''
  subjectCode: string = ''
  knowledgeTag: string = ''
  causeCode: string = ''
  photoUri: string = ''
  remark: string = ''
  status: string = 'pending'
  coverKey: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"stem":${JSON.stringify(this.stem)},"correctAnswer":${JSON.stringify(this.correctAnswer)},"wrongAnswer":${JSON.stringify(this.wrongAnswer)},"subjectCode":${JSON.stringify(this.subjectCode)},"knowledgeTag":${JSON.stringify(this.knowledgeTag)},"causeCode":${JSON.stringify(this.causeCode)},"photoUri":${JSON.stringify(this.photoUri)},"remark":${JSON.stringify(this.remark)},"status":${JSON.stringify(this.status)},"coverKey":${JSON.stringify(this.coverKey)}}`
  }
}

export class SubjectOption {
  code: string = ''
  label: string = ''

  static of(code: string, label: string): SubjectOption {
    const o = new SubjectOption()
    o.code = code
    o.label = label
    return o
  }
}

export class CauseOption {
  code: string = ''
  label: string = ''

  static of(code: string, label: string): CauseOption {
    const o = new CauseOption()
    o.code = code
    o.label = label
    return o
  }
}

export class WeakPoint {
  tag: string = ''
  count: number = 0
}

export class SuggestionCard {
  title: string = ''
  body: string = ''
}

export class MsgRecord {
  id: string = ''
  title: string = ''
  body: string = ''
}

export class MsgListData {
  list: MsgRecord[] = []
}

export class FilterChip {
  id: string = ''
  label: string = ''
}

export class CatalogKind {
  static readonly SUBJECT: string = 'subject'
  static readonly METHOD: string = 'method'
  static readonly TIP: string = 'tip'
  static readonly ARTICLE: string = 'article'
  static readonly ENTRY: string = 'entry'
}
