import { PingzeCell } from '../models/CourtyardModels'

/** 规则格律引擎：平仄字典 + 韵脚位置，不调用大模型 */
export class PingzeEngine {
  private static readonly PING =
    '东冬钟江支微鱼虞齐佳灰真文元寒删先萧宵肴豪歌麻阳庚青蒸尤侵覃盐咸' +
    '平明青清明风花春山天云人年前来时开怀才台梅杯回催雷堆' +
    '东中终忠虫崇嵩丰风枫丰空公工功宫弓躬红洪鸿虹丛从容蓉溶松龙笼隆' +
    '江窗双邦缸降' +
    '支枝移为垂吹陂碑奇宜仪皮儿施知驰池驰诗师狮时迟持棋期其旗欺' +
    '微薇晖辉韦围飞非妃肥归衣依威巍' +
    '鱼渔初书舒居裾车渠余予誉舆驴闾' +
    '虞愚娱隅区驱朱珠株诛殊铢瑜于于无芜巫吴吾梧' +
    '齐西栖犀妻凄啼蹄鼙' +
    '佳街鞋牌' +
    '灰杯回梅枚媒雷堆开哀埃台苔才材财裁来莱灾猜' +
    '真因茵辛新薪晨辰臣人仁神亲身宾滨贫民邻鳞巾银' +
    '文闻云氛分群军裙' +
    '元原源园猿辕烦繁萱喧冤言轩' +
    '寒韩丹单安难餐滩坛残看刊丸端酸官冠宽欢' +
    '删关弯还山闲艰颜' +
    '先前千阡笺天坚肩贤弦烟燕莲田年眠船边烟千' +
    '萧宵消宵迢条调貂' +
    '豪高膏羔刀桃逃涛袍毛毫曹槽' +
    '歌多罗河何荷柯科戈过波坡颇磨' +
    '麻花家霞纱车遮嗟斜' +
    '阳杨扬香乡光昌堂章张王房霜翔方芳妨亡忘望长常场肠黄皇簧' +
    '庚更羹盲横英平评京惊荆明盟鸣荣生甥笙清情晴精睛菁' +
    '青经形刑庭亭丁星醒' +
    '蒸陵凌冰凭绳升兴应' +
    '尤邮优忧流留榴秋楸舟州洲游楼侯谋眸' +
    '侵林心琴寻深金今音阴吟' +
    '覃南男耽含涵' +
    '盐檐严帘尖纤' +
    '咸缄岩衫'

  private static readonly ZE =
    '上去入仄' +
    '月雪白石北国一八七十出客黑竹木玉叶血尺尺策' +
    '上赏想响晓了少鸟扰表秒秒秒秒渺' +
    '去暮路树赋雾度故故故故故故故故故故' +
    '尽近信问恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨恨' +
    '夜谢榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭榭' +
    '是此子纸水里起已矣耳尔迩' +
    '有酒手守口后走狗柳九久' +
    '者野也马把下夏' +
    '可火我左果朵' +
    '语雨与女许吕旅' +
    '暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮暮' +
    '望向唱怅帐将将将将将将将将将将将将将将将将将将将将将将将将将将将将' +
    '送梦弄凤洞众' +
    '送动冻痛众' +
    '问恨闷困阵' +
    '愿怨远晚反返' +
    '汉难炭岸看' +
    '霰县练电殿' +
    '啸笑照耀调' +
    '效教貌闹' +
    '号到告操' +
    '个过破卧' +
    '禡驾化' +
    '漾样状壮' +
    '敬命姓盛' +
    '径定听' +
    '沁禁任' +
    '勘暗' +
    '艳艳艳' +
    '陷鉴' +
    '屋木竹目服福谷' +
    '沃玉欲浴' +
    '觉角岳乐' +
    '质日一乙笔' +
    '物佛屈' +
    '月越阙' +
    '曷达末' +
    '黠八杀' +
    '屑结血' +
    '药略若' +
    '陌白石客' +
    '锡击历' +
    '职国色' +
    '缉入十' +
    '合答杂' +
    '叶接蝶' +
    '洽狭' +
    '不又亦已以与于于于于于于于于于于于于于于于于于于于于于于于于于于于' +
    '对在再最会外快' +
    '更更更更更更更更更更更更更更更更更更更更更更更更更更更更更更更更'

  static analyze(text: string): PingzeCell[] {
    const cells: PingzeCell[] = []
    const lines = PingzeEngine.splitLines(text)
    for (let li = 0; li < lines.length; li++) {
      const line = lines[li]
      const hans = PingzeEngine.hanChars(line)
      for (let i = 0; i < hans.length; i++) {
        const cell = new PingzeCell()
        cell.idx = cells.length
        cell.ch = hans[i]
        cell.mark = PingzeEngine.markOf(hans[i])
        cell.isRhyme = (li % 2 === 1) && i === hans.length - 1 && hans.length > 0
        cells.push(cell)
      }
      if (li < lines.length - 1) {
        const br = new PingzeCell()
        br.idx = cells.length
        br.ch = '\n'
        br.mark = ''
        br.isRhyme = false
        cells.push(br)
      }
    }
    return cells
  }

  static summary(cells: PingzeCell[]): string {
    let ping = 0
    let ze = 0
    let unknown = 0
    const rhymes: string[] = []
    for (const c of cells) {
      if (c.ch === '\n') {
        continue
      }
      if (c.mark === '平') {
        ping += 1
      } else if (c.mark === '仄') {
        ze += 1
      } else {
        unknown += 1
      }
      if (c.isRhyme) {
        rhymes.push(`${c.ch}(${c.mark})`)
      }
    }
    const rhymeText = rhymes.length > 0 ? rhymes.join('、') : '未标出'
    return `平 ${ping} · 仄 ${ze} · 未识 ${unknown}；韵脚 ${rhymeText}`
  }

  static coupletHint(text: string): string {
    const lines = PingzeEngine.splitLines(text)
    if (lines.length < 2) {
      return '至少两句才能看对仗参考。五律中两联宜字数相同、词性相对。'
    }
    const a = PingzeEngine.hanChars(lines[0]).length
    const b = PingzeEngine.hanChars(lines[1]).length
    if (a === b && a >= 5) {
      return `首联字数相同（${a}），可试对仗：名词对名词、颜色对颜色。不必强求工对。`
    }
    return `两句字数 ${a} / ${b}。近体一联宜等长。`
  }

  static rhymeHint(cells: PingzeCell[]): string {
    const rhymes: string[] = []
    for (const c of cells) {
      if (c.isRhyme) {
        rhymes.push(c.ch)
      }
    }
    if (rhymes.length === 0) {
      return '偶句末字将作为韵脚提示。可到韵典页对照平水韵、词林正韵或中华新韵。'
    }
    return `韵脚字：${rhymes.join('、')}。近体诗用平水韵；填词可查词林正韵；今韵习作用中华新韵。`
  }

  private static markOf(ch: string): string {
    if (PingzeEngine.PING.indexOf(ch) >= 0) {
      return '平'
    }
    if (PingzeEngine.ZE.indexOf(ch) >= 0) {
      return '仄'
    }
    return '中'
  }

  private static splitLines(text: string): string[] {
    const buf: string[] = []
    let cur = ''
    for (let i = 0; i < text.length; i++) {
      const ch = text.substring(i, i + 1)
      if (ch === '\n' || ch === '。' || ch === '？' || ch === '！' || ch === '?' || ch === '!') {
        const t = cur.trim()
        if (t.length > 0) {
          buf.push(t)
        }
        cur = ''
      } else {
        cur += ch
      }
    }
    const last = cur.trim()
    if (last.length > 0) {
      buf.push(last)
    }
    return buf
  }

  private static hanChars(line: string): string[] {
    const out: string[] = []
    for (let i = 0; i < line.length; i++) {
      const code = line.charCodeAt(i)
      if (code >= 0x4e00 && code <= 0x9fff) {
        out.push(line.substring(i, i + 1))
      }
    }
    return out
  }
}
