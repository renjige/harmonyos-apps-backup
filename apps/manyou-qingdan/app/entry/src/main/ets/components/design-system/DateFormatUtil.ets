/** 预约/表单日期时间格式化（ArkTS 安全，禁止裸对象字面量） */
export class DateFormatUtil {
  static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static formatDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${y}-${DateFormatUtil.pad2(m)}-${DateFormatUtil.pad2(day)}`
  }

  static formatTime(d: Date): string {
    return `${DateFormatUtil.pad2(d.getHours())}:${DateFormatUtil.pad2(d.getMinutes())}`
  }

  static formatTimeResult(value: TimePickerResult): string {
    return `${DateFormatUtil.pad2(value.hour)}:${DateFormatUtil.pad2(value.minute)}`
  }

  static parseDate(text: string): Date {
    const parts = text.split('-')
    if (parts.length === 3) {
      const y = Number.parseInt(parts[0], 10)
      const m = Number.parseInt(parts[1], 10)
      const day = Number.parseInt(parts[2], 10)
      if (!Number.isNaN(y) && !Number.isNaN(m) && !Number.isNaN(day)) {
        return new Date(y, m - 1, day)
      }
    }
    return DateFormatUtil.todayStart()
  }

  static parseTime(text: string): Date {
    const base = DateFormatUtil.todayStart()
    const parts = text.split(':')
    if (parts.length >= 2) {
      const h = Number.parseInt(parts[0], 10)
      const min = Number.parseInt(parts[1], 10)
      if (!Number.isNaN(h) && !Number.isNaN(min)) {
        base.setHours(h, min, 0, 0)
      }
    }
    return base
  }

  static todayStart(): Date {
    const d = new Date()
    d.setHours(0, 0, 0, 0)
    return d
  }

  static addDays(base: Date, days: number): Date {
    const d = new Date(base.getTime())
    d.setDate(d.getDate() + days)
    return d
  }
}

class CalendarDialogOpts {
  selected: Date = new Date()
  start: Date = new Date()
  end: Date = new Date()
  onAccept: (value: Date) => void = () => {}
}

export class DatePickerLauncher {
  static openDate(
    current: string,
    minDaysFromToday: number,
    maxDaysFromToday: number,
    onPicked: (value: string) => void
  ): void {
    const today = DateFormatUtil.todayStart()
    const opts = new CalendarDialogOpts()
    opts.selected = current.length > 0 ? DateFormatUtil.parseDate(current) : today
    opts.start = DateFormatUtil.addDays(today, minDaysFromToday)
    opts.end = DateFormatUtil.addDays(today, maxDaysFromToday)
    opts.onAccept = (value: Date) => {
      onPicked(DateFormatUtil.formatDate(value))
    }
    CalendarPickerDialog.show(opts)
  }

  static openTime(current: string, onPicked: (value: string) => void): void {
    const opts = new TimeDialogOpts()
    opts.selected = current.length > 0 ? DateFormatUtil.parseTime(current) : DateFormatUtil.parseTime('09:00')
    opts.useMilitaryTime = true
    opts.onAccept = (value: TimePickerResult) => {
      onPicked(DateFormatUtil.formatTimeResult(value))
    }
    TimePickerDialog.show(opts)
  }
}

class TimeDialogOpts {
  selected: Date = new Date()
  useMilitaryTime: boolean = true
  onAccept: (value: TimePickerResult) => void = () => {}
}
