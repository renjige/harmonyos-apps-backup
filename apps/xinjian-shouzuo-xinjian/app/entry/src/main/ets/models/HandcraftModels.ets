/** 手作心笺 — 平台 /biz/handcraft Wire 模型（ArkTS strict） */

export class HandcraftWorkWire {
  id: string = ''
  title: string = ''
  category: string = ''
  coverKey: string = ''
  summary: string = ''
  description: string = ''
  materials: string[] = []
  steps: string[] = []
  notes: string = ''
  tags: string[] = []
  userId: string = ''
  userName: string = ''
  likeCount: number = 0
  commentCount: number = 0
  status: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class HandcraftWork {
  id: string = ''
  title: string = ''
  category: string = ''
  coverKey: string = ''
  summary: string = ''
  description: string = ''
  materials: string[] = []
  steps: string[] = []
  notes: string = ''
  tags: string[] = []
  userId: string = ''
  userName: string = ''
  likeCount: number = 0
  commentCount: number = 0
  createdAt: string = ''
  updatedAt: string = ''

  static fromWire(w: HandcraftWorkWire): HandcraftWork {
    const item = new HandcraftWork()
    item.id = w.id
    item.title = w.title
    item.category = w.category
    item.coverKey = w.coverKey
    item.summary = w.summary
    item.description = w.description.length > 0 ? w.description : w.summary
    item.materials = w.materials ?? []
    item.steps = w.steps ?? []
    item.notes = w.notes
    item.tags = w.tags ?? []
    item.userId = w.userId
    item.userName = w.userId === 'curator' ? '' : w.userName
    item.likeCount = w.likeCount ?? 0
    item.commentCount = w.commentCount ?? 0
    item.createdAt = w.createdAt ?? ''
    item.updatedAt = w.updatedAt ?? ''
    return item
  }
}

export class HandcraftWorkListPayload {
  list: HandcraftWorkWire[] = []
}

export class HandcraftCategoryWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  iconKey: string = ''
  sort: number = 0
}

export class HandcraftCategory {
  id: string = ''
  title: string = ''
  summary: string = ''
  iconKey: string = ''

  static fromWire(w: HandcraftCategoryWire): HandcraftCategory {
    const item = new HandcraftCategory()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary
    item.iconKey = w.iconKey
    return item
  }
}

export class HandcraftCategoryListPayload {
  list: HandcraftCategoryWire[] = []
}

export class HandcraftInspirationWire {
  id: string = ''
  title: string = ''
  content: string = ''
  tags: string[] = []
  category: string = ''
  userId: string = ''
  createdAt: string = ''
}

export class HandcraftInspiration {
  id: string = ''
  title: string = ''
  content: string = ''
  tags: string[] = []
  category: string = ''
  userId: string = ''
  createdAt: string = ''

  static fromWire(w: HandcraftInspirationWire): HandcraftInspiration {
    const item = new HandcraftInspiration()
    item.id = w.id
    item.title = w.title
    item.content = w.content
    item.tags = w.tags ?? []
    item.category = w.category
    item.userId = w.userId
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class HandcraftChallengeWire extends HandcraftWorkWire {
  joined: boolean = false
  participantCount: number = 0
  extra: string = ''
}

export class HandcraftChallenge {
  id: string = ''
  title: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  participantCount: number = 0
  joined: boolean = false
  endAt: string = ''

  static fromWire(w: HandcraftChallengeWire): HandcraftChallenge {
    const item = new HandcraftChallenge()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary
    item.description = w.description.length > 0 ? w.description : w.summary
    item.coverKey = w.coverKey
    item.participantCount = w.participantCount ?? w.likeCount ?? 0
    item.joined = w.joined ?? false
    item.endAt = w.extra ?? ''
    return item
  }
}

export class HandcraftMaterialWire {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  content: string = ''
  notes: string = ''
  userId: string = ''
}

export class HandcraftMaterial {
  id: string = ''
  name: string = ''
  category: string = ''
  quantity: string = ''
  unit: string = ''
  notes: string = ''

  static fromWire(w: HandcraftMaterialWire): HandcraftMaterial {
    const item = new HandcraftMaterial()
    item.id = w.id
    item.name = w.title
    item.category = w.category
    item.quantity = w.summary
    item.unit = w.content
    item.notes = w.notes
    return item
  }
}

export class HandcraftMaterialListPayload {
  list: HandcraftMaterialWire[] = []
}

export class CreateMaterialRequest {
  name: string = ''
  category: string = ''
  quantity: string = ''
  unit: string = ''
  notes: string = ''
  username: string = ''

  toJsonString(): string {
    return `{"name":${JSON.stringify(this.name)},"category":${JSON.stringify(this.category)},"quantity":${JSON.stringify(this.quantity)},"unit":${JSON.stringify(this.unit)},"notes":${JSON.stringify(this.notes)},"username":${JSON.stringify(this.username)}}`
  }
}

export class MaterialActionBody {
  username: string = ''

  toJsonString(): string {
    return `{"username":${JSON.stringify(this.username)}}`
  }
}

export class HandcraftInspirationListPayload {
  list: HandcraftInspirationWire[] = []
}

export class HandcraftCommentWire {
  id: string = ''
  workId: string = ''
  userId: string = ''
  userName: string = ''
  content: string = ''
  createdAt: string = ''
}

export class HandcraftComment {
  id: string = ''
  workId: string = ''
  userId: string = ''
  userName: string = ''
  content: string = ''

  static fromWire(w: HandcraftCommentWire): HandcraftComment {
    const item = new HandcraftComment()
    item.id = w.id
    item.workId = w.workId
    item.userId = w.userId
    item.userName = w.userName
    item.content = w.content
    return item
  }
}

export class HandcraftCommentListPayload {
  list: HandcraftCommentWire[] = []
}

export class HandcraftInteractionsWire {
  likeCount: number = 0
  commentCount: number = 0
  liked: boolean = false
  favorited: boolean = false
}

export class HandcraftLikeResult {
  liked: boolean = false
  likeCount: number = 0
}

export class HandcraftFavoriteResult {
  favorited: boolean = false
}

export class CreateWorkRequest {
  title: string = ''
  category: string = ''
  coverKey: string = ''
  summary: string = ''
  description: string = ''
  materials: string[] = []
  steps: string[] = []
  notes: string = ''
  tags: string[] = []
  username: string = ''
  userName: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"category":${JSON.stringify(this.category)},"coverKey":${JSON.stringify(this.coverKey)},"summary":${JSON.stringify(this.summary)},"description":${JSON.stringify(this.description)},"materials":${JSON.stringify(this.materials)},"steps":${JSON.stringify(this.steps)},"notes":${JSON.stringify(this.notes)},"tags":${JSON.stringify(this.tags)},"username":${JSON.stringify(this.username)},"userName":${JSON.stringify(this.userName)}}`
  }
}

export class UpdateWorkRequest {
  title: string = ''
  category: string = ''
  coverKey: string = ''
  summary: string = ''
  description: string = ''
  materials: string[] = []
  steps: string[] = []
  notes: string = ''
  tags: string[] = []
  username: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"category":${JSON.stringify(this.category)},"coverKey":${JSON.stringify(this.coverKey)},"summary":${JSON.stringify(this.summary)},"description":${JSON.stringify(this.description)},"materials":${JSON.stringify(this.materials)},"steps":${JSON.stringify(this.steps)},"notes":${JSON.stringify(this.notes)},"tags":${JSON.stringify(this.tags)},"username":${JSON.stringify(this.username)}}`
  }
}

export class CreateInspirationRequest {
  title: string = ''
  content: string = ''
  tags: string[] = []
  category: string = ''
  username: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"content":${JSON.stringify(this.content)},"tags":${JSON.stringify(this.tags)},"category":${JSON.stringify(this.category)},"username":${JSON.stringify(this.username)}}`
  }
}

export class HandcraftActionBody {
  username: string = ''

  toJsonString(): string {
    return `{"username":${JSON.stringify(this.username)}}`
  }
}

export class HandcraftCommentBody {
  content: string = ''
  username: string = ''
  userName: string = ''

  toJsonString(): string {
    return `{"content":${JSON.stringify(this.content)},"username":${JSON.stringify(this.username)},"userName":${JSON.stringify(this.userName)}}`
  }
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}
