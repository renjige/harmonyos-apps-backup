import { BarChartItem } from '../components/design-system/AppChart'
import { DashboardKpiData } from '../models/ApiModels'
import { HttpClient } from './HttpClient'

export class DashboardViewModel {
  activeProjectsText: string = '—'
  outputRateText: string = '—'
  openRisksText: string = '—'
  openSafetyText: string = '—'
  openQualityText: string = '0'
  maintenanceText: string = '—'
  openSafety: number = 0
  openQuality: number = 0
  openRisks: number = 0
  maintenanceEquipment: number = 0
  activeProjects: number = 0
  outputRate: number = 0
  summaryBanner: string = ''
  safetyTrend: string = ''
  safetyPositive: boolean = true
  qualityTrend: string = ''
  qualityPositive: boolean = true
  outputTrend: string = ''
  outputPositive: boolean = true
  riskTrend: string = ''
  riskPositive: boolean = true
  trendItems: BarChartItem[] = []
  kpiBars: BarChartItem[] = []
}

export class DashboardService {
  static async load(): Promise<DashboardViewModel> {
    const vm = new DashboardViewModel()
    const res = await HttpClient.get<DashboardKpiData>('/dashboard/kpis')
    if (res.code !== 0 || res.data === undefined) {
      return vm
    }
    const d = DashboardService.normalize(res.data)
    vm.activeProjects = d.activeProjects
    vm.openRisks = d.openRisks
    vm.openSafety = d.openSafetyIssues
    vm.openQuality = d.openQualityIssues
    vm.maintenanceEquipment = d.maintenanceEquipment
    vm.outputRate = d.outputRate
    vm.activeProjectsText = DashboardService.safeNumText(d.activeProjects)
    vm.outputRateText = `${d.outputRate}%`
    vm.openRisksText = DashboardService.safeNumText(d.openRisks)
    vm.openSafetyText = DashboardService.safeNumText(d.openSafetyIssues)
    vm.openQualityText = DashboardService.safeNumText(d.openQualityIssues)
    vm.maintenanceText = DashboardService.safeNumText(d.maintenanceEquipment)

    vm.safetyPositive = d.openSafetyIssues === 0
    vm.safetyTrend = d.openSafetyIssues === 0 ? '现场平稳' : `待闭环 ${d.openSafetyIssues} 项`
    vm.qualityPositive = d.openQualityIssues === 0
    vm.qualityTrend = d.openQualityIssues === 0 ? '整改清零' : `待整改 ${d.openQualityIssues} 项`
    vm.outputPositive = d.outputRate >= 60
    vm.outputTrend = d.outputRate >= 60 ? `完成率 ${d.outputRate}%` : `偏低 ${d.outputRate}%`
    vm.riskPositive = d.openRisks === 0
    vm.riskTrend = d.openRisks === 0 ? '无开放风险' : `开放 ${d.openRisks} 项`

    if (d.openSafetyIssues > 0) {
      vm.summaryBanner = `${d.openSafetyIssues} 项安全隐患待处置`
    } else if (d.openQualityIssues > 0) {
      vm.summaryBanner = `${d.openQualityIssues} 项质量问题待整改`
    } else if (d.openRisks > 0) {
      vm.summaryBanner = `${d.openRisks} 项风险待处置，产值完成率 ${d.outputRate}%`
    } else if (d.activeProjects > 0) {
      vm.summaryBanner = `在建 ${d.activeProjects} 个项目，现场状态平稳`
    } else {
      vm.summaryBanner = '暂无在建项目，可从工程立项开始'
    }
    vm.trendItems = DashboardService.buildBars(d)
    vm.kpiBars = DashboardService.buildBars(d)
    return vm
  }

  /** 平台返回 { items:[{key,value}] }，兼容扁平字段 */
  private static normalize(raw: DashboardKpiData): DashboardKpiData {
    const out = new DashboardKpiData()
    let activeProjects = DashboardService.asNum(raw.activeProjects)
    let outputRate = DashboardService.asNum(raw.outputRate)
    let openRisks = DashboardService.asNum(raw.openRisks)
    let openSafetyIssues = DashboardService.asNum(raw.openSafetyIssues)
    let openQualityIssues = DashboardService.asNum(raw.openQualityIssues)
    let maintenanceEquipment = DashboardService.asNum(raw.maintenanceEquipment)
    if (raw.items !== undefined && raw.items.length > 0) {
      for (let i = 0; i < raw.items.length; i++) {
        const row = raw.items[i]
        const key = row.key
        const num = DashboardService.asNum(row.value)
        if (key === 'activeProjects') {
          activeProjects = num
        } else if (key === 'outputRate') {
          outputRate = num
        } else if (key === 'openRisks') {
          openRisks = num
        } else if (key === 'openSafetyIssues') {
          openSafetyIssues = num
        } else if (key === 'openQualityIssues') {
          openQualityIssues = num
        } else if (key === 'maintenanceEquipment') {
          maintenanceEquipment = num
        }
      }
    }
    out.activeProjects = activeProjects
    out.outputRate = outputRate
    out.openRisks = openRisks
    out.openSafetyIssues = openSafetyIssues
    out.openQualityIssues = openQualityIssues
    out.maintenanceEquipment = maintenanceEquipment
    out.items = raw.items !== undefined ? raw.items : []
    return out
  }

  private static asNum(v: number | string): number {
    if (typeof v === 'number') {
      if (isNaN(v)) {
        return 0
      }
      return v
    }
    const n = Number(v)
    if (isNaN(n)) {
      return 0
    }
    return n
  }

  private static safeNumText(v: number): string {
    if (typeof v !== 'number' || isNaN(v)) {
      return '0'
    }
    return `${v}`
  }

  private static buildBars(d: DashboardKpiData): BarChartItem[] {
    const items: BarChartItem[] = []
    const a = new BarChartItem()
    a.label = '隐患'
    a.value = d.openSafetyIssues
    items.push(a)
    const b = new BarChartItem()
    b.label = '质量'
    b.value = d.openQualityIssues
    items.push(b)
    const c = new BarChartItem()
    c.label = '风险'
    c.value = d.openRisks
    items.push(c)
    const e = new BarChartItem()
    e.label = '产值%'
    e.value = d.outputRate
    items.push(e)
    return items
  }
}
