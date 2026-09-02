import { DailyPrompt } from '../models/WorkbenchModels'

/** 按日期轮换的记录提示，纯规则，不调用接口 */
export class DailyPromptService {
  static today(): DailyPrompt {
    const all = DailyPromptService.all()
    const d = new Date()
    const start = new Date(d.getFullYear(), 0, 0)
    const day = Math.floor((d.getTime() - start.getTime()) / 86400000)
    let idx = day % all.length
    if (idx < 0) {
      idx = 0
    }
    return all[idx]
  }

  static applyToCapture(): void {
    const p = DailyPromptService.today()
    DailyPromptService.applyPrompt(p)
  }

  static applyPrompt(p: DailyPrompt): void {
    AppStorage.setOrCreate('captureDraftTitle', p.title)
    AppStorage.setOrCreate('captureDraftBody', p.starter)
    AppStorage.setOrCreate('captureDraftTags', p.tag)
  }

  static applyCustom(title: string, body: string, tags: string): void {
    AppStorage.setOrCreate('captureDraftTitle', title)
    AppStorage.setOrCreate('captureDraftBody', body)
    AppStorage.setOrCreate('captureDraftTags', tags)
  }

  static requestEdit(id: string): void {
    AppStorage.setOrCreate('captureEditId', id)
  }

  static templates(): DailyPrompt[] {
    const list: DailyPrompt[] = []
    list.push(DailyPrompt.of('观察现场', '把眼前材质、光线、气味写成备忘。', '我看到：\n光线：\n材质：\n可复用在：', '观察, 现场'))
    list.push(DailyPrompt.of('配色便签', '记下停下来的一组颜色。', '主色：\n辅色：\n点缀：\n适合：包装 / 界面 / 空间', '配色, 视觉'))
    list.push(DailyPrompt.of('文案节奏', '收集一句可改写的节奏。', '原句：\n节奏：短-短-长 / 问句收尾\n我的改写：', '文案, 节奏'))
    list.push(DailyPrompt.of('构图草稿', '记下还没画完的画面。', '主体位置：\n留白给谁：\n下一步先画：', '构图, 画面'))
    return list
  }

  static requestOpenForm(): void {
    const n = AppStorage.get<number>('captureOpenNonce')
    const next = n !== undefined && n !== null ? n + 1 : 1
    AppStorage.setOrCreate('captureOpenNonce', next)
  }

  private static all(): DailyPrompt[] {
    const list: DailyPrompt[] = []
    list.push(DailyPrompt.of(
      '光线备忘',
      '观察一处光线变化，写成三句话。',
      '此刻的光：从哪里来，落在什么材质上，情绪更接近冷还是暖。',
      '观察, 光线'
    ))
    list.push(DailyPrompt.of(
      '停下来的配色',
      '记下让你驻足的一组颜色关系。',
      '主色 / 辅色 / 点缀：它们为什么配在一起，适合哪种画面。',
      '配色, 视觉'
    ))
    list.push(DailyPrompt.of(
      '一句话标题',
      '把今天听到或看到的一句话改写成可用标题。',
      '原句：\n改写标题：\n适用场景：',
      '文案, 标题'
    ))
    list.push(DailyPrompt.of(
      '材质五词',
      '用五个词描述此刻的触感与材质。',
      '五个词：\n适合用在：包装 / 界面 / 空间 / 插画。',
      '材质, 感官'
    ))
    list.push(DailyPrompt.of(
      '未完成构图',
      '记下脑子里还没画完的画面。',
      '主体在画面的哪一侧，留白给谁，下一步先画哪一块。',
      '构图, 画面'
    ))
    list.push(DailyPrompt.of(
      '文案节奏',
      '收集一条可复用的句子节奏。',
      '原句节奏：短-短-长 / 问句收尾。\n我可以改写成：',
      '文案, 节奏'
    ))
    list.push(DailyPrompt.of(
      '工作命名',
      '给下周要推进的项目起一个工作名。',
      '项目一句话：\n工作名：\n为什么这个名字好记。',
      '项目, 命名'
    ))
    return list
  }
}
