import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { StatusChip } from '../quality/StatusChip'
import { CoverImage } from '../quality/CoverImage'
import { IssueRecord, QualityDates, RectifyRecord } from '../../models/QualityModels'
import { QualityLocalStore } from '../../services/QualityLocalStore'
import { QualityService } from '../../services/QualityService'
import { QualityNav } from '../../services/QualityNav'

@Component
export struct IssueDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIssueId') issueId: string = ''
  @State item: IssueRecord = new IssueRecord()
  @State timeline: RectifyRecord[] = []
  @State photos: string[] = []
  @State missing: boolean = false
  @State confirmDelete: boolean = false
  onBack: () => void = () => {}
  onRectify: (id: string) => void = (_id: string) => {}
  onEdit: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  onIssueId(): void {
    this.reload()
  }

  private reload(): void {
    const found = QualityService.findIssue(this.issueId)
    if (found === undefined) {
      this.missing = true
      return
    }
    this.missing = false
    this.item = found
    this.timeline = QualityService.issueTimeline(found.id)
    this.photos = QualityLocalStore.parsePhotos(found.photosJson)
    this.confirmDelete = false
  }

  private async remove(): Promise<void> {
    await QualityService.deleteIssue(this.item.id)
    QualityNav.toast('问题已删除')
    this.onBack()
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
          .onClick(() => this.onBack())
        Text('问题详情')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 20, top: 16, bottom: 8 })

      if (this.missing) {
        Text('数据不存在，可能已被删除')
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(20)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            StatusChip({ label: this.item.status })
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Column({ space: 8 }) {
              this.metaRow('项目', this.item.projectName)
              this.metaRow('位置', this.item.location)
              this.metaRow('问题类型', this.item.category)
              this.metaRow('严重程度', this.item.severity)
              this.metaRow('发现时间', QualityDates.displayTime(this.item.foundAt))
              if (this.item.isSample) {
                this.metaRow('数据', '示例数据，可删除')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)
            Text('问题描述')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.description.length > 0 ? this.item.description : '暂无描述')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.item.requirement.length > 0) {
              Text('整改要求')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(this.item.requirement)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            Text('现场照片')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            if (this.photos.length === 0) {
              Text('暂无现场照片')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            } else {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.photos, (p: string) => {
                  CoverImage({ coverKey: p, imgWidth: 96, imgHeight: 96, radius: 12 })
                }, (p: string) => p)
              }
              .width('100%')
            }
            Text('整改记录')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Column({ space: 0 }) {
              ForEach(this.timeline, (row: RectifyRecord) => {
                Row({ space: 12 }) {
                  Column() {
                    Column()
                      .width(8)
                      .height(8)
                      .borderRadius(4)
                      .backgroundColor(Theme.colors().brandPrimary)
                    Column()
                      .width(2)
                      .layoutWeight(1)
                      .backgroundColor(Theme.colors().strokeStrong)
                  }
                  .width(12)
                  .height(56)
                  Column({ space: 4 }) {
                    Text(QualityDates.displayTime(row.createdAt))
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    Text(row.note.length > 0 ? row.note : row.status)
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
              }, (row: RectifyRecord) => row.id)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)

            AppButton({
              label: '编辑问题',
              variant: 'secondary',
              onTap: () => this.onEdit(this.item.id)
            })
            AppButton({
              label: '删除问题',
              variant: 'ghost',
              onTap: () => { this.confirmDelete = true }
            })
            if (this.confirmDelete) {
              Column({ space: 8 }) {
                Text('确认删除该问题？删除后不可恢复。')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().danger)
                  .width('100%')
                Row({ space: 8 }) {
                  AppButton({
                    label: '取消',
                    variant: 'secondary',
                    onTap: () => { this.confirmDelete = false }
                  }).layoutWeight(1)
                  AppButton({
                    label: '确认删除',
                    variant: 'danger',
                    onTap: (): void => { void this.remove() }
                  }).layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
            }
          }
          .padding({ left: 20, right: 20, bottom: 24 })
        }
        .layoutWeight(1)

        Column() {
          AppButton({
            label: '提交整改结果',
            onTap: () => this.onRectify(this.item.id)
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20, top: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  metaRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width(88)
      Text(value)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
  }
}
