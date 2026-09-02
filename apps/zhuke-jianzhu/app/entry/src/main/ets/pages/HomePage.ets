/**
 * 筑科建筑 — 智慧工程驾驶舱
 * workbenchId: ops-cockpit · premium-business
 */
import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ZhukeKpiCard } from '../components/zhuke/ZhukeKpiCard'
import { ZhukeQuickEntry } from '../components/zhuke/ZhukeQuickEntry'
import { ZhukeProjectCard } from '../components/zhuke/ZhukeProjectCard'
import { DashboardService } from '../services/DashboardService'
import { BizService, EngProjectView } from '../services/BizService'
import { SafetyService } from '../services/SafetyService'
import { QualityService } from '../services/QualityService'
import { MediaCatalog } from '../config/MediaCatalog'

class QuickItem {
  label: string = ''
  icon: AppIconName = 'biz'
  accent: boolean = false
  tab: number = 0

  static make(label: string, icon: AppIconName, accent: boolean, tab: number): QuickItem {
    const q = new QuickItem()
    q.label = label
    q.icon = icon
    q.accent = accent
    q.tab = tab
    return q
  }
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '筑科建筑工程有限公司'
  @Prop appName: string = '筑科建筑'
  @Prop tagline: string = '智慧工程管理'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State activeProjects: number = 0
  @State outputRateText: string = '—'
  @State openSafety: number = 0
  @State openQuality: number = 0
  @State safetyHint: string = '现场平稳'
  @State qualityHint: string = '质量达标'
  @State dateLine: string = ''
  @State focusProjects: EngProjectView[] = []
  onOpenProject: (id: string) => void = (_id: string) => {}
  onGoTab: (index: number) => void = (_index: number) => {}

  private quickItems: QuickItem[] = [
    QuickItem.make('项目管理', 'biz', true, 1),
    QuickItem.make('安全巡检', 'alert', false, 2),
    QuickItem.make('质量管理', 'check', false, 2),
    QuickItem.make('材料设备', 'chart', false, 3)
  ]

  aboutToAppear(): void {
    const d = new Date()
    const week = ['日', '一', '二', '三', '四', '五', '六']
    this.dateLine = `${d.getMonth() + 1}月${d.getDate()}日 · 周${week[d.getDay()]}`
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private async reload(): Promise<void> {
    const vm = await DashboardService.load()
    this.activeProjects = vm.activeProjects
    this.outputRateText = vm.outputRateText

    let sOpen = vm.openSafety
    const safetyList = await SafetyService.list()
    if (safetyList.length > 0) {
      sOpen = 0
      for (const s of safetyList) {
        if (s.status !== 'closed') {
          sOpen++
        }
      }
    }
    this.openSafety = sOpen
    this.safetyHint = sOpen === 0 ? '现场平稳' : `${sOpen} 项待处置`

    let qOpen = vm.openQuality
    const qualityList = await QualityService.list()
    if (qualityList.length > 0) {
      qOpen = 0
      for (const q of qualityList) {
        if (q.status !== 'closed' && q.status !== 'verified') {
          qOpen++
        }
      }
    }
    this.openQuality = qOpen
    this.qualityHint = qOpen === 0 ? '质量达标' : `${qOpen} 项待整改`

    const all = await BizService.listProjects()
    const focus: EngProjectView[] = []
    for (const p of all) {
      if (focus.length >= 2) {
        break
      }
      if (p.statusCode === 'in_progress' || p.statusCode === 'accepting') {
        focus.push(p)
      }
    }
    if (focus.length === 0) {
      for (const p of all) {
        if (focus.length >= 2) {
          break
        }
        focus.push(p)
      }
    }
    this.focusProjects = focus
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Row() {
          Column({ space: Theme.space.s1 }) {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.tagline)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Text(this.dateLine)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(MediaCatalog.heroBg())
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 180,
              colors: [
                ['rgba(22,119,255,0.08)', 0.0],
                ['rgba(52,64,84,0.55)', 0.5],
                ['rgba(16,24,40,0.88)', 1.0]
              ]
            })
            .borderRadius(Theme.radius.xl)
          Column({ space: Theme.space.s3 }) {
            Row({ space: Theme.space.s2 }) {
              Column() {
                Text('Z')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .width(36)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(Theme.radius.sm)
              Text(this.company)
                .fontSize(Theme.type.footnote)
                .fontColor('rgba(255,255,255,0.85)')
            }
            Text('智慧工程驾驶舱')
              .fontSize(Theme.type.overline)
              .fontColor('rgba(255,255,255,0.75)')
              .letterSpacing(1.5)
            Text(`${this.activeProjects}`)
              .fontSize(56)
              .fontWeight(FontWeight.Lighter)
              .fontColor(Color.White)
            Text(`在建项目 · 产值完成 ${this.outputRateText}`)
              .fontSize(Theme.type.subhead)
              .fontColor('rgba(255,255,255,0.88)')
          }
          .width('100%')
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(220)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .clip(true)
        .shadow(Theme.cardShadow())

        Row({ space: Theme.space.s3 }) {
          ZhukeKpiCard({
            label: '项目数量',
            value: `${this.activeProjects}`,
            hint: '在建工程',
            tone: 'neutral',
            onTap: () => this.onGoTab(1)
          }).layoutWeight(1)
          ZhukeKpiCard({
            label: '工程进度',
            value: this.outputRateText,
            hint: '产值完成率',
            tone: 'neutral',
            onTap: () => this.onGoTab(1)
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          ZhukeKpiCard({
            label: '安全状态',
            value: this.openSafety === 0 ? '良好' : `${this.openSafety}`,
            hint: this.safetyHint,
            tone: this.openSafety === 0 ? 'success' : 'warn',
            onTap: () => this.onGoTab(2)
          }).layoutWeight(1)
          ZhukeKpiCard({
            label: '质量状态',
            value: this.openQuality === 0 ? '达标' : `${this.openQuality}`,
            hint: this.qualityHint,
            tone: this.openQuality === 0 ? 'success' : 'warn',
            onTap: () => this.onGoTab(2)
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          Text('快捷入口')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          GridRow({ columns: 4, gutter: Theme.space.s2 }) {
            ForEach(this.quickItems, (q: QuickItem) => {
              GridCol() {
                ZhukeQuickEntry({
                  label: q.label,
                  icon: q.icon,
                  accent: q.accent,
                  onTap: () => this.onGoTab(q.tab)
                })
              }
            }, (q: QuickItem) => q.label)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('重点关注项目')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Row({ space: 4 }) {
              Text('全部项目')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
            }
            .onClick(() => this.onGoTab(1))
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          if (this.focusProjects.length === 0) {
            AppEmpty({
              title: '暂无在建项目',
              description: '进入项目页创建或查看工程'
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.focusProjects, (p: EngProjectView) => {
                ZhukeProjectCard({
                  item: p,
                  onTap: () => this.onOpenProject(p.id)
                })
              }, (p: EngProjectView) => p.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
        }
      }
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
  }
}
