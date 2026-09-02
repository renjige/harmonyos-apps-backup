/** 按公历近似日期推算当前节气（与平台 seed 日期段对齐） */

class TermStart {
  id: string = ''
  name: string = ''
  md: number = 0

  constructor(id: string, name: string, md: number) {
    this.id = id
    this.name = name
    this.md = md
  }
}

export class SolarTermUtil {
  private static readonly STARTS: TermStart[] = [
    new TermStart('st_xiaohan', '小寒', 105),
    new TermStart('st_dahan', '大寒', 120),
    new TermStart('st_lichun', '立春', 203),
    new TermStart('st_yushui', '雨水', 218),
    new TermStart('st_jingzhe', '惊蛰', 305),
    new TermStart('st_chunfen', '春分', 320),
    new TermStart('st_qingming', '清明', 405),
    new TermStart('st_guyu', '谷雨', 420),
    new TermStart('st_lixia', '立夏', 505),
    new TermStart('st_xiaoman', '小满', 521),
    new TermStart('st_mangzhong', '芒种', 606),
    new TermStart('st_xiazhi', '夏至', 621),
    new TermStart('st_xiaoshu', '小暑', 707),
    new TermStart('st_dashu', '大暑', 722),
    new TermStart('st_liqiu', '立秋', 807),
    new TermStart('st_chushu', '处暑', 823),
    new TermStart('st_bailu', '白露', 908),
    new TermStart('st_qiufen', '秋分', 923),
    new TermStart('st_hanlu', '寒露', 1008),
    new TermStart('st_shuangjiang', '霜降', 1023),
    new TermStart('st_lidong', '立冬', 1107),
    new TermStart('st_xiaoxue', '小雪', 1122),
    new TermStart('st_daxue', '大雪', 1207),
    new TermStart('st_dongzhi', '冬至', 1221),
  ]

  static monthDay(): number {
    const now = new Date()
    return (now.getMonth() + 1) * 100 + now.getDate()
  }

  static currentTermId(): string {
    const md = SolarTermUtil.monthDay()
    let current = SolarTermUtil.STARTS[SolarTermUtil.STARTS.length - 1]
    if (md < SolarTermUtil.STARTS[0].md) {
      return current.id
    }
    for (const t of SolarTermUtil.STARTS) {
      if (md >= t.md) {
        current = t
      }
    }
    return current.id
  }

  static currentTermName(): string {
    const id = SolarTermUtil.currentTermId()
    for (const t of SolarTermUtil.STARTS) {
      if (t.id === id) {
        return t.name
      }
    }
    return '节气'
  }

  static isCurrentTerm(termId: string): boolean {
    return termId === SolarTermUtil.currentTermId()
  }
}
