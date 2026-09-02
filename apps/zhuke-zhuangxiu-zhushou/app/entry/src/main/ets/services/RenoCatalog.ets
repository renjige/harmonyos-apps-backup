import {
  ListPayload,
  RenoGuide,
  RenoNotice,
  RenoStage,
  RenoSuggestion
} from '../models/RenoModels'
import { HttpClient } from './HttpClient'
import { RenoMedia } from './RenoMedia'

const BASE = '/biz/reno-assist'

export class RenoCatalog {
  static values<T>(data: ListPayload<T> | undefined): T[] {
    if (data === undefined) {
      return []
    }
    return data.list.length > 0 ? data.list : data.items
  }

  static async stages(): Promise<RenoStage[]> {
    const res = await HttpClient.get<ListPayload<RenoStage>>(`${BASE}/stages`)
    if (res.code === 0 && RenoCatalog.values(res.data).length > 0) {
      const mapped: RenoStage[] = []
      for (const row of RenoCatalog.values(res.data)) {
        mapped.push(RenoCatalog.mapStage(row))
      }
      return mapped
    }
    return RenoCatalog.fallbackStages()
  }

  static async suggestions(stage: string): Promise<RenoSuggestion[]> {
    const path = stage.length > 0 ? `${BASE}/suggestions?stage=${encodeURIComponent(stage)}` : `${BASE}/suggestions`
    const res = await HttpClient.get<ListPayload<RenoSuggestion>>(path)
    const mapped: RenoSuggestion[] = []
    if (res.code === 0) {
      for (const row of RenoCatalog.values(res.data)) {
        mapped.push(RenoCatalog.mapSuggestion(row))
      }
    }
    if (mapped.length > 0) {
      return mapped
    }
    const all = RenoCatalog.fallbackSuggestions()
    if (stage.length === 0) {
      return all
    }
    const filtered: RenoSuggestion[] = []
    for (const row of all) {
      if (row.category === stage) {
        filtered.push(row)
      }
    }
    return filtered
  }

  static async acceptItems(category: string): Promise<RenoSuggestion[]> {
    const path = category.length > 0
      ? `${BASE}/accept-items?category=${encodeURIComponent(category)}`
      : `${BASE}/accept-items`
    const res = await HttpClient.get<ListPayload<RenoSuggestion>>(path)
    const mapped: RenoSuggestion[] = []
    if (res.code === 0) {
      for (const row of RenoCatalog.values(res.data)) {
        mapped.push(RenoCatalog.mapSuggestion(row))
      }
    }
    if (mapped.length > 0) {
      return mapped
    }
    return RenoCatalog.fallbackAccept(category)
  }

  static async guides(): Promise<RenoGuide[]> {
    const res = await HttpClient.get<ListPayload<RenoGuide>>(`${BASE}/guides`)
    if (res.code === 0 && RenoCatalog.values(res.data).length > 0) {
      const mapped: RenoGuide[] = []
      for (const row of RenoCatalog.values(res.data)) {
        mapped.push(RenoCatalog.mapGuide(row))
      }
      return mapped
    }
    return RenoCatalog.fallbackGuides()
  }

  static async notices(): Promise<RenoNotice[]> {
    const res = await HttpClient.get<ListPayload<RenoNotice>>(`${BASE}/messages`)
    if (res.code === 0) {
      return RenoCatalog.values(res.data)
    }
    const res2 = await HttpClient.get<ListPayload<RenoNotice>>('/messages')
    return res2.code === 0 ? RenoCatalog.values(res2.data) : []
  }

  static mapStage(raw: RenoStage): RenoStage {
    const row = new RenoStage()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.summary = raw.summary ?? ''
    row.body = raw.body ?? ''
    row.coverKey = raw.coverKey ?? ''
    row.sortOrder = raw.sortOrder ?? 0
    return row
  }

  static mapSuggestion(raw: RenoSuggestion): RenoSuggestion {
    const row = new RenoSuggestion()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.summary = raw.summary ?? ''
    row.body = raw.body ?? ''
    row.category = raw.category ?? ''
    row.coverKey = RenoMedia.coverKeyForSuggestion(raw.id ?? '', raw.coverKey ?? '')
    return row
  }

  static mapGuide(raw: RenoGuide): RenoGuide {
    const row = new RenoGuide()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.summary = raw.summary ?? ''
    row.body = raw.body ?? ''
    row.coverKey = raw.coverKey ?? ''
    return row
  }

  private static stageOf(id: string, title: string, summary: string, body: string, cover: string, order: number): RenoStage {
    const row = new RenoStage()
    row.id = id
    row.title = title
    row.summary = summary
    row.body = body
    row.coverKey = cover
    row.sortOrder = order
    return row
  }

  private static sugOf(id: string, title: string, stage: string, summary: string, body: string, cover: string): RenoSuggestion {
    const row = new RenoSuggestion()
    row.id = id
    row.title = title
    row.category = stage
    row.summary = summary
    row.body = body
    row.coverKey = cover
    return row
  }

  private static guideOf(id: string, title: string, summary: string, body: string, cover: string): RenoGuide {
    const row = new RenoGuide()
    row.id = id
    row.title = title
    row.summary = summary
    row.body = body
    row.coverKey = cover
    return row
  }

  static fallbackStages(): RenoStage[] {
    const rows: RenoStage[] = []
    rows.push(RenoCatalog.stageOf('ra_stage_demo', '拆改', '拆除、砌墙、结构改动',
      '拆改阶段重点记录拆除范围与砌筑完成情况。说明仅供个人记录参考。', 'stage_demo', 1))
    rows.push(RenoCatalog.stageOf('ra_stage_hydro', '水电', '水路、电路、弱电定位',
      '水电阶段建议确认开关插座、水路打压与电路弱电检查。', 'stage_hydro', 2))
    rows.push(RenoCatalog.stageOf('ra_stage_wood', '泥木', '防水、瓷砖、木作吊顶',
      '泥木阶段关注防水闭水、瓷砖平整与吊顶。', 'stage_wood', 3))
    rows.push(RenoCatalog.stageOf('ra_stage_paint', '油漆', '基层、底漆、面漆观感',
      '油漆阶段记录基层、底漆、面漆与观感问题。', 'stage_paint', 4))
    rows.push(RenoCatalog.stageOf('ra_stage_install', '安装', '洁具、灯具、柜体安装',
      '安装阶段核对洁具、面板、灯具与柜体收口。', 'stage_install', 5))
    rows.push(RenoCatalog.stageOf('ra_stage_accept', '验收', '按清单逐项核对',
      '使用 Checklist 标记通过、待处理或不适用。结果仅供个人记录，不构成专业鉴定。', 'stage_accept', 6))
    return rows
  }

  static fallbackSuggestions(): RenoSuggestion[] {
    const rows: RenoSuggestion[] = []
    rows.push(RenoCatalog.sugOf('ra_sug_1', '拆除范围确认', '拆改', '核对拆除墙体与保留结构', '开工前把拆除范围记清楚。承重结构改动须由有资质单位处理。', 'sug_demolish'))
    rows.push(RenoCatalog.sugOf('ra_sug_2', '砌筑完成检查', '拆改', '新砌墙体垂直与完成面', '记录砌筑完成日期与明显偏差。', 'sug_masonry'))
    rows.push(RenoCatalog.sugOf('ra_sug_3', '水电定位', '水电', '点位与走向确认', '厨房、卫生间、客厅开关插座位置确认后写备注。', 'sug_hydro_layout'))
    rows.push(RenoCatalog.sugOf('ra_sug_4', '开关插座确认', '水电', '数量、高度、回路', '核对每个房间插座数量与操作台专用插座。', 'sug_outlet'))
    rows.push(RenoCatalog.sugOf('ra_sug_5', '水路打压', '水电', '打压结果与日期', '记录打压时间与是否渗漏。不替代施工方检测。', 'sug_pressure'))
    rows.push(RenoCatalog.sugOf('ra_sug_6', '电路检查', '水电', '回路与配电', '记录强电回路划分与空开标识。', 'sug_circuit'))
    rows.push(RenoCatalog.sugOf('ra_sug_7', '弱电检查', '水电', '网络、电视、门禁', '弱电箱位置与网线电视点位是否到位。', 'sug_weak'))
    rows.push(RenoCatalog.sugOf('ra_sug_8', '防水检查', '泥木', '涂刷范围与闭水', '卫生间、厨房防水高度与闭水天数记入事项。', 'sug_waterproof'))
    rows.push(RenoCatalog.sugOf('ra_sug_9', '瓷砖检查', '泥木', '平整、缝隙、空鼓', '抽查地面与墙砖空鼓并记录位置。', 'sug_tile'))
    rows.push(RenoCatalog.sugOf('ra_sug_10', '地漏确认', '泥木', '型号与排水坡度', '确认地漏型号、位置与排水方向。', 'sug_drain'))
    rows.push(RenoCatalog.sugOf('ra_sug_11', '吊顶检查', '泥木', '龙骨与检修口', '记录吊顶完成面与检修口位置。', 'sug_ceiling'))
    rows.push(RenoCatalog.sugOf('ra_sug_12', '墙面基层检查', '油漆', '腻子与平整', '侧光检查墙面平整，记录需修补位置。', 'sug_putty'))
    rows.push(RenoCatalog.sugOf('ra_sug_13', '底漆施工', '油漆', '底漆遍数与日期', '记录底漆施工日期，便于安排面漆。', 'sug_primer'))
    rows.push(RenoCatalog.sugOf('ra_sug_14', '面漆施工', '油漆', '颜色与遍数', '确认色号后记录面漆施工情况。', 'sug_paint'))
    rows.push(RenoCatalog.sugOf('ra_sug_15', '墙面观感检查', '油漆', '流挂、色差、裂纹', '近距离与侧光检查，问题记入现场记录。', 'sug_wall_look'))
    rows.push(RenoCatalog.sugOf('ra_sug_16', '洁具安装核对', '安装', '马桶、龙头、花洒', '核对品牌型号与安装位置。', 'sug_sanitary'))
    rows.push(RenoCatalog.sugOf('ra_sug_17', '开关面板安装', '安装', '面板与回路标识', '安装后确认回路对应关系。', 'sug_switch'))
    rows.push(RenoCatalog.sugOf('ra_sug_18', '柜体尺寸确认', '安装', '橱柜与衣柜收口', '安装前再次确认尺寸。', 'sug_cabinet'))
    rows.push(RenoCatalog.sugOf('ra_sug_19', '水电验收清单', '验收', '水路电路逐项核对', '按验收模板逐项标记通过或待处理。', 'sug_accept_hydro'))
    rows.push(RenoCatalog.sugOf('ra_sug_20', '防水验收清单', '验收', '闭水与排水', '闭水结束后记录地面与墙面情况。', 'sug_accept_water'))
    rows.push(RenoCatalog.sugOf('ra_sug_21', '泥木验收清单', '验收', '瓷砖与阴阳角', '记录平整、缝隙与空鼓抽查结果。', 'sug_accept_wood'))
    rows.push(RenoCatalog.sugOf('ra_sug_22', '油漆验收清单', '验收', '颜色与观感', '记录均匀度、裂纹与流挂情况。', 'sug_accept_paint'))
    return rows
  }

  static fallbackAccept(category: string): RenoSuggestion[] {
    const rows: RenoSuggestion[] = []
    rows.push(RenoCatalog.sugOf('ra_acc_1', '水路是否正常', '水电验收', '水电验收', '观察阀门、接头与用水点是否有渗漏迹象。', 'stage_hydro'))
    rows.push(RenoCatalog.sugOf('ra_acc_2', '电路是否正常', '水电验收', '水电验收', '空开标识是否清晰，插座是否按约定布置。', 'stage_hydro'))
    rows.push(RenoCatalog.sugOf('ra_acc_3', '插座位置是否确认', '水电验收', '水电验收', '对照水电定位记录核对插座高度与数量。', 'stage_hydro'))
    rows.push(RenoCatalog.sugOf('ra_acc_4', '开关数量是否确认', '水电验收', '水电验收', '核对各房间开关数量与双控需求。', 'stage_hydro'))
    rows.push(RenoCatalog.sugOf('ra_acc_5', '水压测试是否完成', '水电验收', '水电验收', '记录打压日期与结果说明，不替代施工方检测。', 'stage_hydro'))
    rows.push(RenoCatalog.sugOf('ra_acc_6', '防水施工完成', '防水验收', '防水验收', '涂刷范围与高度是否达到约定记录。', 'stage_wood'))
    rows.push(RenoCatalog.sugOf('ra_acc_7', '闭水检查完成', '防水验收', '防水验收', '闭水时长与周边是否有异常记录。', 'stage_wood'))
    rows.push(RenoCatalog.sugOf('ra_acc_8', '墙面无明显异常', '防水验收', '防水验收', '防水完成后墙面是否有明显起鼓。', 'stage_wood'))
    rows.push(RenoCatalog.sugOf('ra_acc_9', '地面排水正常', '防水验收', '防水验收', '地漏排水是否顺畅。', 'stage_wood'))
    rows.push(RenoCatalog.sugOf('ra_acc_10', '瓷砖平整', '泥木验收', '泥木验收', '抽查地面与墙砖平整度。', 'stage_wood'))
    rows.push(RenoCatalog.sugOf('ra_acc_11', '缝隙均匀', '泥木验收', '泥木验收', '观察砖缝是否大致均匀。', 'stage_wood'))
    rows.push(RenoCatalog.sugOf('ra_acc_12', '空鼓情况记录', '泥木验收', '泥木验收', '轻敲抽查并记录疑似空鼓处。', 'stage_wood'))
    rows.push(RenoCatalog.sugOf('ra_acc_13', '阴阳角检查', '泥木验收', '泥木验收', '记录阴阳角是否顺直。', 'stage_wood'))
    rows.push(RenoCatalog.sugOf('ra_acc_14', '墙面颜色均匀', '油漆验收', '油漆验收', '侧光观察色差。', 'stage_paint'))
    rows.push(RenoCatalog.sugOf('ra_acc_15', '无明显裂纹', '油漆验收', '油漆验收', '记录可见裂纹位置。', 'stage_paint'))
    rows.push(RenoCatalog.sugOf('ra_acc_16', '无明显流挂', '油漆验收', '油漆验收', '记录流挂或刷痕位置。', 'stage_paint'))
    rows.push(RenoCatalog.sugOf('ra_acc_17', '阴阳角平整', '油漆验收', '油漆验收', '油漆完成后再次核对阴阳角观感。', 'stage_paint'))
    rows.push(RenoCatalog.sugOf('ra_acc_18', '洁具安装到位', '安装验收', '安装验收', '马桶、龙头、花洒是否按材料清单安装。', 'stage_install'))
    rows.push(RenoCatalog.sugOf('ra_acc_19', '灯具开关可用', '安装验收', '安装验收', '抽查灯具与开关是否可正常开闭。', 'stage_install'))
    rows.push(RenoCatalog.sugOf('ra_acc_20', '柜体收口完成', '安装验收', '安装验收', '橱柜衣柜收口与五金是否完成。', 'stage_install'))
    if (category.length === 0) {
      return rows
    }
    const filtered: RenoSuggestion[] = []
    for (const row of rows) {
      if (row.category === category) {
        filtered.push(row)
      }
    }
    return filtered
  }

  static fallbackGuides(): RenoGuide[] {
    const tip = '结果仅供装修计划参考，实际用量请结合现场情况确认。'
    const rows: RenoGuide[] = []
    rows.push(RenoCatalog.guideOf('ra_guide_area', '面积计算', '长 × 宽', `输入长度和宽度得到面积。${tip}`, 'home_hero'))
    rows.push(RenoCatalog.guideOf('ra_guide_wall', '墙面面积', '墙宽 × 墙高', `输入墙宽和墙高估算墙面面积。门窗洞口需自行扣除。${tip}`, 'stage_paint'))
    rows.push(RenoCatalog.guideOf('ra_guide_tile', '瓷砖数量估算', '面积 ÷ 单片 × (1+损耗)', `输入施工面积、瓷砖长宽与损耗比例。${tip}`, 'stage_wood'))
    rows.push(RenoCatalog.guideOf('ra_guide_paint', '涂料用量估算', '面积 × 遍数 ÷ 覆盖面积', `输入墙面面积、涂刷遍数与单位覆盖面积。${tip}`, 'stage_paint'))
    return rows
  }
}
