export class DailyTaskItem {
  id: string = ''
  title: string = ''
  detail: string = ''
  encourage: string = ''

  static create(id: string, title: string, detail: string, encourage: string): DailyTaskItem {
    const t = new DailyTaskItem()
    t.id = id
    t.title = title
    t.detail = detail
    t.encourage = encourage
    return t
  }
}

export class DailyQuoteItem {
  id: string = ''
  text: string = ''

  static create(id: string, text: string): DailyQuoteItem {
    const q = new DailyQuoteItem()
    q.id = id
    q.text = text
    return q
  }
}

export class MoodEntry {
  dateKey: string = ''
  moodKey: string = ''
  moodLabel: string = ''
  note: string = ''
  updatedAt: number = 0

  static create(dateKey: string, moodKey: string, moodLabel: string, note: string): MoodEntry {
    const m = new MoodEntry()
    m.dateKey = dateKey
    m.moodKey = moodKey
    m.moodLabel = moodLabel
    m.note = note
    m.updatedAt = Date.now()
    return m
  }
}

export class UserProfile {
  nickname: string = '青柠用户'
  avatarKey: string = 'default'

  static defaultProfile(): UserProfile {
    const p = new UserProfile()
    p.nickname = '青柠用户'
    p.avatarKey = 'default'
    return p
  }
}

export class DailyStats {
  streakDays: number = 0
  totalMoods: number = 0
  favoriteCount: number = 0
  taskDoneCount: number = 0
}

export class MoodOption {
  key: string = ''
  label: string = ''
  emoji: string = ''

  static create(key: string, label: string, emoji: string): MoodOption {
    const o = new MoodOption()
    o.key = key
    o.label = label
    o.emoji = emoji
    return o
  }
}

export class DailyConstants {
  static tasks(): DailyTaskItem[] {
    const list: DailyTaskItem[] = []
    list.push(DailyTaskItem.create('t1', '今天拍一张天空的照片',
      '抬头看看今天的云，用手机留下这一瞬间。不必完美，真实就好。',
      '天空会记住你的好奇心。'))
    list.push(DailyTaskItem.create('t2', '给家人发一句问候',
      '一条简单的消息，一句「今天好吗」，就能让距离变近。',
      '温暖的话，值得被说出口。'))
    list.push(DailyTaskItem.create('t3', '读一页书',
      '翻开任意一本书，认真读一页。可以出声，也可以默读。',
      '一页也是进步，今天你又前进了。'))
    list.push(DailyTaskItem.create('t4', '做一件好事',
      '帮同事递杯水、给陌生人让路、整理公共区域的杂物……小事即可。',
      '世界因你的善意更亮一点。'))
    list.push(DailyTaskItem.create('t5', '记录一个微笑',
      '留意今天让你嘴角上扬的瞬间，写下来或记在心里。',
      '微笑是最轻的日常礼物。'))
    list.push(DailyTaskItem.create('t6', '走一段没走过的路',
      '换一条回家或散步的路线，看看不同的风景与店铺。',
      '新路线，新发现，新心情。'))
    list.push(DailyTaskItem.create('t7', '写一句感谢',
      '感谢某个人、某件事，或感谢坚持到现在的自己。',
      '感恩让日常有了光。'))
    return list
  }

  static quotes(): DailyQuoteItem[] {
    const texts: string[] = [
      '小确幸藏在寻常烟火里，别等大事才觉得值得庆祝。',
      '今天不必完美，只要比昨天多一点点温柔就好。',
      '慢下来，听听自己的呼吸，日子就不会那么赶。',
      '把一件小事做好，就是对生活最好的回答。',
      '你认真生活的样子，真的很可爱。',
      '允许休息，也允许努力，两者都是爱自己。',
      '阳光会迟到，但从不缺席；你也是。',
      '把烦恼写成字，它会变轻；把快乐写成字，它会变久。',
      '今天也要对自己说一句：你已经很棒了。',
      '生活不是冲刺，而是一次次轻轻起跳的舞蹈。',
      '留心身边的绿，心也会跟着亮起来。',
      '不必和所有人比较，你的节奏刚刚好。',
      '一杯水、一口饭、一次深呼吸，都是值得感恩的事。',
      '把期待放低一点，惊喜就会多一点点。',
      '失败只是过程，不是标签；明天还可以重新开始。',
      '给未来写信之前，先好好拥抱今天。',
      '温柔不是软弱，而是一种力量。',
      '你记录下的每一句，都是写给未来自己的信。',
      '世界很大，但此刻的你是完整的。',
      '做喜欢的事五分钟，胜过空想一整晚。',
      '与其焦虑未知，不如整理眼前的一平米。',
      '允许情绪来访，也允许它离开。',
      '把今天过成作品，而不是任务清单。',
      '好好吃饭，是对身体最朴素的爱。',
      '每一次按时睡觉，都是在为明天充电。',
      '你值得被温柔对待，首先从自己开始。',
      '别急着回答所有问题，有些答案会在路上出现。',
      '分享一点快乐，它会变成双份。',
      '今天的你，已经比昨天更懂得生活。',
      '青柠般清新的一天，从一个小决定开始。'
    ]
    const list: DailyQuoteItem[] = []
    for (let i = 0; i < texts.length; i++) {
      list.push(DailyQuoteItem.create(`q${i + 1}`, texts[i]))
    }
    return list
  }

  static moods(): MoodOption[] {
    const list: MoodOption[] = []
    list.push(MoodOption.create('happy', '开心', '😊'))
    list.push(MoodOption.create('calm', '平静', '😐'))
    list.push(MoodOption.create('sad', '难过', '😢'))
    list.push(MoodOption.create('excited', '兴奋', '😄'))
    list.push(MoodOption.create('angry', '生气', '😡'))
    list.push(MoodOption.create('sleepy', '困倦', '😴'))
    return list
  }
}
