/** 巡检 — 安全检查 · 隐患记录 · 整改状态 */
import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { ZhukeInspectionCard } from '../components/zhuke/ZhukeInspectionCard'
import { SafetyService, SafetyItem } from '../services/SafetyService'
import { QualityService, QualityItem } from '../services/QualityService'

class InspectSegment {
  code: string = ''
  label: string = ''

  static all(): InspectSegment[] {
    const list: InspectSegment[] = []
    const codes: string[] = ['safety', 'quality']
    const labels: string[] = ['安全检查', '质量巡检']
    for (let i = 0; i < codes.length; i++) {
      const s = new InspectSegment()
      s.code = codes[i]
      s.label = labels[i]
      list.push(s)
    }
    return list
  }
}

@Component
export struct InspectionPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State segment: string = 'safety'
  @State safetyItems: SafetyItem[] = []
  @State qualityItems: QualityItem[] = []
  @State loading: boolean = true
  @State openCount: number = 0
  @State rectifyingCount: number = 0
  @State closedCount: number = 0
  private segments: InspectSegment[] = InspectSegment.all()
  onOpenSafety: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.safetyItems = await SafetyService.list()
    this.qualityItems = await QualityService.list()
    this.loading = false
    this.recalcStats()
  }

  private recalcStats(): void {
    let open = 0
    let rect = 0
    let closed = 0
    const list = this.segment === 'safety' ? this.safetyItems : this.qualityItems
    for (const row of list) {
      if (row.status === 'closed' || row.status === 'verified') {
        closed++
      } else if (row.status === 'rectifying') {
        rect++
      } else {
        open++
      }
    }
    this.openCount = open
    this.rectifyingCount = rect
    this.closedCount = closed
  }

  build() {
    Column() {
      Column({ space: Theme.space.s2 }) {
        Text('巡检')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('安全 · 隐患 · 整改闭环')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s4
      })

      Row({ space: Theme.space.s3 }) {
        AppStatCard({ label: '待处置', value: `${this.openCount}` })
          .layoutWeight(1)
        AppStatCard({ label: '整改中', value: `${this.rectifyingCount}` })
          .layoutWeight(1)
        AppStatCard({ label: '已闭环', value: `${this.closedCount}`, positive: true, trend: '已完成' })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })

      Row({ space: Theme.space.s2 }) {
        ForEach(this.segments, (s: InspectSegment) => {
          Text(s.label)
            .fontSize(Theme.type.subhead)
            .fontWeight(this.segment === s.code ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.segment === s.code ?
              Theme.colors().brandPrimary : Theme.colors().textSecondary)
            .padding({ bottom: Theme.space.s2 })
            .border({
              width: { bottom: this.segment === s.code ? 2 : 0 },
              color: Theme.colors().brandPrimary
            })
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.segment = s.code
              this.recalcStats()
            })
        }, (s: InspectSegment) => s.code)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })

      if (this.loading) {
        AppLoading({ label: '加载巡检记录' })
      } else if (this.segment === 'safety') {
        if (this.safetyItems.length === 0) {
          AppEmpty({
            title: '暂无安全检查记录',
            description: '现场巡检数据将在此展示，支持隐患登记与整改跟踪'
          })
        } else {
          List({ space: Theme.space.s3 }) {
            ForEach(this.safetyItems, (row: SafetyItem) => {
              ListItem() {
                ZhukeInspectionCard({
                  item: row,
                  onTap: () => this.onOpenSafety(row.id)
                })
              }
            }, (row: SafetyItem) => row.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
      } else {
        if (this.qualityItems.length === 0) {
          AppEmpty({
            title: '暂无质量巡检记录',
            description: '质量问题发现与整改验收将在此跟踪'
          })
        } else {
          List({ space: Theme.space.s3 }) {
            ForEach(this.qualityItems, (row: QualityItem) => {
              ListItem() {
                Column({ space: Theme.space.s3 }) {
                  Row() {
                    Column({ space: Theme.space.s1 }) {
                      Text(row.title)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      Text(`${QualityService.typeLabel(row.type)} · ${row.projectName}`)
                        .fontSize(Theme.type.footnote)
                        .fontColor(Theme.colors().textTertiary)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Text(QualityService.statusLabel(row.status))
                      .fontSize(Theme.type.caption)
                      .fontColor(QualityService.levelColor(row.level))
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(Theme.space.cardPadding)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.card)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .shadow(Theme.cardShadow())
              }
            }, (row: QualityItem) => row.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
