import { AppointmentItem, GapSlot, NextHint, PrepItem, WeekDigest, FreeSlot, MonthInsights } from '../models/AppointmentModels'
import { AppointmentLocalStore } from './AppointmentLocalStore'

export class ScheduleEngine {
  static weekdayLabel(iso: string): string {
    if (iso.length < 10) {
      return ''
    }
    const y = parseInt(iso.slice(0, 4), 10)
    const m = parseInt(iso.slice(5, 7), 10)
    const d = parseInt(iso.slice(8, 10), 10)
    const dt = new Date(y, m - 1, d)
    const names: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    const idx = dt.getDay()
    if (idx >= 0 && idx < names.length) {
      return names[idx]
    }
    return ''
  }

  static todayLongLabel(): string {
    const iso = AppointmentLocalStore.today()
    return `${iso.slice(5, 7)}月${iso.slice(8, 10)}日 ${ScheduleEngine.weekdayLabel(iso)}`
  }

  static timeToMinutes(time: string): number {
    if (time.length < 5) {
      return 9 * 60
    }
    const h = parseInt(time.slice(0, 2), 10)
    const min = parseInt(time.slice(3, 5), 10)
    if (Number.isNaN(h) || Number.isNaN(min)) {
      return 9 * 60
    }
    return h * 60 + min
  }

  static minutesToTime(total: number): string {
    let t = total
    while (t < 0) {
      t += 24 * 60
    }
    const h = Math.floor((t % (24 * 60)) / 60)
    const m = t % 60
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${hs}:${ms}`
  }

  static addDays(iso: string, days: number): string {
    const y = parseInt(iso.slice(0, 4), 10)
    const m = parseInt(iso.slice(5, 7), 10)
    const d = parseInt(iso.slice(8, 10), 10)
    const dt = new Date(y, m - 1, d + days)
    const mm = dt.getMonth() + 1
    const dd = dt.getDate()
    const ms = mm < 10 ? `0${mm}` : `${mm}`
    const ds = dd < 10 ? `0${dd}` : `${dd}`
    return `${dt.getFullYear()}-${ms}-${ds}`
  }

  static classifyScene(title: string, note: string): string {
    const text = `${title}${note}`
    if (text.indexOf('会') >= 0 || text.indexOf('汇报') >= 0 || text.indexOf('客户') >= 0 ||
      text.indexOf('面试') >= 0 || text.indexOf('项目') >= 0) {
      return 'work'
    }
    if (text.indexOf('学习') >= 0 || text.indexOf('课') >= 0 || text.indexOf('阅读') >= 0 ||
      text.indexOf('复习') >= 0) {
      return 'study'
    }
    if (text.indexOf('健身') >= 0 || text.indexOf('跑步') >= 0 || text.indexOf('医院') >= 0 ||
      text.indexOf('体检') >= 0 || text.indexOf('运动') >= 0) {
      return 'health'
    }
    if (text.indexOf('生日') >= 0 || text.indexOf('接') >= 0 || text.indexOf('家') >= 0 ||
      text.indexOf('饭') >= 0 || text.indexOf('还款') >= 0) {
      return 'life'
    }
    return 'life'
  }

  static defaultPrep(scene: string): string {
    if (scene === 'work') {
      return '确认议题|带好材料|提前五分钟到'
    }
    if (scene === 'study') {
      return '准备资料|找安静环境|关闭通知'
    }
    if (scene === 'health') {
      return '带好装备|预留热身|补充水分'
    }
    return '确认地点|预留路上时间|通知相关的人'
  }

  static prepItems(item: AppointmentItem): PrepItem[] {
    const out: PrepItem[] = []
    if (item.prepLine.length === 0) {
      return out
    }
    const names = item.prepLine.split('|')
    for (let i = 0; i < names.length; i++) {
      const row = new PrepItem()
      row.name = names[i]
      row.index = i
      row.done = i < item.prepMask.length && item.prepMask.slice(i, i + 1) === '1'
      out.push(row)
    }
    return out
  }

  static toggleMask(mask: string, index: number, total: number): string {
    let next = ''
    for (let i = 0; i < total; i++) {
      let ch = i < mask.length ? mask.slice(i, i + 1) : '0'
      if (i === index) {
        ch = ch === '1' ? '0' : '1'
      }
      next = `${next}${ch}`
    }
    return next
  }

  static prepProgress(item: AppointmentItem): string {
    const list = ScheduleEngine.prepItems(item)
    if (list.length === 0) {
      return ''
    }
    let done = 0
    for (const row of list) {
      if (row.done) {
        done += 1
      }
    }
    return `准备 ${done}/${list.length}`
  }

  static overlaps(a: AppointmentItem, b: AppointmentItem): boolean {
    if (a.id === b.id || a.dueDate !== b.dueDate) {
      return false
    }
    if (a.isDone() || b.isDone()) {
      return false
    }
    const a0 = ScheduleEngine.timeToMinutes(a.dueTime)
    const a1 = a0 + a.durationMin
    const b0 = ScheduleEngine.timeToMinutes(b.dueTime)
    const b1 = b0 + b.durationMin
    return a0 < b1 && b0 < a1
  }

  static conflictsOf(item: AppointmentItem, all: AppointmentItem[]): AppointmentItem[] {
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (ScheduleEngine.overlaps(item, row)) {
        out.push(row)
      }
    }
    return out
  }

  static conflictCount(all: AppointmentItem[]): number {
    let count = 0
    for (let i = 0; i < all.length; i++) {
      for (let j = i + 1; j < all.length; j++) {
        if (ScheduleEngine.overlaps(all[i], all[j])) {
          count += 1
        }
      }
    }
    return count
  }

  static nextHint(all: AppointmentItem[]): NextHint {
    const hint = new NextHint()
    const today = AppointmentLocalStore.today()
    const now = new Date()
    const nowMin = now.getHours() * 60 + now.getMinutes()
    let best: AppointmentItem | undefined = undefined
    let bestScore = 999999
    for (const row of all) {
      if (row.isDone() || row.dueDate < today) {
        continue
      }
      let score = ScheduleEngine.timeToMinutes(row.dueTime)
      if (row.dueDate > today) {
        score += 24 * 60 * 8
      } else if (score < nowMin) {
        continue
      }
      if (score < bestScore) {
        bestScore = score
        best = row
      }
    }
    if (best === undefined) {
      hint.countdown = '今日约定已全部完成'
      return hint
    }
    hint.hasNext = true
    hint.title = best.title
    hint.id = best.id
    hint.timeLabel = best.timeRangeLabel()
    if (best.dueDate === today) {
      const left = ScheduleEngine.timeToMinutes(best.dueTime) - nowMin
      if (left < 60) {
        hint.countdown = `${left} 分钟后开始`
      } else {
        hint.countdown = `${Math.floor(left / 60)} 小时 ${left % 60} 分后开始`
      }
    } else {
      hint.countdown = `${best.dueDate} ${best.dueTime}`
    }
    return hint
  }

  static idleGaps(todayItems: AppointmentItem[]): GapSlot[] {
    const pending: AppointmentItem[] = []
    for (const row of todayItems) {
      if (!row.isDone()) {
        pending.push(row)
      }
    }
    const out: GapSlot[] = []
    if (pending.length === 0) {
      const g = new GapSlot()
      g.start = '09:00'
      g.end = '18:00'
      g.label = '今天日程空着，适合安排一件重要的事'
      out.push(g)
      return out
    }
    const sorted: AppointmentItem[] = []
    for (const row of pending) {
      sorted.push(row)
    }
    for (let i = 0; i < sorted.length; i++) {
      for (let j = i + 1; j < sorted.length; j++) {
        if (ScheduleEngine.timeToMinutes(sorted[i].dueTime) > ScheduleEngine.timeToMinutes(sorted[j].dueTime)) {
          const tmp = sorted[i]
          sorted[i] = sorted[j]
          sorted[j] = tmp
        }
      }
    }
    let cursor = 8 * 60
    for (const row of sorted) {
      const start = ScheduleEngine.timeToMinutes(row.dueTime)
      if (start - cursor >= 45) {
        const g = new GapSlot()
        g.start = ScheduleEngine.minutesToTime(cursor)
        g.end = ScheduleEngine.minutesToTime(start)
        g.label = `${g.start}–${g.end} 有空档，可安排准备或休息`
        out.push(g)
      }
      const end = start + row.durationMin
      if (end > cursor) {
        cursor = end
      }
    }
    if (18 * 60 - cursor >= 45) {
      const g = new GapSlot()
      g.start = ScheduleEngine.minutesToTime(cursor)
      g.end = '18:00'
      g.label = `${g.start} 之后较从容，适合复盘或运动`
      out.push(g)
    }
    const limited: GapSlot[] = []
    for (let i = 0; i < out.length && i < 2; i++) {
      limited.push(out[i])
    }
    return limited
  }

  static shift(date: string, time: string, addMin: number): AppointmentItem {
    const row = new AppointmentItem()
    let total = ScheduleEngine.timeToMinutes(time) + addMin
    let dayDelta = 0
    while (total >= 24 * 60) {
      total -= 24 * 60
      dayDelta += 1
    }
    while (total < 0) {
      total += 24 * 60
      dayDelta -= 1
    }
    row.dueDate = ScheduleEngine.addDays(date, dayDelta)
    row.dueTime = ScheduleEngine.minutesToTime(total)
    return row
  }

  static matchesQuery(item: AppointmentItem, q: string): boolean {
    if (q.length === 0) {
      return true
    }
    const hay = `${item.title}${item.note}${item.place}${item.contactName}${item.sceneLabel()}`
    return hay.indexOf(q) >= 0
  }

  static sortPinned(rows: AppointmentItem[]): AppointmentItem[] {
    const pin: AppointmentItem[] = []
    const rest: AppointmentItem[] = []
    for (const row of rows) {
      if (row.pinned) {
        pin.push(row)
      } else {
        rest.push(row)
      }
    }
    const out: AppointmentItem[] = []
    for (const row of pin) {
      out.push(row)
    }
    for (const row of rest) {
      out.push(row)
    }
    return out
  }

  static weekStartIso(): string {
    const today = AppointmentLocalStore.today()
    const names = ScheduleEngine.weekdayLabel(today)
    let back = 0
    if (names === '周一') {
      back = 0
    } else if (names === '周二') {
      back = 1
    } else if (names === '周三') {
      back = 2
    } else if (names === '周四') {
      back = 3
    } else if (names === '周五') {
      back = 4
    } else if (names === '周六') {
      back = 5
    } else {
      back = 6
    }
    return ScheduleEngine.addDays(today, -back)
  }

  static digest(all: AppointmentItem[]): WeekDigest {
    const d = new WeekDigest()
    const start = ScheduleEngine.weekStartIso()
    const end = ScheduleEngine.addDays(start, 6)
    const today = AppointmentLocalStore.today()
    const dayCount: number[] = [0, 0, 0, 0, 0, 0, 0]
    for (const row of all) {
      if (row.dueDate < start || row.dueDate > end) {
        continue
      }
      d.totalCount += 1
      if (row.isDone()) {
        d.doneCount += 1
      } else {
        d.pendingCount += 1
        if (row.dueDate < today) {
          d.missedCount += 1
        }
      }
      if (row.scene === 'work') {
        d.workCount += 1
      } else if (row.scene === 'study') {
        d.studyCount += 1
      } else if (row.scene === 'health') {
        d.healthCount += 1
      } else {
        d.lifeCount += 1
      }
      const wd = ScheduleEngine.weekdayLabel(row.dueDate)
      const idx = wd === '周一' ? 0 : wd === '周二' ? 1 : wd === '周三' ? 2 :
        wd === '周四' ? 3 : wd === '周五' ? 4 : wd === '周六' ? 5 : 6
      dayCount[idx] += 1
    }
    d.conflictCount = ScheduleEngine.conflictCount(all)
    if (d.totalCount === 0) {
      d.rateText = '—'
      d.suggestion = '本周还没有约定。从一次会议或学习计划开始，首页可一键创建。'
      return d
    }
    d.rateText = `${Math.round(d.doneCount * 100 / d.totalCount)}%`
    let busyIdx = 0
    let busyVal = 0
    for (let i = 0; i < 7; i++) {
      if (dayCount[i] > busyVal) {
        busyVal = dayCount[i]
        busyIdx = i
      }
    }
    const dayNames: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    d.busiestDay = busyVal > 0 ? `${dayNames[busyIdx]}（${busyVal} 件）` : '分布均匀'
    if (d.missedCount > 0) {
      d.suggestion = `有 ${d.missedCount} 件已过期未完成，建议改期或标记完成，避免堆积。`
    } else if (d.conflictCount > 0) {
      d.suggestion = '存在时间重叠。保存前可查看冲突提示，或把其中一件改到空档。'
    } else if (d.workCount > d.lifeCount + d.healthCount + 2) {
      d.suggestion = '工作约定偏多。可在空档加入运动或休息，保持节奏。'
    } else {
      d.suggestion = '本周节奏平稳。完成一件就勾选一件，守约记录会留在「已完成」。'
    }
    return d
  }

  static exportWeek(all: AppointmentItem[]): string {
    const start = ScheduleEngine.weekStartIso()
    const end = ScheduleEngine.addDays(start, 6)
    const digest = ScheduleEngine.digest(all)
    let text = `【约定提醒 · 本周安排】${start} 至 ${end}\n`
    text = `${text}完成 ${digest.doneCount}/${digest.totalCount} · 守约 ${digest.rateText}\n`
    for (const row of all) {
      if (row.dueDate < start || row.dueDate > end) {
        continue
      }
      const mark = row.isDone() ? '完成' : '待办'
      text = `${text}- ${row.dueDate} ${row.dueTime} ${row.title}（${mark}）\n`
    }
    text = `${text}${digest.suggestion}`
    return text
  }

  static nextRepeatDate(iso: string, repeatType: string): string {
    if (repeatType === 'daily') {
      return ScheduleEngine.addDays(iso, 1)
    }
    if (repeatType === 'weekly') {
      return ScheduleEngine.addDays(iso, 7)
    }
    if (repeatType === 'monthly') {
      const y = parseInt(iso.slice(0, 4), 10)
      const m = parseInt(iso.slice(5, 7), 10)
      const d = parseInt(iso.slice(8, 10), 10)
      const dt = new Date(y, m, d)
      const mm = dt.getMonth() + 1
      const dd = dt.getDate()
      const ms = mm < 10 ? `0${mm}` : `${mm}`
      const ds = dd < 10 ? `0${dd}` : `${dd}`
      return `${dt.getFullYear()}-${ms}-${ds}`
    }
    return iso
  }

  static leaveByLabel(item: AppointmentItem): string {
    if (item.dueTime.length < 5) {
      return ''
    }
    const leaveMin = ScheduleEngine.timeToMinutes(item.dueTime) - item.bufferMin
    if (leaveMin < 0) {
      return ''
    }
    return `建议 ${ScheduleEngine.minutesToTime(leaveMin)} 出发`
  }

  static suggestFreeSlots(item: AppointmentItem, all: AppointmentItem[], max: number): FreeSlot[] {
    const out: FreeSlot[] = []
    const date = item.dueDate.length > 0 ? item.dueDate : AppointmentLocalStore.today()
    const dayItems: AppointmentItem[] = []
    for (const row of all) {
      if (row.dueDate === date && !row.isDone() && row.id !== item.id) {
        dayItems.push(row)
      }
    }
    const candidates: number[] = [8 * 60 + 30, 10 * 60, 13 * 60 + 30, 15 * 60, 17 * 60]
    for (const start of candidates) {
      if (out.length >= max) {
        break
      }
      const probe = new AppointmentItem()
      probe.id = 'probe'
      probe.dueDate = date
      probe.dueTime = ScheduleEngine.minutesToTime(start)
      probe.durationMin = item.durationMin > 0 ? item.durationMin : 60
      let clash = false
      for (const row of dayItems) {
        if (ScheduleEngine.overlaps(probe, row)) {
          clash = true
          break
        }
      }
      if (!clash) {
        const slot = new FreeSlot()
        slot.date = date
        slot.time = probe.dueTime
        slot.label = `${date} ${probe.dueTime} 可安排`
        out.push(slot)
      }
    }
    if (out.length === 0) {
      const shifted = ScheduleEngine.shift(date, item.dueTime.length > 0 ? item.dueTime : '09:00', 60)
      const slot = new FreeSlot()
      slot.date = shifted.dueDate
      slot.time = shifted.dueTime
      slot.label = `${shifted.dueDate} ${shifted.dueTime} 顺延 1 小时`
      out.push(slot)
    }
    return out
  }

  static monthInsights(all: AppointmentItem[]): MonthInsights {
    const m = new MonthInsights()
    const today = AppointmentLocalStore.today()
    const start = ScheduleEngine.addDays(today, -29)
    const hourBuckets: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    const dayDone: boolean[] = []
    for (let i = 0; i < 30; i++) {
      dayDone.push(false)
    }
    for (const row of all) {
      if (row.dueDate < start || row.dueDate > today) {
        continue
      }
      m.totalCount += 1
      if (row.isDone()) {
        m.doneCount += 1
        const idx = ScheduleEngine.dayIndexFromStart(start, row.dueDate)
        if (idx >= 0 && idx < 30) {
          dayDone[idx] = true
        }
      }
      if (row.scene === 'work') {
        m.workCount += 1
      } else if (row.scene === 'study') {
        m.studyCount += 1
      } else if (row.scene === 'health') {
        m.healthCount += 1
      } else {
        m.lifeCount += 1
      }
      if (row.repeatType !== 'once' && !row.isDone()) {
        m.repeatActive += 1
      }
      if (row.dueTime.length >= 5) {
        const h = parseInt(row.dueTime.slice(0, 2), 10)
        if (!Number.isNaN(h) && h >= 0 && h < 12) {
          hourBuckets[h] += 1
        }
      }
    }
    if (m.totalCount > 0) {
      m.rateText = `${Math.round(m.doneCount * 100 / m.totalCount)}%`
    }
    let streak = 0
    for (let i = 29; i >= 0; i--) {
      if (dayDone[i]) {
        streak += 1
      } else if (streak > 0) {
        break
      }
    }
    m.streakDays = streak
    let bestH = 9
    let bestV = 0
    for (let h = 0; h < 12; h++) {
      if (hourBuckets[h] > bestV) {
        bestV = hourBuckets[h]
        bestH = h
      }
    }
    m.busiestHour = bestV > 0 ? `${bestH}:00–${bestH + 1}:00 段较集中` : '暂无规律'
    if (m.totalCount === 0) {
      m.suggestion = '近 30 天还没有记录。从一次会议或生活约定开始，首页可一键创建。'
    } else if (m.streakDays >= 3) {
      m.suggestion = `已连续 ${m.streakDays} 天有完成记录，保持节奏；可在场景中心查看各类约定分布。`
    } else if (m.repeatActive > 0) {
      m.suggestion = `有 ${m.repeatActive} 条重复约定进行中，完成后会自动生成下一周期。`
    } else if (m.workCount > m.lifeCount + m.healthCount + 3) {
      m.suggestion = '工作类偏多，建议在空档加入运动或休息，避免日程失衡。'
    } else {
      m.suggestion = '守约数据正常。可用智能整理调整节奏，或用冲突检测避免撞车。'
    }
    return m
  }

  private static dayIndexFromStart(start: string, iso: string): number {
    const sy = parseInt(start.slice(0, 4), 10)
    const sm = parseInt(start.slice(5, 7), 10)
    const sd = parseInt(start.slice(8, 10), 10)
    const ty = parseInt(iso.slice(0, 4), 10)
    const tm = parseInt(iso.slice(5, 7), 10)
    const td = parseInt(iso.slice(8, 10), 10)
    const s = new Date(sy, sm - 1, sd).getTime()
    const t = new Date(ty, tm - 1, td).getTime()
    const diff = Math.floor((t - s) / (24 * 60 * 60 * 1000))
    return diff
  }
}
