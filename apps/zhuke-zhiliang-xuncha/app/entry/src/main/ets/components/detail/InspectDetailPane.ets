import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { StatusChip } from '../quality/StatusChip'
import { IssueCard } from '../quality/IssueCard'
import { InspectionItem, InspectionRecord, IssueRecord, QualityDates } from '../../models/QualityModels'
import { QualityLocalStore } from '../../services/QualityLocalStore'
import { QualityService } from '../../services/QualityService'
import { QualityNav } from '../../services/QualityNav'

@Component
export struct InspectDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onInspectId') inspectId: string = ''
  @State row: InspectionRecord = new InspectionRecord()
  @State items: InspectionItem[] = []
  @State issues: IssueRecord[] = []
  @State missing: boolean = false
  @State confirmDelete: boolean = false
  onBack: () => void = () => {}
  onOpenIssue: (id: string) => void = (_id: string) => {}
  onResume: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  onInspectId(): void {
    this.reload()
  }

  private reload(): void {
    const found = QualityService.findInspection(this.inspectId)
    if (found === undefined) {
      this.missing = true
      return
    }
    this.missing = false
    this.row = found
    this.items = QualityLocalStore.parseItems(found.itemsJson)
    this.issues = QualityService.issuesOfInspection(found.id)
    this.confirmDelete = false
  }

  private async remove(): Promise<void> {
    await QualityService.deleteInspection(this.row.id)
    QualityNav.toast('巡查记录已删除')
    this.onBack()
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
          .onClick(() => this.onBack())
        Text('巡查记录')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 20, top: 16, bottom: 8 })

      if (this.missing) {
        Text('巡查不存在或已删除')
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(20)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Text(this.row.projectName)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Column({ space: 8 }) {
              this.meta('巡查日期', QualityDates.display(this.row.inspectDate))
              this.meta('巡查区域', this.row.area)
              this.meta('巡查类型', this.row.inspectType)
              this.meta('检查项总数', `${this.row.itemCount}`)
              this.meta('正常数量', `${this.row.okCount}`)
              this.meta('问题数量', `${this.row.issueCount}`)
              Row() {
                Text('当前状态').fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width(88)
                StatusChip({ label: this.row.status })
              }.width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)

            if (this.row.remark.length > 0) {
              Text(this.row.remark)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }

            Text('本次发现问题')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            if (this.issues.length === 0) {
              AppEmpty({ title: '本次未记录问题', description: '可返回检查页将异常项转为质量问题' })
            } else {
              ForEach(this.issues, (it: IssueRecord) => {
                IssueCard({ item: it, onOpen: (id: string) => this.onOpenIssue(id) })
              }, (it: IssueRecord) => it.id)
            }

            if (this.row.status !== '已完成') {
              AppButton({
                label: '继续检查',
                onTap: () => this.onResume(this.row.id)
              })
            }
            AppButton({
              label: '删除记录',
              variant: 'ghost',
              onTap: () => { this.confirmDelete = true }
            })
            if (this.confirmDelete) {
              Column({ space: 8 }) {
                Text('确认删除该巡查记录？')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().danger)
                  .width('100%')
                Row({ space: 8 }) {
                  AppButton({ label: '取消', variant: 'secondary', onTap: () => { this.confirmDelete = false } })
                    .layoutWeight(1)
                  AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.remove() } })
                    .layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
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
  meta(label: string, value: string) {
    Row() {
      Text(label).fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width(88)
      Text(value).fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).layoutWeight(1)
    }
    .width('100%')
  }
}
