import { PresetPack } from '../models/TuceModels'

/** 精选训练课（场景化模板，非用户假数据） */
export class PresetLibrary {
  static scenes(): string[] {
    return ['全部', '居家', '办公室', '户外', '跑后', 'HIIT', '新手']
  }

  static all(): PresetPack[] {
    const out: PresetPack[] = []
    PresetLibrary.push(out, 'p01', '晨间唤醒组合', '居家', 15, '入门',
      '5 分钟唤醒心率，再进入轻力量与拉伸，适合工作日早晨。',
      'm01|m07|m10|m04', 25, 'warmup')
    PresetLibrary.push(out, 'p02', '办公室微运动', '办公室', 8, '入门',
      '肩颈、侧腰与放松，久坐间隙可完成，无需器械与大面积空间。',
      'm02|m05|m18|m23', 20, 'stretch')
    PresetLibrary.push(out, 'p03', '跑后放松恢复', '跑后', 12, '入门',
      '跑后腿后侧、髋部与呼吸放松，帮助从高强度平稳过渡到恢复。',
      'm04|m06|m16|m22', 30, 'relax')
    PresetLibrary.push(out, 'p04', '核心强化课', '居家', 18, '进阶',
      '平板、死虫、卷腹与侧平板，质量优先于次数。',
      'm13|m14|m15|m27', 35, 'core')
    PresetLibrary.push(out, 'p05', 'HIIT 燃脂循环', 'HIIT', 20, '进阶',
      '开合跳、波比、登山跑与深蹲循环，心率高但可自控节奏。',
      'm08|m25|m26|m10', 40, 'cardio')
    PresetLibrary.push(out, 'p06', '新手全身入门', '新手', 20, '入门',
      '从热身、慢跑、深蹲到放松，建立每周 2–3 次的基础习惯。',
      'm01|m09|m10|m12|m22', 30, 'warmup')
    PresetLibrary.push(out, 'p07', '平衡稳定训练', '户外', 12, '入门',
      '单脚站、足跟对足尖与树式，提升踝膝稳定与本体感觉。',
      'm19|m20|m21|m31', 25, 'balance')
    PresetLibrary.push(out, 'p08', '柔韧延展课', '居家', 15, '入门',
      '腿后侧、胸肩、猫牛与侧腰，适合训练后或晚间拉伸。',
      'm04|m05|m16|m17|m18', 25, 'flex')
    PresetLibrary.push(out, 'p09', '力量基础课', '居家', 25, '进阶',
      '深蹲、静蹲、臀桥、弓步与俯卧撑，可在家完成的力量循环。',
      'm10|m11|m12|m28|m29', 45, 'strength')
    PresetLibrary.push(out, 'p10', '睡前舒缓课', '居家', 12, '入门',
      '猫牛、婴儿式、呼吸与全身扫描，帮助从训练日切换到休息。',
      'm17|m30|m22|m24', 20, 'relax')
    PresetLibrary.push(out, 'p11', '午间活力 10 分', '办公室', 10, '入门',
      '高抬腿、开合跳与肩颈放松，快速激活下午状态。',
      'm07|m08|m23', 25, 'cardio')
    PresetLibrary.push(out, 'p12', '户外热身包', '户外', 10, '入门',
      '踝、颈、开合与高抬腿，跑步或徒步前的标准热身序列。',
      'm03|m02|m01|m07', 20, 'warmup')
    return out
  }

  static find(id: string): PresetPack | undefined {
    for (const p of PresetLibrary.all()) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static byScene(scene: string): PresetPack[] {
    if (scene === '全部') {
      return PresetLibrary.all()
    }
    const out: PresetPack[] = []
    for (const p of PresetLibrary.all()) {
      if (p.scene === scene) {
        out.push(p)
      }
    }
    return out
  }

  static idsJoin(ids: string[]): string {
    return ids.join('|')
  }

  private static push(out: PresetPack[], id: string, name: string, scene: string, minutes: number,
    level: string, summary: string, moveIds: string, restSec: number, coverKey: string): void {
    const p = new PresetPack()
    p.id = id
    p.name = name
    p.scene = scene
    p.minutes = minutes
    p.level = level
    p.summary = summary
    p.moveIds = moveIds
    p.restSec = restSec
    p.coverKey = coverKey
    out.push(p)
  }
}
