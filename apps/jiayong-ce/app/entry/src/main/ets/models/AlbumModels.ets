export class FamilyPhoto {
  id: string = ''
  uri: string = ''
  caption: string = ''
  takenAt: number = 0
  memberId: string = ''
  location: string = ''
  isVideo: boolean = false
  uploadedBy: string = ''
  createdAt: number = 0
  favorited: boolean = false
  albumId: string = ''
}

export class FamilyMember {
  id: string = ''
  name: string = ''
  relation: string = ''
  avatarColor: string = '#E8862E'
  isOwner: boolean = false
}

export class FamilyActivity {
  id: string = ''
  memberId: string = ''
  memberName: string = ''
  action: string = 'upload'
  photoId: string = ''
  caption: string = ''
  createdAt: number = 0
}

export class FamilyProfile {
  name: string = '我的家庭'
  inviteCode: string = ''
  coverUri: string = ''
}

export class AppSettings {
  displayName: string = ''
  colorMode: string = 'system'
  darkFollowSystem: boolean = true
  autoBackup: boolean = false
  notifyFamily: boolean = true
}

export class StorageStats {
  usedBytes: number = 0
  quotaBytes: number = 5368709120
  photoCount: number = 0
  favoriteCount: number = 0
  locationCount: number = 0
}

export class MemoryCard {
  year: number = 0
  month: number = 0
  day: number = 0
  photos: FamilyPhoto[] = []
}

export class BucketItem {
  key: string = ''
  label: string = ''
  count: number = 0
}

export class RecapMonth {
  label: string = ''
  count: number = 0
}

export class RecapSummary {
  photoCount: number = 0
  favoriteCount: number = 0
  locationCount: number = 0
  memberCount: number = 0
  thisMonth: number = 0
  months: RecapMonth[] = []
}

export class ThemeAlbum {
  id: string = ''
  title: string = ''
  createdAt: number = 0
}

export class Anniversary {
  id: string = ''
  title: string = ''
  month: number = 1
  day: number = 1
  note: string = ''
}

export class AlbumBundle {
  photos: FamilyPhoto[] = []
  members: FamilyMember[] = []
  activities: FamilyActivity[] = []
  albums: ThemeAlbum[] = []
  anniversaries: Anniversary[] = []
  profile: FamilyProfile = new FamilyProfile()
  settings: AppSettings = new AppSettings()
}

export class PhotoWrite {
  caption: string = ''
  location: string = ''
  memberId: string = ''
  takenAt: number = 0
  albumId: string = ''
  favorited: boolean = false
}
