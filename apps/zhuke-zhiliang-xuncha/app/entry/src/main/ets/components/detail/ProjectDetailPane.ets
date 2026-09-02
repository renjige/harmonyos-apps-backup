import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { StatusChip } from '../quality/StatusChip'
import { IssueCard } from '../quality/IssueCard'
import { QualityMedia } from '../../services/QualityMedia'
import { IssueRecord, ProjectItem, QualityStats } from '../../models/QualityModels'
import { QualityService } from '../../services/QualityService'
import { QualityNav } from '../../services/QualityNav'

@Component
export struct ProjectDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onProjectId') projectId: string = ''
  @State item: ProjectItem = new ProjectItem()
  @State counts: QualityStats = new QualityStats()
  @State issues: IssueRecord[] = []
  @State missing: boolean = false
  @State confirmDelete: boolean = false
  onBack: () => void = () => {}
  onOpenIssue: (id: string) => void = (_id: string) => {}
  onStart: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onProjectId(): void {
    this.reload()
  }

  private reload(): void {
    const found = QualityService.findProject(this.projectId)
    if (found === undefined) {
      this.missing = true
      return
    }
    this.missing = false
    this.item = found
    this.counts = QualityService.projectCounts(found.id)
    const all = QualityService.issues()
    const mine: IssueRecord[] = []
    for (const row of all) {
      if (row.projectId === found.id && mine.length < 8) {
        mine.push(row)
      }
    }
    this.issues = mine
    this.confirmDelete = false
  }

  private health(): string {
    if (this.counts.foundToday + this.counts.rectifying === 0) {
      return '巡查正常'
    }
    return '整改跟进中'
  }

  private async remove(): Promise<void> {
    await QualityService.deleteProject(this.item.id)
    QualityNav.toast('项目已删除')
    this.onBack()
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
          .onClick(() => this.onBack())
        Text('项目详情')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 20, top: 16, bottom: 8 })

      if (this.missing) {
        Text('项目不存在或已删除')
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(20)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(QualityMedia.cover(this.item.coverKey))
                .width('100%')
                .height(168)
                .objectFit(ImageFit.Cover)
                .borderRadius(18)
                .alt('项目封面')
              Column()
                .width('100%')
                .height(90)
                .linearGradient({
                  angle: 180,
                  colors: [['#00000000', 0], ['#B30F172A', 1]]
                })
                .borderRadius(18)
              Column({ space: 6 }) {
                Text(this.item.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                Text(this.item.location)
                  .fontSize(Theme.type.footnote)
                  .fontColor('#FFFFFF')
              }
              .margin({ left: 16, bottom: 14, right: 16 })
            }
            Row() {
              StatusChip({ label: this.health() })
              Blank()
              if (this.item.isSample) {
                Text('示例').fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
            }
            .width('100%')
            Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Row({ space: 8 }) {
              this.stat('发现问题', `${this.counts.foundToday}`)
              this.stat('整改中', `${this.counts.rectifying}`)
              this.stat('已闭环', `${this.counts.closed}`)
            }
            .width('100%')
            Text('相关问题')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            if (this.issues.length === 0) {
              AppEmpty({ title: '暂无问题', description: '开始巡查后，问题会汇总到这里' })
            } else {
              ForEach(this.issues, (it: IssueRecord) => {
                IssueCard({ item: it, onOpen: (id: string) => this.onOpenIssue(id) })
              }, (it: IssueRecord) => it.id)
            }
            AppButton({ label: '开始巡查', onTap: () => this.onStart() })
            AppButton({ label: '删除项目', variant: 'ghost', onTap: () => { this.confirmDelete = true } })
            if (this.confirmDelete) {
              Column({ space: 8 }) {
                Text('确认删除该项目？相关巡查与问题仍保留在列表中。')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().danger)
                  .width('100%')
                Row({ space: 8 }) {
                  AppButton({ label: '取消', variant: 'secondary', onTap: () => { this.confirmDelete = false } }).layoutWeight(1)
                  AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.remove() } }).layoutWeight(1)
                }.width('100%')
              }.width('100%')
            }
          }
          .padding({ left: 20, right: 20, bottom: 32 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  stat(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
  }
}
