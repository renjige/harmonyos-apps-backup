import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { StatusTag } from '../inspect/StatusTag'
import { InspectRecord, InspectMedia, InspectStatus, PhotoList } from '../../models/InspectModels'
import { InspectGuide } from '../../models/InspectGuide'
import { InspectLocalStore } from '../../services/InspectLocalStore'
import { InspectService } from '../../services/InspectService'
import { InspectNav } from '../../services/InspectNav'
import { ExportService } from '../../services/ExportService'

@Component
export struct InspectDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: InspectRecord = new InspectRecord()
  @Prop stamp: number = 0
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}
  @State toastText: string = ''

  private cover(): Resource {
    return InspectMedia.cover(this.record.category)
  }

  private firstPhoto(): string {
    const photos = PhotoList.split(this.record.photosCsv)
    for (const uri of photos) {
      return uri
    }
    return ''
  }

  private hasPhoto(): boolean {
    return this.firstPhoto().length > 0
  }

  private photos(): string[] {
    return PhotoList.split(this.record.photosCsv)
  }

  private async copyText(): Promise<void> {
    const ok = await ExportService.copyRecord(this.record)
    this.toastText = ok ? '验收摘要已复制' : '复制失败，请稍后重试'
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async doReinspect(): Promise<void> {
    const row = await InspectService.reinspect(this.record.id)
    if (row !== null) {
      InspectNav.openEdit(row.id)
    }
  }

  build() {
    Stack() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack() {
            if (this.hasPhoto()) {
              Image(this.firstPhoto())
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
            } else {
              Image(this.cover())
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
            }
          }
          .width('100%')
          .height(140)
          .clip(true)

          Column({ space: 8 }) {
            Text(this.record.materialName)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            StatusTag({ result: this.record.result })
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3
          })

          Column({ space: Theme.space.s4 }) {
            AppCard({ title: '基础信息' }) {
              this.metaBlock()
            }
            AppCard({ title: '检查结果' }) {
              this.checkBlock()
            }
            AppCard({ title: '现场照片' }) {
              this.photoBlock()
            }
            AppCard({ title: '验收备注' }) {
              Text(this.record.remark.length > 0 ? this.record.remark : '无备注')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            AppButton({
              label: '查看本类要点',
              variant: 'secondary',
              onTap: (): void => InspectNav.openGuide(this.record.category)
            })
            AppButton({
              label: '复制验收摘要',
              variant: 'secondary',
              onTap: (): void => { void this.copyText() }
            })
            if (this.record.result === 'fail' || this.record.result === 'pending') {
              AppButton({
                label: '异常跟进',
                onTap: (): void => InspectNav.openFollow(this.record.id)
              })
              AppButton({
                label: '发起复验',
                variant: 'secondary',
                onTap: (): void => { void this.doReinspect() }
              })
            }
            AppButton({
              label: '编辑记录',
              onTap: (): void => this.onEdit()
            })
            AppButton({
              label: '删除记录',
              variant: 'secondary',
              onTap: (): void => this.onDelete()
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')

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
  }

  @Builder
  metaBlock() {
    Column({ space: 10 }) {
      this.metaRow('工点 / 工程', this.record.projectName.length > 0 ? this.record.projectName : '未填写')
      this.metaRow('批次 / 送货单', this.record.batchNo.length > 0 ? this.record.batchNo : '未填写')
      this.metaRow('材料类别', this.record.category)
      this.metaRow('规格型号', this.record.spec.length > 0 ? this.record.spec : '未填写')
      this.metaRow('数量', `${this.record.quantity} ${this.record.unit}`)
      this.metaRow('供应商', this.record.supplier.length > 0 ? this.record.supplier : '未填写')
      this.metaRow('进场日期', this.record.arrivalDate)
      this.metaRow('记录时间', InspectLocalStore.displayTime(this.record.updatedAt))
    }
    .width('100%')
  }

  @Builder
  metaRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width(88)
      Text(value)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  checkBlock() {
    Column({ space: 8 }) {
      Text(`外观检查：${InspectStatus.checkLabel('look', this.record.checkAppearance)}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`包装检查：${InspectStatus.checkLabel('pack', this.record.checkPacking)}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`数量检查：${InspectStatus.checkLabel('qty', this.record.checkQty)}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`资料检查：${InspectStatus.checkLabel('docs', this.record.checkDocs)}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`${InspectGuide.of(this.record.category).extraA}：${InspectStatus.checkLabel('look', this.record.extraA)}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`${InspectGuide.of(this.record.category).extraB}：${InspectStatus.checkLabel('look', this.record.extraB)}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.record.followUpNote.length > 0) {
        Text(`异常跟进：${this.record.followUpNote}`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      if (this.record.parentId.length > 0) {
        Text('本条为复验记录')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  photoBlock() {
    Column({ space: 8 }) {
      if (this.photos().length === 0) {
        Text('未添加现场照片')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.photos(), (uri: string) => {
            Image(uri)
              .width('31%')
              .height(88)
              .objectFit(ImageFit.Cover)
              .borderRadius(12)
              .margin({ right: 6, bottom: 6 })
          }, (uri: string) => uri)
        }
        .width('100%')
      }
    }
    .width('100%')
    .opacity(this.stamp >= 0 ? 1 : 1)
  }
}
