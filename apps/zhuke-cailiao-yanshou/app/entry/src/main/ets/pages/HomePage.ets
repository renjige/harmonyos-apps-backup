import { Theme, ThemeColors } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspectListCard } from '../components/inspect/InspectListCard'
import { InspectRecord, ProjectBrief } from '../models/InspectModels'
import { InspectService } from '../services/InspectService'
import { InspectNav } from '../services/InspectNav'
import { InspectLocalStore } from '../services/InspectLocalStore'
import { ExportService } from '../services/ExportService'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('inspectTick') @Watch('onDataTick') inspectTick: number = 0
  @StorageLink('inspectNavMode') @Watch('onNavClosed') navMode: string = ''
  @StorageLink('homeTodayTotal') todayTotal: number = 0
  @StorageLink('homeTodayDone') todayDone: number = 0
  @StorageLink('homeTodayPending') todayPending: number = 0
  @StorageLink('homeFollowCount') followCount: number = 0
  @Prop refreshToken: number = 0
  @State recent: InspectRecord[] = []
  @State todayTodo: InspectRecord[] = []
  @State projects: ProjectBrief[] = []
  @State toastText: string = ''
  onOpenSettings: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onDataTick(): void {
    this.reload()
  }

  onNavClosed(): void {
    if (this.navMode.length === 0) {
      this.reload()
    }
  }

  private reload(): void {
    InspectLocalStore.publishHomeStats()
    this.recent = []
    this.recent = InspectService.recent(5)
    this.todayTodo = []
    const pending = InspectService.todayPendingList()
    let todoN = 0
    for (const row of pending) {
      if (todoN >= 3) {
        break
      }
      this.todayTodo.push(row)
      todoN += 1
    }
    this.projects = []
    this.projects = InspectService.projectBriefs(4)
  }

  private pad2(n: number): string {
    return DateFormatUtil.pad2(n)
  }

  private skin(): ThemeColors {
    if (this.themeEpoch < 0) {
      return Theme.colors()
    }
    return Theme.colors()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async copyToday(): Promise<void> {
    const ok = await ExportService.copyTodayReport()
    this.showToast(ok ? '今日验收日报已复制' : '复制失败，请稍后重试')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('筑科材料验收')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.skin().textPrimary)
            .layoutWeight(1)
          Column() {
            AppIcon({ name: 'settings', iconSize: Theme.icon.md, color: this.skin().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.onOpenSettings())
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX - 8,
          top: Theme.space.pageY,
          bottom: 8
        })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: 6 }) {
              Text('今日验收')
                .fontSize(Theme.type.caption)
                .fontColor(this.skin().textPrimary)
                .width('100%')
              Text(this.pad2(this.todayTotal))
                .fontSize(Theme.type.displayM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.skin().textPrimary)
                .width('100%')
              Text(`今日已完成 ${this.todayDone}    待验收 ${this.todayPending}`)
                .fontSize(Theme.type.subhead)
                .fontColor(this.skin().textPrimary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s5)
            .backgroundColor(this.skin().surfaceCard)
            .borderRadius(Theme.radius.card)
            .border({ width: 1, color: this.skin().strokeHairline })

            Column() {
              Image($r('app.media.hero_site'))
                .width('100%')
                .height(92)
                .objectFit(ImageFit.Cover)
              Column({ space: 4 }) {
                Text('开始材料验收')
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.skin().textPrimary)
                  .width('100%')
                Text('工点、批次、专项检查一次记清')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.skin().textPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.skin().surfaceCard)
            }
            .width('100%')
            .clip(true)
            .borderRadius(Theme.radius.card)
            .border({ width: 1, color: this.skin().strokeHairline })
            .onClick(() => InspectNav.openCreate())

            Row({ space: 10 }) {
              this.miniStat('待验收', this.pad2(this.todayPending), 'todayPending')
              this.miniStat('已通过', this.pad2(this.todayDone), 'todayPass')
              this.miniStat('待跟进', this.pad2(this.followCount), 'follow')
            }
            .width('100%')

            Row({ space: 10 }) {
              this.actionEntry('品类要点', '按材料看核对项', () => {
                const cat = AppStorage.get<string>('defaultCategory')
                InspectNav.openGuide(cat !== undefined && cat.length > 0 ? cat : '瓷砖')
              })
              this.actionEntry('异常跟进', '待处理闭环', () => InspectNav.openFollowList())
            }
            .width('100%')

            Row({ space: 10 }) {
              this.actionEntry('工点台账', '按工点汇总', () => {
                if (this.projects.length > 0) {
                  InspectNav.openProjectBoard(this.projects[0].name)
                } else {
                  InspectNav.openCreate()
                }
              })
              this.actionEntry('今日日报', '复制验收摘要', () => { void this.copyToday() })
            }
            .width('100%')

            Row({ space: 10 }) {
              this.actionEntry('供应商台账', '按供货单位汇总', () => {
                const list = InspectService.supplierBriefs(1)
                if (list.length > 0) {
                  InspectNav.openSupplierBoard(list[0].name)
                } else {
                  InspectNav.openCreate()
                }
              })
              this.actionEntry('超期未验', '进场后仍待处理', () => InspectNav.openBoard('overdue'))
            }
            .width('100%')

            if (this.projects.length > 0) {
              Text('工点概览')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.skin().textPrimary)
                .width('100%')
              Column({ space: 8 }) {
                ForEach(this.projects, (p: ProjectBrief) => {
                  Row() {
                    Column({ space: 4 }) {
                      Text(p.name)
                        .fontSize(Theme.type.body)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.skin().textPrimary)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
                      Text(`共 ${p.total} 条 · 待处理 ${p.pending} · 已通过 ${p.passCount}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.skin().textPrimary)
                        .width('100%')
                    }
                    .layoutWeight(1)
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: this.skin().textPrimary })
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.skin().surfaceCard)
                  .borderRadius(Theme.radius.md)
                  .border({ width: 1, color: this.skin().strokeHairline })
                  .onClick(() => InspectNav.openProjectBoard(p.name))
                }, (p: ProjectBrief) => `${p.name}_${p.total}_${this.inspectTick}`)
              }
              .width('100%')
            }

            if (this.todayTodo.length > 0) {
              Row() {
                Text('今日待验收')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.skin().textPrimary)
                  .layoutWeight(1)
                Text('查看全部')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.skin().textPrimary)
                  .onClick(() => InspectNav.openBoard('todayPending'))
              }
              .width('100%')
              Column({ space: 8 }) {
                ForEach(this.todayTodo, (item: InspectRecord) => {
                  InspectListCard({
                    item: item,
                    stamp: `${item.id}_${item.updatedAt}_${this.inspectTick}`,
                    onTap: () => InspectNav.openDetail(item.id)
                  })
                }, (item: InspectRecord) => `${item.id}_${item.updatedAt}_${this.inspectTick}`)
              }
              .width('100%')
            }

            Text('最近验收')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.skin().textPrimary)
              .width('100%')

            if (this.recent.length === 0) {
              Column({ space: 10 }) {
                Image($r('app.media.empty_inspect'))
                  .width(120)
                  .height(80)
                  .objectFit(ImageFit.Contain)
                Text('还没有验收记录')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.skin().textPrimary)
                Text('开始一次材料验收，让现场记录更清晰。')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.skin().textPrimary)
                  .textAlign(TextAlign.Center)
                Text('开始验收')
                  .fontSize(Theme.type.body)
                  .fontColor('#FFFFFF')
                  .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                  .backgroundColor('#174A72')
                  .borderRadius(14)
                  .onClick(() => InspectNav.openCreate())
              }
              .width('100%')
              .padding(Theme.space.s6)
              .backgroundColor(this.skin().surfaceCard)
              .borderRadius(Theme.radius.card)
              .border({ width: 1, color: this.skin().strokeHairline })
            } else {
              Column({ space: 10 }) {
                ForEach(this.recent, (item: InspectRecord) => {
                  InspectListCard({
                    item: item,
                    stamp: `${item.id}_${item.updatedAt}_${item.result}_${this.inspectTick}`,
                    onTap: () => InspectNav.openDetail(item.id)
                  })
                }, (item: InspectRecord) => `${item.id}_${item.updatedAt}_${item.result}_${this.inspectTick}`)
              }
              .width('100%')
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.skin().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('#174A72')
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .id(`home_skin_${this.themeEpoch}`)
  }

  @Builder
  miniStat(label: string, value: string, boardMode: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.skin().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.skin().textPrimary)
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(this.skin().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: this.skin().strokeHairline })
    .onClick(() => InspectNav.openBoard(boardMode))
  }

  @Builder
  actionEntry(title: string, hint: string, tap: () => void) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.skin().textPrimary)
        .width('100%')
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.skin().textPrimary)
        .width('100%')
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.skin().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: this.skin().strokeStrong })
    .onClick(() => tap())
  }
}
