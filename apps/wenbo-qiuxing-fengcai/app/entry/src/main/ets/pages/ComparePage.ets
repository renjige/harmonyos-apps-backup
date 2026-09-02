import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { AthleteItem } from '../models/StarModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'
import { CompareSetService } from '../services/CompareSetService'
import { CompareSet } from '../models/FanGrowthModels'
import { FanStatsService } from '../services/FanStatsService'
import { StarMedia } from '../services/StarMedia'

class CompareRow {
  label: string = ''
  left: string = ''
  right: string = ''

  static build(left: AthleteItem, right: AthleteItem): CompareRow[] {
    const out: CompareRow[] = []
    const r0 = new CompareRow()
    r0.label = '项目'
    r0.left = left.sportLabel()
    r0.right = right.sportLabel()
    out.push(r0)
    const r1 = new CompareRow()
    r1.label = '俱乐部/队伍'
    r1.left = left.team.length > 0 ? left.team : '—'
    r1.right = right.team.length > 0 ? right.team : '—'
    out.push(r1)
    const r2 = new CompareRow()
    r2.label = '位置/角色'
    r2.left = left.position.length > 0 ? left.position : '—'
    r2.right = right.position.length > 0 ? right.position : '—'
    out.push(r2)
    const r3 = new CompareRow()
    r3.label = '国籍'
    r3.left = left.nationality.length > 0 ? left.nationality : '—'
    r3.right = right.nationality.length > 0 ? right.nationality : '—'
    out.push(r3)
    const r4 = new CompareRow()
    r4.label = '出生年份'
    r4.left = left.birthYear > 0 ? `${left.birthYear}` : '—'
    r4.right = right.birthYear > 0 ? `${right.birthYear}` : '—'
    out.push(r4)
    const r5 = new CompareRow()
    r5.label = left.statsLabel.length > 0 ? left.statsLabel : '数据概览'
    r5.left = left.statsValue.length > 0 ? left.statsValue : '—'
    r5.right = right.statsValue.length > 0 ? right.statsValue : '—'
    out.push(r5)
    return out
  }
}

@Component
export struct ComparePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State allAthletes: AthleteItem[] = []
  @State leftId: string = ''
  @State rightId: string = ''
  @State left: AthleteItem | undefined = undefined
  @State right: AthleteItem | undefined = undefined
  @State loading: boolean = true
  @State pickerSide: string = ''
  @State rows: CompareRow[] = []
  @State savedSets: CompareSet[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    this.savedSets = CompareSetService.list()
    void this.loadAthletes()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async saveCompareSet(): Promise<void> {
    if (this.left === undefined || this.right === undefined) {
      return
    }
    const ok = await CompareSetService.save(
      this.left.id, this.right.id, this.left.title, this.right.title, this.left.sport)
    this.savedSets = CompareSetService.list()
    if (ok) {
      const ach = await FanStatsService.bumpAndEvaluate()
      this.showToast(ach.length > 0 ? ach : '已保存到对比研究夹')
    }
  }

  private loadSavedSet(set: CompareSet): void {
    this.leftId = set.athleteAId
    this.rightId = set.athleteBId
    void this.applySelection()
  }

  private async loadAthletes(): Promise<void> {
    this.loading = true
    this.allAthletes = await StarBizService.loadAthletes('', false)
    this.loading = false
  }

  private async applySelection(): Promise<void> {
    this.left = undefined
    this.right = undefined
    this.rows = []
    if (this.leftId.length > 0) {
      this.left = await StarBizService.findAthlete(this.leftId)
    }
    if (this.rightId.length > 0) {
      this.right = await StarBizService.findAthlete(this.rightId)
    }
    if (this.left !== undefined && this.right !== undefined) {
      this.rows = CompareRow.build(this.left, this.right)
    }
  }

  private athleteTitle(id: string): string {
    for (const item of this.allAthletes) {
      if (item.id === id) {
        return item.title
      }
    }
    return '点击选择球星'
  }

  private openAthleteDetail(id: string): void {
    if (id.length === 0) {
      return
    }
    StarDetailNav.pushAthlete(id)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { StarDetailNav.close() })
          Text('球星对比')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.loading) {
          AppLoading({ label: '加载球星列表…' }).layoutWeight(1)
        } else if (this.allAthletes.length < 2) {
          AppEmpty({
            title: '球星不足',
            description: '至少需要 2 位球星才能对比',
            actionLabel: '返回',
            onAction: (): void => { StarDetailNav.close() }
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text('选择两位球星，横向对比资料与关键数据')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              Row({ space: Theme.space.s3 }) {
                Column({ space: 6 }) {
                  Text('球星 A')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  Text(this.athleteTitle(this.leftId))
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .width('100%')
                  AppButton({
                    label: '选择',
                    variant: 'secondary',
                    onTap: (): void => { this.pickerSide = 'left' }
                  })
                }
                .layoutWeight(1)
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })

                Column({ space: 6 }) {
                  Text('球星 B')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  Text(this.athleteTitle(this.rightId))
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .width('100%')
                  AppButton({
                    label: '选择',
                    variant: 'secondary',
                    onTap: (): void => { this.pickerSide = 'right' }
                  })
                }
                .layoutWeight(1)
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }
              .width('100%')

              if (this.pickerSide.length > 0) {
                Column({ space: Theme.space.s2 }) {
                  Text(`选择${this.pickerSide === 'left' ? '球星 A' : '球星 B'}`)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  ForEach(this.allAthletes, (item: AthleteItem) => {
                    Row({ space: Theme.space.s2 }) {
                      if (item.coverKey.length > 0) {
                        Image(StarMedia.coverMedia(item.coverKey))
                          .width(40)
                          .height(40)
                          .borderRadius(Theme.radius.md)
                          .objectFit(ImageFit.Cover)
                      }
                      Column({ space: 2 }) {
                        Text(item.title)
                          .fontSize(Theme.type.callout)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        Text(item.sportLabel())
                          .fontSize(Theme.type.caption)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.lg)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                    .onClick((): void => {
                      if (this.pickerSide === 'left') {
                        this.leftId = item.id
                      } else {
                        this.rightId = item.id
                      }
                      this.pickerSide = ''
                      void this.applySelection()
                    })
                  }, (item: AthleteItem) => item.id)
                }
                .width('100%')
              }

              if (this.left !== undefined && this.right !== undefined) {
                Column({ space: Theme.space.s3 }) {
                  Text('对比结果')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  ForEach(this.rows, (row: CompareRow) => {
                    AppCard({ title: row.label, variant: 'plain' }) {
                      Row({ space: Theme.space.s3 }) {
                        Text(row.left)
                          .fontSize(Theme.type.body)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .layoutWeight(1)
                          .textAlign(TextAlign.Start)
                        Text('VS')
                          .fontSize(Theme.type.caption)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                        Text(row.right)
                          .fontSize(Theme.type.body)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .layoutWeight(1)
                          .textAlign(TextAlign.End)
                      }
                      .width('100%')
                    }
                  }, (row: CompareRow) => row.label)
                  Row({ space: Theme.space.s3 }) {
                    Column() {
                      AppButton({
                        label: '查看 A 详情',
                        variant: 'secondary',
                        onTap: (): void => { this.openAthleteDetail(this.left!.id) }
                      })
                    }
                    .layoutWeight(1)
                    .onClick((): void => { this.openAthleteDetail(this.left!.id) })
                    Column() {
                      AppButton({
                        label: '查看 B 详情',
                        variant: 'secondary',
                        onTap: (): void => { this.openAthleteDetail(this.right!.id) }
                      })
                    }
                    .layoutWeight(1)
                    .onClick((): void => { this.openAthleteDetail(this.right!.id) })
                  }
                  .width('100%')
                  AppButton({
                    label: '保存到对比研究夹',
                    onTap: (): void => { void this.saveCompareSet() }
                  })
                }
                .width('100%')
              }

              if (this.savedSets.length > 0) {
                Column({ space: Theme.space.s2 }) {
                  Text('对比研究夹')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  ForEach(this.savedSets, (set: CompareSet) => {
                    Text(set.label())
                      .fontSize(Theme.type.callout)
                      .fontColor(Theme.colors().brandPrimary)
                      .width('100%')
                      .padding(Theme.space.s3)
                      .backgroundColor(Theme.colors().surfaceCard)
                      .borderRadius(Theme.radius.lg)
                      .border({ width: 1, color: Theme.colors().strokeHairline })
                      .onClick((): void => { this.loadSavedSet(set) })
                  }, (set: CompareSet) => set.id)
                }
                .width('100%')
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
