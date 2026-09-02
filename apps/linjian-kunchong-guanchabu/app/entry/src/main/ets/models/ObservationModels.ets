export class Observation {
  id: string = ''
  name: string = ''
  photoUri: string = ''
  location: string = ''
  latitude: number = 0
  longitude: number = 0
  date: string = ''
  time: string = ''
  weather: string = 'sunny'
  behavior: string = ''
  tags: string[] = []
  isFavorite: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): Observation {
    const now = new Date()
    const o = new Observation()
    o.id = `${now.getTime()}_${Math.floor(Math.random() * 100000)}`
    o.date = Observation.formatDate(now)
    o.time = Observation.formatTime(now)
    o.createdAt = now.getTime()
    o.updatedAt = now.getTime()
    return o
  }

  static formatDate(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static formatTime(d: Date): string {
    const h = d.getHours()
    const min = d.getMinutes()
    const hh = h < 10 ? `0${h}` : `${h}`
    const mm = min < 10 ? `0${min}` : `${min}`
    return `${hh}:${mm}`
  }

  tagsJoined(): string {
    if (this.tags.length === 0) {
      return ''
    }
    return this.tags.join(' · ')
  }
}

export class UserProfile {
  nickname: string = '观察者'
  themeMode: string = 'system'
}

export class WeatherOption {
  key: string = ''
  label: string = ''

  static all(): WeatherOption[] {
    const out: WeatherOption[] = []
    const sunny = new WeatherOption()
    sunny.key = 'sunny'
    sunny.label = '晴'
    out.push(sunny)
    const cloudy = new WeatherOption()
    cloudy.key = 'cloudy'
    cloudy.label = '多云'
    out.push(cloudy)
    const overcast = new WeatherOption()
    overcast.key = 'overcast'
    overcast.label = '阴'
    out.push(overcast)
    const rainy = new WeatherOption()
    rainy.key = 'rainy'
    rainy.label = '雨'
    out.push(rainy)
    const other = new WeatherOption()
    other.key = 'other'
    other.label = '其他'
    out.push(other)
    return out
  }

  static labelOf(key: string): string {
    const list = WeatherOption.all()
    for (const w of list) {
      if (w.key === key) {
        return w.label
      }
    }
    return '其他'
  }
}

export class TagPreset {
  static all(): string[] {
    return ['飞行中', '觅食', '交配', '幼虫', '停歇', '其他']
  }
}
