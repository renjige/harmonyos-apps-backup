import { SportRecord, SportTypeOption } from '../models/SportRecord'
import { ResultOption, WatchChecklist } from '../models/SportExtra'
import { RecapPhase } from '../models/CollectModels'
import { KeyMoment } from '../models/SportExtra'
import { RecordStore } from './RecordStore'
import { CollectStore } from './CollectStore'

export class MatchReportService {
  static async build(matchId: string): Promise<string> {
    const record = await RecordStore.findById(matchId)
    if (record === undefined) {
      return '未找到该场比赛。'
    }
    const linked = await CollectStore.loadByMatchId(matchId)
    const lines: string[] = []
    lines.push('══════════════════════════════')
    lines.push('  赛场拾录 · 比赛战报')
    lines.push('══════════════════════════════')
    lines.push('')
    lines.push(`【${record.title}】`)
    lines.push(`${SportTypeOption.labelOf(record.sportType)} · ${record.date} ${record.time}`)
    if (record.homeTeam.length > 0 || record.opponent.length > 0) {
      lines.push(`对阵：${record.homeTeam} vs ${record.opponent}`)
    }
    if (record.score.length > 0) {
      lines.push(`比分：${record.score}`)
    }
    if (ResultOption.labelOf(record.result).length > 0) {
      lines.push(`结果：${ResultOption.labelOf(record.result)}`)
    }
    if (record.location.length > 0) {
      lines.push(`地点：${record.location}`)
    }
    lines.push('')

    if (record.prediction.length > 0) {
      lines.push('── 赛前预测 ──')
      lines.push(record.prediction)
      lines.push('')
    }
    if (record.watchPlan.length > 0) {
      lines.push('── 观赛计划 ──')
      lines.push(record.watchPlan)
      lines.push('')
    }

    const checklist = WatchChecklist.unpack(record.checklistPacked)
    let doneCount = 0
    for (const it of checklist) {
      if (it.done) {
        doneCount++
      }
    }
    lines.push(`── 观赛清单（${doneCount}/${checklist.length}）──`)
    for (const it of checklist) {
      lines.push(`${it.done ? '✓' : '○'} ${it.label}`)
    }
    lines.push('')

    const dims: string[] = []
    if (record.rating > 0) {
      dims.push(`综合 ${record.rating} 星`)
    }
    if (record.rateQuality > 0) {
      dims.push(`质量 ${record.rateQuality}/5`)
    }
    if (record.rateIntensity > 0) {
      dims.push(`强度 ${record.rateIntensity}/5`)
    }
    if (record.rateAtmosphere > 0) {
      dims.push(`氛围 ${record.rateAtmosphere}/5`)
    }
    if (dims.length > 0) {
      lines.push('── 多维评价 ──')
      lines.push(dims.join(' · '))
      lines.push('')
    }

    if (record.mvpName.length > 0) {
      lines.push(`── 本场 MVP ──`)
      lines.push(record.mvpName)
      lines.push('')
    }

    const moments = KeyMoment.unpack(record.momentsPacked)
    if (moments.length > 0) {
      lines.push('── 赛点时刻 ──')
      for (const m of moments) {
        lines.push(`${m.minute}' [${KeyMoment.kindLabel(m.kind)}] ${m.text}`)
      }
      lines.push('')
    }

    const phases = RecapPhase.unpack(record.recapPhases)
    const filled: RecapPhase[] = []
    for (const p of phases) {
      if (p.text.length > 0) {
        filled.push(p)
      }
    }
    if (filled.length > 0) {
      lines.push('── 复盘时间轴 ──')
      for (const p of filled) {
        lines.push(`${p.label}：${p.text}`)
      }
      lines.push('')
    }

    if (record.recapSummary.length > 0) {
      lines.push(`── 复盘报告${record.recapScore.length > 0 ? `（${record.recapScore}）` : ''} ──`)
      lines.push(record.recapSummary)
      lines.push('')
    }

    if (linked.length > 0) {
      lines.push('── 关联瞬间 / 笔记 ──')
      for (const it of linked) {
        const head = it.sub.length > 0 ? `${it.sub} · ` : ''
        lines.push(`· ${head}${it.title}`)
        if (it.body.length > 0) {
          lines.push(`  ${it.body}`)
        }
      }
      lines.push('')
    }

    if (record.note.length > 0) {
      lines.push('── 个人备注 ──')
      lines.push(record.note)
      lines.push('')
    }

    if (record.tagsPacked.length > 0) {
      lines.push(`标签：${record.tagsPacked.replace(/,/g, ' · ')}`)
    }
    lines.push('')
    lines.push('—— 由赛场拾录自动生成 ——')
    return lines.join('\n')
  }
}
