export class WisdomItem {
  id: string = ''
  content: string = ''
  source: string = ''
}

export class MoodOption {
  key: string = ''
  label: string = ''
  emoji: string = ''

  static all(): MoodOption[] {
    const defs: string[][] = [
      ['1', '喜悦', '😊'],
      ['2', '平静', '😌'],
      ['3', '一般', '😐'],
      ['4', '低落', '😔'],
      ['5', '疲惫', '😴']
    ]
    const out: MoodOption[] = []
    for (const d of defs) {
      const m = new MoodOption()
      m.key = d[0]
      m.label = d[1]
      m.emoji = d[2]
      out.push(m)
    }
    return out
  }

  static find(key: string): MoodOption | undefined {
    for (const m of MoodOption.all()) {
      if (m.key === key) {
        return m
      }
    }
    return undefined
  }
}

export class MoodRecord {
  dateKey: string = ''
  moodKey: string = '3'
  moodLabel: string = '一般'
  note: string = ''
  gratitude: string[] = []
  updatedAt: number = 0
}

export class TodoItem {
  id: string = ''
  title: string = ''
  isCompleted: boolean = false
  category: string = ''
}

export class HabitDef {
  id: string = ''
  title: string = ''
  iconName: string = 'check'
}

export class HabitDayRecord {
  dateKey: string = ''
  habitIds: string[] = []
}

export class UserProfile {
  nickname: string = '生活旅人'
  darkMode: boolean = false
}

export class DayWeatherMock {
  condition: string = '晴'
  tempHigh: number = 26
  tempLow: number = 18
  solarTerm: string = ''
}
