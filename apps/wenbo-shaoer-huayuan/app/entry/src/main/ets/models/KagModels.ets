export class CatalogItemWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  category: string = ''
  seasonTag: string = ''
  lightMood: string = ''
  ageHint: string = ''
  readMinutes: number = 0
}

export class CatalogItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'empty_easel'
  category: string = ''
  seasonTag: string = ''
  lightMood: string = ''
  ageHint: string = ''
  readMinutes: number = 3

  static fromWire(w: CatalogItemWire): CatalogItem {
    const item = new CatalogItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? w.body ?? ''
    item.coverKey = w.coverKey !== undefined && w.coverKey.length > 0 ? w.coverKey : 'empty_easel'
    item.category = w.category ?? ''
    item.seasonTag = w.seasonTag ?? ''
    item.lightMood = w.lightMood ?? ''
    item.ageHint = w.ageHint ?? ''
    if (w.readMinutes !== undefined && w.readMinutes !== null) {
      item.readMinutes = w.readMinutes
    }
    return item
  }
}

export class CatalogListPayload {
  list: CatalogItemWire[] = []
}

export class ArtworkItemWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  story: string = ''
  createdOn: string = ''
  ageLabel: string = ''
  childId: string = ''
  imageFile: string = ''
  coverKey: string = ''
  userId: string = ''
  tags: string[] = []
  albumIds: string[] = []
}

export class ArtworkItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  story: string = ''
  createdOn: string = ''
  ageLabel: string = ''
  childId: string = ''
  imageFile: string = ''
  coverKey: string = 'empty_easel'
  userId: string = ''
  tags: string[] = []
  albumIds: string[] = []

  static fromWire(w: ArtworkItemWire): ArtworkItem {
    const item = new ArtworkItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.story = w.story ?? w.body ?? ''
    item.createdOn = w.createdOn ?? ''
    item.ageLabel = w.ageLabel ?? ''
    item.childId = w.childId ?? ''
    item.imageFile = w.imageFile ?? ''
    item.coverKey = w.coverKey !== undefined && w.coverKey.length > 0 ? w.coverKey : 'empty_easel'
    item.userId = w.userId ?? ''
    if (w.tags !== undefined && w.tags !== null) {
      for (const t of w.tags) {
        item.tags.push(t)
      }
    }
    if (w.albumIds !== undefined && w.albumIds !== null) {
      for (const a of w.albumIds) {
        item.albumIds.push(a)
      }
    }
    return item
  }
}

export class ArtworkListPayload {
  list: ArtworkItemWire[] = []
}

export class AlbumItemWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  childId: string = ''
  coverKey: string = ''
  coverWorkId: string = ''
  userId: string = ''
}

export class AlbumItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  childId: string = ''
  coverKey: string = 'empty_easel'
  coverWorkId: string = ''
  userId: string = ''

  static fromWire(w: AlbumItemWire): AlbumItem {
    const item = new AlbumItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.childId = w.childId ?? ''
    item.coverKey = w.coverKey !== undefined && w.coverKey.length > 0 ? w.coverKey : 'empty_easel'
    item.coverWorkId = w.coverWorkId ?? ''
    item.userId = w.userId ?? ''
    return item
  }
}

export class AlbumListPayload {
  list: AlbumItemWire[] = []
}

export class ChildItemWire {
  id: string = ''
  title: string = ''
  birthYear: string = ''
  note: string = ''
  summary: string = ''
  userId: string = ''
}

export class ChildItem {
  id: string = ''
  title: string = ''
  birthYear: string = ''
  note: string = ''
  summary: string = ''
  userId: string = ''

  static fromWire(w: ChildItemWire): ChildItem {
    const item = new ChildItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.birthYear = w.birthYear ?? ''
    item.note = w.note ?? ''
    item.summary = w.summary ?? ''
    item.userId = w.userId ?? ''
    return item
  }
}

export class ChildListPayload {
  list: ChildItemWire[] = []
}

export class ArtworkWriteRequest {
  title: string = ''
  createdOn: string = ''
  ageLabel: string = ''
  story: string = ''
  childId: string = ''
  imageFile: string = ''
  coverKey: string = 'empty_easel'
  userId: string = ''
  albumIds: string[] = []
  tags: string[] = []

  toJsonString(): string {
    const albums = JSON.stringify(this.albumIds)
    const tags = JSON.stringify(this.tags)
    return `{"title":${JSON.stringify(this.title)},"createdOn":${JSON.stringify(this.createdOn)},` +
      `"ageLabel":${JSON.stringify(this.ageLabel)},"story":${JSON.stringify(this.story)},` +
      `"childId":${JSON.stringify(this.childId)},"imageFile":${JSON.stringify(this.imageFile)},` +
      `"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)},` +
      `"albumIds":${albums},"tags":${tags}}`
  }
}

export class AlbumWriteRequest {
  title: string = ''
  summary: string = ''
  childId: string = ''
  coverKey: string = 'empty_easel'
  coverWorkId: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},` +
      `"childId":${JSON.stringify(this.childId)},"coverKey":${JSON.stringify(this.coverKey)},` +
      `"coverWorkId":${JSON.stringify(this.coverWorkId)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class ChildWriteRequest {
  title: string = ''
  name: string = ''
  birthYear: string = ''
  note: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"name":${JSON.stringify(this.name)},` +
      `"birthYear":${JSON.stringify(this.birthYear)},"note":${JSON.stringify(this.note)},` +
      `"userId":${JSON.stringify(this.userId)}}`
  }
}

export class MsgItemWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  createdAt: string = ''
}

export class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  createdAt: string = ''

  static fromWire(w: MsgItemWire): MsgItem {
    const item = new MsgItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.body = w.body ?? ''
    item.type = w.type ?? ''
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class MsgListPayload {
  list: MsgItemWire[] = []
}
