import { MoveItem } from '../models/TuceModels'

/** 内置动作图鉴（商户目录，非用户假数据） */
export class MoveLibrary {
  static categories(): string[] {
    return ['热身', '拉伸', '有氧', '力量', '核心', '柔韧', '平衡', '放松']
  }

  static coverKeyOf(category: string): string {
    if (category === '热身') {
      return 'warmup'
    }
    if (category === '拉伸') {
      return 'stretch'
    }
    if (category === '有氧') {
      return 'cardio'
    }
    if (category === '力量') {
      return 'strength'
    }
    if (category === '核心') {
      return 'core'
    }
    if (category === '柔韧') {
      return 'flex'
    }
    if (category === '平衡') {
      return 'balance'
    }
    return 'relax'
  }

  static all(): MoveItem[] {
    const out: MoveItem[] = []
    MoveLibrary.push(out, 'm01', '开合热身', '热身', '全身', '入门', 5, '双脚开合、手臂上举，把心率慢慢带起来。', '膝盖微屈，落地轻柔。')
    MoveLibrary.push(out, 'm02', '颈部绕环', '热身', '肩颈', '入门', 3, '缓慢画圈，唤醒颈椎与肩带。', '避开疼痛角度，不要快速甩头。')
    MoveLibrary.push(out, 'm03', '踝关节画圈', '热身', '下肢', '入门', 3, '单脚点地，脚踝顺时针再逆时针。', '站稳后再画圈。')
    MoveLibrary.push(out, 'm04', '腿后侧拉伸', '拉伸', '腿后侧', '入门', 4, '前倾时保持腰背延展，感受腿后侧拉长。', '膝盖微屈，不要弹振。')
    MoveLibrary.push(out, 'm05', '胸部开门拉伸', '拉伸', '胸肩', '入门', 4, '侧手扶墙，身体缓慢旋转打开含胸。', '肩胛下沉，呼吸放慢。')
    MoveLibrary.push(out, 'm06', '髋部开合', '拉伸', '髋部', '入门', 5, '弓步下沉，打开髋关节活动度。', '前膝不超过脚尖过多。')
    MoveLibrary.push(out, 'm07', '原地高抬腿', '有氧', '下肢', '进阶', 8, '提膝至髋高，摆臂带动节奏。', '核心收紧，避免塌腰。')
    MoveLibrary.push(out, 'm08', '开合跳', '有氧', '全身', '进阶', 6, '跳起开合，落地缓冲。', '关节不适时改为步进开合。')
    MoveLibrary.push(out, 'm09', '原地慢跑', '有氧', '心肺', '入门', 10, '轻快原地跑，保持鼻吸口呼。', '脚掌过渡落地。')
    MoveLibrary.push(out, 'm10', '徒手深蹲', '力量', '臀腿', '入门', 8, '髋后坐，膝随脚尖方向，起身夹臀。', '脚跟压实，膝盖不要内扣。')
    MoveLibrary.push(out, 'm11', '靠墙静蹲', '力量', '股四头', '入门', 5, '背靠墙下滑至大腿接近水平。', '膝盖不超过脚尖过多。')
    MoveLibrary.push(out, 'm12', '臀桥', '力量', '臀', '入门', 6, '仰卧屈膝，髋向上推起再缓慢落下。', '用臀发力，不要用腰硬撑。')
    MoveLibrary.push(out, 'm13', '平板支撑', '核心', '核心', '进阶', 4, '肘撑或直臂撑，身体一条直线。', '不要塌腰或耸肩。')
    MoveLibrary.push(out, 'm14', '死虫式', '核心', '核心', '入门', 5, '仰卧对侧手脚交替伸展，腰贴地。', '腰一离开地面就缩小幅度。')
    MoveLibrary.push(out, 'm15', '卷腹', '核心', '腹直肌', '入门', 5, '呼气卷起肩胛，吸气缓慢落下。', '不要用手猛拉脖子。')
    MoveLibrary.push(out, 'm16', '坐姿体前屈', '柔韧', '腿后侧', '入门', 5, '坐姿伸腿，躯干前送。', '以髋为轴，不要弓背硬压。')
    MoveLibrary.push(out, 'm17', '猫牛式', '柔韧', '脊柱', '入门', 4, '四点支撑，交替弓背与塌腰。', '跟随呼吸，动作匀速。')
    MoveLibrary.push(out, 'm18', '侧腰伸展', '柔韧', '侧腰', '入门', 4, '站立侧屈，另一手过头。', '骨盆保持中立。')
    MoveLibrary.push(out, 'm19', '单脚站立', '平衡', '踝稳定', '入门', 3, '单脚站立，目光看前方固定点。', '靠近墙面保护。')
    MoveLibrary.push(out, 'm20', '足跟对足尖走', '平衡', '全身', '入门', 3, '像走钢丝一样直线行走。', '抬头看前方。')
    MoveLibrary.push(out, 'm21', '燕式平衡预备', '平衡', '臀后链', '进阶', 4, '单腿后伸，躯干前倾成一条线。', '幅度以能稳住为准。')
    MoveLibrary.push(out, 'm22', '仰卧放松呼吸', '放松', '呼吸', '入门', 6, '仰卧，腹式呼吸，训练后收尾。', '环境安静即可。')
    MoveLibrary.push(out, 'm23', '肩颈放松', '放松', '肩颈', '入门', 4, '缓慢转肩、点头与侧屈。', '力度轻柔。')
    MoveLibrary.push(out, 'm24', '全身扫描放松', '放松', '全身', '入门', 8, '从脚到头依次放松，配合呼气。', '不必追求空念，跟着身体走。')
    MoveLibrary.push(out, 'm25', '波比跳', '有氧', '全身', '进阶', 6, '深蹲、撑地、收腿、跳跃连贯完成。', '腰背痛或膝不适时跳过跳跃。')
    MoveLibrary.push(out, 'm26', '登山跑', '有氧', '核心', '进阶', 5, '平板位交替提膝，保持肩在腕上方。', '不要塌腰，节奏可控。')
    MoveLibrary.push(out, 'm27', '侧平板', '核心', '侧腹', '进阶', 4, '侧撑身体成直线，髋不沉。', '可屈膝降低难度。')
    MoveLibrary.push(out, 'm28', '弓步蹲', '力量', '臀腿', '入门', 8, '前后脚分步，下沉时前膝对齐脚尖。', '保持躯干直立。')
    MoveLibrary.push(out, 'm29', '俯卧撑', '力量', '胸肩', '进阶', 6, '身体一条线，肘约 45° 夹角。', '可跪姿降低难度。')
    MoveLibrary.push(out, 'm30', '婴儿式', '放松', '腰背', '入门', 5, '跪坐，额头触地，手臂前伸或侧放。', '呼吸放慢。')
    MoveLibrary.push(out, 'm31', '树式平衡', '平衡', '下肢', '入门', 4, '单脚站立，另一脚贴小腿或大腿内侧。', '不要贴膝关节。')
    MoveLibrary.push(out, 'm32', '动态弓步拉伸', '拉伸', '髋部', '入门', 5, '弓步位前后轻微弹动，打开髋屈肌。', '幅度小、可控。')
    return out
  }

  static byCategory(category: string): MoveItem[] {
    const out: MoveItem[] = []
    const all = MoveLibrary.all()
    for (const m of all) {
      if (m.category === category) {
        out.push(m)
      }
    }
    return out
  }

  static find(id: string): MoveItem | undefined {
    const all = MoveLibrary.all()
    for (const m of all) {
      if (m.id === id) {
        return m
      }
    }
    return undefined
  }

  static namesOf(idsRaw: string): string {
    const ids = MoveLibrary.splitIds(idsRaw)
    const names: string[] = []
    for (const id of ids) {
      const m = MoveLibrary.find(id)
      if (m !== undefined) {
        names.push(m.name)
      }
    }
    return names.join(' → ')
  }

  static splitIds(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    return raw.split('|')
  }

  static joinIds(ids: string[]): string {
    return ids.join('|')
  }

  private static push(out: MoveItem[], id: string, name: string, cat: string, part: string,
    level: string, minutes: number, summary: string, caution: string): void {
    const m = new MoveItem()
    m.id = id
    m.name = name
    m.category = cat
    m.bodyPart = part
    m.level = level
    m.minutes = minutes
    m.summary = summary
    m.caution = caution
    m.coverKey = MoveLibrary.coverKeyOf(cat)
    out.push(m)
  }
}
