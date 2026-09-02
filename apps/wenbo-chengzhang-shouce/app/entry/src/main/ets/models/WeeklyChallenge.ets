export class WeeklyChallengeItem {
  title: string = ''
  summary: string = ''
  step1: string = ''
  step2: string = ''
  step3: string = ''

  static current(): WeeklyChallengeItem {
    const all = WeeklyChallengeItem.all()
    const week = Math.floor(Date.now() / 604800000)
    const idx = week % all.length
    return all[idx]
  }

  static all(): WeeklyChallengeItem[] {
    const list: WeeklyChallengeItem[] = []
    list.push(WeeklyChallengeItem.of(
      '把一件大事拆成三步',
      '本周只推进一件真正重要的事，用清单代替空进度条。',
      '写出这件大事的最小第一步',
      '完成一次可验证的中间结果',
      '写下完成标准并对照检查'
    ))
    list.push(WeeklyChallengeItem.of(
      '三天成长记录挑战',
      '连续三天各写一条成长记录，让时间轴不再空白。',
      '今天写一条具体发生的事',
      '第二天补一条卡住与突破',
      '第三天写给下周的自己'
    ))
    list.push(WeeklyChallengeItem.of(
      '推开一个卡住的目标',
      '选一个停了很久的目标，本周至少推进到 50%。',
      '重新打开目标并补上拆解步骤',
      '完成其中一步',
      '把进度推进到一半并写一句心得'
    ))
    list.push(WeeklyChallengeItem.of(
      '习惯五连打卡',
      '选一个习惯，本周打满五天。',
      '创建或选定一个习惯',
      '连续打卡三天',
      '打满五天并回顾卡点'
    ))
    list.push(WeeklyChallengeItem.of(
      '完成一次周四问',
      '用进步 / 卡住 / 下周 / 感谢把一周收束。',
      '列出本周真实发生的一件进步',
      '写下卡住的原因',
      '保存一篇完整周复盘'
    ))
    list.push(WeeklyChallengeItem.of(
      '把完成写成里程碑',
      '本周至少完成一个目标，并写入时间轴。',
      '把目标拆成可勾选步骤',
      '勾完所有步骤',
      '写下完成心得并归档时间轴'
    ))
    list.push(WeeklyChallengeItem.of(
      '精力与行动对齐',
      '先完成今日仪式，再只做一件最重要的事。',
      '完成一次今日成长仪式',
      '把仪式里的那件事写成目标步骤',
      '当天勾掉第一步'
    ))
    return list
  }

  static of(title: string, summary: string, step1: string, step2: string, step3: string): WeeklyChallengeItem {
    const item = new WeeklyChallengeItem()
    item.title = title
    item.summary = summary
    item.step1 = step1
    item.step2 = step2
    item.step3 = step3
    return item
  }
}
