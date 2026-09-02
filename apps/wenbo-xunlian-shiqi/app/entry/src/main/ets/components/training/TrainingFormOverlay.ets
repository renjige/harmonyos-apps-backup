import { Theme } from '../design-system/Theme'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { AppIcon } from '../design-system/AppIcon'
import { SolidButton } from '../design-system/SolidButton'
import { TrainingDraft } from '../../models/TrainingModels'
import { TrainingRecordService } from '../../services/TrainingRecordService'

@Component
export struct TrainingFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop draft: TrainingDraft = TrainingRecordService.emptyDraft()
  @Prop formError: string = ''
  @Prop formTitle: string = '记录训练'
  onClose: () => void = () => {}
  onSubmit: () => void = () => {}
  onDraftChange: (d: TrainingDraft) => void = () => {}

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text(this.formTitle)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text('训练类型')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(TrainingRecordService.PRESET_TYPES, (typeName: string) => {
              Text(typeName)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.draft.trainingType === typeName ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.draft.trainingType === typeName ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  const next = TrainingRecordService.copy(this.draft)
                  next.trainingType = typeName
                  this.onDraftChange(next)
                })
            }, (typeName: string) => typeName)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('训练时长（分钟）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.durationMin, placeholder: '例如 30' })
              .type(InputType.Number)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const next = TrainingRecordService.copy(this.draft)
                next.durationMin = v
                this.onDraftChange(next)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          AppDatePickerField({
            label: '训练日期',
            value: this.draft.recordDate,
            onChange: (v: string): void => {
              const next = TrainingRecordService.copy(this.draft)
              next.recordDate = v
              this.onDraftChange(next)
            }
          })

          Text('训练后体感')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(TrainingRecordService.FEELINGS, (feel: string) => {
              Text(feel)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.draft.feeling === feel ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.draft.feeling === feel ? '#FF6B35' : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  const next = TrainingRecordService.copy(this.draft)
                  next.feeling = feel
                  this.onDraftChange(next)
                })
            }, (feel: string) => feel)
          }
          .width('100%')

          Text('主观强度')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(TrainingRecordService.INTENSITIES, (lv: string) => {
              Text(lv)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.draft.intensity === lv ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.draft.intensity === lv ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  const next = TrainingRecordService.copy(this.draft)
                  next.intensity = lv
                  this.onDraftChange(next)
                })
            }, (lv: string) => lv)
          }
          .width('100%')

          Text('完成状态')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(TrainingRecordService.STATUSES, (st: string) => {
              Text(st)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.draft.completeStatus === st ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.draft.completeStatus === st ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  const next = TrainingRecordService.copy(this.draft)
                  next.completeStatus = st
                  this.onDraftChange(next)
                })
            }, (st: string) => st)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('训练心得（可选）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.note, placeholder: '今天完成后的感受，或哪种方式更适合自己' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const next = TrainingRecordService.copy(this.draft)
                next.note = v
                this.onDraftChange(next)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s2 }) {
            Text('训练收获（可选）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.harvest, placeholder: '例如：身体状态更好' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const next = TrainingRecordService.copy(this.draft)
                next.harvest = v
                this.onDraftChange(next)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          if (this.formError.length > 0) {
            Text(this.formError)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      Column() {
        SolidButton({
          label: '保存训练记录',
          tone: 'primary',
          onTap: (): void => { this.onSubmit() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s6 })
      .backgroundColor(Theme.colors().surfaceCard)
      .onClick((): void => { this.onSubmit() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
