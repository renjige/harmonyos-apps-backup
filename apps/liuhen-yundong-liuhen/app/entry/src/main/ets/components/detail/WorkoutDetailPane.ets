import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { WorkoutRecord, WorkoutTypeOption, TagOption, EnergyOption } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'
import { WorkoutStore } from '../../services/WorkoutStore'

@Component
export struct WorkoutDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: WorkoutRecord = new WorkoutRecord()
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onEdit: () => void = () => {}
  @State confirmDelete: boolean = false

  private async handleDelete(): Promise<void> {
    await WorkoutStore.deleteWorkout(this.record.id)
    this.confirmDelete = false
    this.onChanged()
    this.onClose()
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('运动痕迹')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_trace'))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column() {
                Blank()
                Column({ space: 4 }) {
                  Text(WorkoutTypeOption.labelFor(this.record.typeKey))
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text(DateHelper.displayDate(this.record.dateKey))
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['#00000000', 0], ['#CC1A1A2E', 1]]
                })
              }
              .width('100%')
              .height(180)
            }

            Column({ space: Theme.space.s3 }) {
              this.MetaRow('时长', DateHelper.formatDuration(this.record.durationSeconds))
              this.MetaRow('参考距离', `${this.record.distanceKm} km（按时长估算，非 GPS）`)
              this.MetaRow('配速', this.record.paceLabel())
              this.MetaRow('消耗', `约 ${this.record.caloriesEstimate()} kcal`)
              this.MetaRow('标签', TagOption.labelFor(this.record.tagKey))
              this.MetaRow('状态', EnergyOption.labelFor(this.record.energyKey))
            }
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s2 }) {
              Text('备注')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
              Text(this.record.note.length > 0 ? this.record.note : '还没有备注，可点编辑补上感受')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            AppButton({
              label: '编辑这条痕迹',
              variant: 'primary',
              onTap: (): void => { this.onEdit() }
            })
            AppButton({
              label: '删除这条记录',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('92%')
      .backgroundColor(Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })

      if (this.confirmDelete) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)
        Column({ space: Theme.space.s4 }) {
          Text('确定删除这条运动痕迹？删除后统计会立即更新。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
              .layoutWeight(1)
            AppButton({ label: '删除', variant: 'primary', onTap: (): void => { void this.handleDelete() } })
              .layoutWeight(1)
          }
          .width('100%')
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(60)
  }

  @Builder
  MetaRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
      Blank()
      Text(value)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
  }
}
