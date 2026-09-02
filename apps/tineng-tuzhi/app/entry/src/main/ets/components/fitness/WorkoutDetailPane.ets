import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from '../detail/DetailShell'
import { CompleteStateOption, FeelingOption, WorkoutRecord, WorkoutTagOption, WorkoutTypeOption } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct WorkoutDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recordId: string = ''
  @Prop typeKey: string = 'other'
  @Prop dateKey: string = ''
  @Prop durationMinutes: number = 0
  @Prop calories: number = 0
  @Prop distanceKm: number = 0
  @Prop heartRateZone: string = ''
  @Prop feeling: string = ''
  @Prop tag: string = ''
  @Prop note: string = ''
  @Prop insight: string = ''
  @Prop sessionTitle: string = ''
  @Prop starRating: number = 0
  @Prop completeState: string = 'done'
  onClose: () => void = () => {}
  onDelete: () => void = () => {}
  onEdit: () => void = () => {}
  @State confirmDelete: boolean = false

  build() {
    Stack() {
      Column() {
        DetailShell({
          title: '运动详情',
          onClose: (): void => this.onClose()
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column() {
              Column() {
                AppIcon({ name: 'chart', iconSize: Theme.icon.xl, color: '#FFFFFF' })
              }
              .width(72)
              .height(72)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#1A2332')
              .borderRadius(Theme.radius.pill)
              .margin({ bottom: Theme.space.s4 })

              Text(this.sessionTitle.length > 0 ? this.sessionTitle : WorkoutTypeOption.labelFor(this.typeKey))
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.dateKey.length >= 8 ? DateHelper.displayDate(this.dateKey) : '')
                .fontSize(Theme.type.body)
                .fontColor('#FFFFFF')
                .margin({ top: Theme.space.s1 })
            }
            .width('100%')
            .padding(Theme.space.s6)
            .backgroundColor('#FF6B35')
            .borderRadius(Theme.radius.lg)

            Row({ space: Theme.space.s3 }) {
              this.MetaChip(`${this.durationMinutes}`, '分钟')
              this.MetaChip(`${this.calories}`, '千卡')
              if (this.distanceKm > 0) {
                this.MetaChip(`${this.distanceKm}`, '公里')
              }
            }
            .width('100%')

            Text(`完成状态 · ${CompleteStateOption.labelFor(this.completeState)}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')

            if (this.starRating > 0) {
              Text(`完成质量  ${this.starRating} / 5`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }

            if (this.heartRateZone.length > 0) {
              Text(`心率区间 · ${this.heartRateZone}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            if (this.feeling.length > 0) {
              Text(`体感 · ${FeelingOption.labelFor(this.feeling)}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            if (this.tag.length > 0) {
              Text(`标签 · ${WorkoutTagOption.labelFor(this.tag)}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }

            Column({ space: Theme.space.s2 }) {
              Text('训练内容')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`${WorkoutTypeOption.labelFor(this.typeKey)} · ${this.durationMinutes} 分钟`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
              Text(this.note.length > 0 ? this.note : '暂无训练内容备注')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(22)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s2 }) {
              Text('训练心得')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(this.insight.length > 0 ? this.insight : '暂无心得，可在编辑里补记身体感受。')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(22)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            AppButton({
              label: '编辑这条记录',
              variant: 'primary',
              onTap: (): void => this.onEdit()
            })
            AppButton({
              label: '删除记录',
              variant: 'danger',
              onTap: (): void => { this.confirmDelete = true }
            })
            Row().height(Theme.space.s10)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.confirmDelete) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Theme.colors().overlayScrim)
          Column({ space: Theme.space.s4 }) {
            Text('确认删除这条记录？')
              .fontSize(Theme.type.title3)
              .fontColor(Theme.colors().textPrimary)
            Text('删除后不可恢复。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppButton({
                  label: '取消',
                  variant: 'secondary',
                  onTap: (): void => { this.confirmDelete = false }
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: '确认删除',
                  variant: 'danger',
                  onTap: (): void => {
                    this.confirmDelete = false
                    this.onDelete()
                  }
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
          }
          .width('84%')
          .padding(Theme.space.s6)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }
        .width('100%')
        .height('100%')
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MetaChip(value: string, unit: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(unit)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }
}
