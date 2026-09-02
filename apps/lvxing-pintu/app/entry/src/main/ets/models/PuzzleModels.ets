export class PuzzlePiece {
  id: string = ''
  imageUri: string = ''
  caption: string = ''
  location: string = ''
  takenAt: number = 0
}

export class TravelPuzzle {
  id: string = ''
  title: string = ''
  location: string = ''
  layoutType: string = 'grid-4'
  pieces: PuzzlePiece[] = []
  tags: string[] = []
  favorited: boolean = false
  createdAt: number = 0
  updatedAt: number = 0
}

export class TagItem {
  id: string = ''
  name: string = ''
}

export class AppSettings {
  displayName: string = ''
  colorMode: string = 'system'
  darkFollowSystem: boolean = true
}

export class PuzzleStats {
  tripCount: number = 0
  cityCount: number = 0
  photoCount: number = 0
}

export class PuzzleBundle {
  puzzles: TravelPuzzle[] = []
  tags: TagItem[] = []
  settings: AppSettings = new AppSettings()
}

export class LayoutOption {
  id: string = ''
  label: string = ''
  minPhotos: number = 3
  maxPhotos: number = 9

  static all(): LayoutOption[] {
    const list: LayoutOption[] = []
    const a = new LayoutOption()
    a.id = 'classic-3'
    a.label = '经典三格'
    a.minPhotos = 3
    a.maxPhotos = 3
    list.push(a)
    const b = new LayoutOption()
    b.id = 'grid-4'
    b.label = '四宫格'
    b.minPhotos = 4
    b.maxPhotos = 4
    list.push(b)
    const c = new LayoutOption()
    c.id = 'grid-6'
    c.label = '六格拼贴'
    c.minPhotos = 6
    c.maxPhotos = 6
    list.push(c)
    const d = new LayoutOption()
    d.id = 'grid-9'
    d.label = '九宫格'
    d.minPhotos = 9
    d.maxPhotos = 9
    list.push(d)
    return list
  }

  static find(id: string): LayoutOption | null {
    for (const item of LayoutOption.all()) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }
}
