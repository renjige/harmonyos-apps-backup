import { AnnualStatsData } from '../models/JournalModels'

export class AchievementBadge {
  id: string = ''
  title: string = ''
  description: string = ''
  unlocked: boolean = false
}

export class AchievementService {
  static buildBadges(
    stats: AnnualStatsData,
    checkinStreak: number,
    footprintCities: number
  ): AchievementBadge[] {
    const badges: AchievementBadge[] = []

    const b1 = new AchievementBadge()
    b1.id = 'first_journey'
    b1.title = '首次旅程'
    b1.description = '写下第一段旅行札记'
    b1.unlocked = stats.diaryCount >= 1
    badges.push(b1)

    const b2 = new AchievementBadge()
    b2.id = 'album_maker'
    b2.title = '相册成册'
    b2.description = '创建第一个旅行相册'
    b2.unlocked = stats.albumCount >= 1
    badges.push(b2)

    const b3 = new AchievementBadge()
    b3.id = 'favorite_star'
    b3.title = '收藏行家'
    b3.description = '收藏一段旅途回忆'
    b3.unlocked = stats.favoriteCount >= 1
    badges.push(b3)

    const b4 = new AchievementBadge()
    b4.id = 'streak_3'
    b4.title = '连续打卡 3 天'
    b4.description = '坚持记录旅途心情'
    b4.unlocked = checkinStreak >= 3
    badges.push(b4)

    const b5 = new AchievementBadge()
    b5.id = 'streak_7'
    b5.title = '连续打卡 7 天'
    b5.description = '一周不间断旅途记录'
    b5.unlocked = checkinStreak >= 7
    badges.push(b5)

    const b6 = new AchievementBadge()
    b6.id = 'footprint_3'
    b6.title = '三城足迹'
    b6.description = '足迹覆盖 3 个目的地'
    b6.unlocked = footprintCities >= 3
    badges.push(b6)

    const b7 = new AchievementBadge()
    b7.id = 'writer_10'
    b7.title = '记录达人'
    b7.description = '累计 10 篇旅程札记'
    b7.unlocked = stats.diaryCount >= 10
    badges.push(b7)

    const b8 = new AchievementBadge()
    b8.id = 'year_writer'
    b8.title = '年度书写者'
    b8.description = '今年写作天数达 30 天'
    b8.unlocked = stats.writingDays >= 30
    badges.push(b8)

    return badges
  }

  static unlockedCount(badges: AchievementBadge[]): number {
    let n = 0
    for (const b of badges) {
      if (b.unlocked) {
        n += 1
      }
    }
    return n
  }
}
