import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { WorkoutRecord, WorkoutTypeOption, TagOption, EnergyOption } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'
import { WorkoutStore } from '../../services/WorkoutStore'
import { AchievementService } from '../../services/StatsService'

@Component
export struct WorkoutEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isCreate: boolean = false
  @Prop seed: WorkoutRecord = new WorkoutRecord()
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State typeKey: string = 'run'
  @State minutesText: string = '30'
  @State noteText: string = ''
  @State dateKey: string = ''
  @State tagKey: string = ''
  @State energyKey: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    if (this.isCreate) {
      this.typeKey = 'run'
      this.minutesText = '30'
      this.noteText = ''
      this.dateKey = DateHelper.todayKey()
      this.tagKey = ''
      this.energyKey = ''
    } else {
      this.typeKey = this.seed.typeKey
      this.minutesText = `${this.seed.durationMinutes()}`
      this.noteText = this.seed.note
      this.dateKey = this.seed.dateKey
      this.tagKey = this.seed.tagKey
      this.energyKey = this.seed.energyKey
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    const mins = parseInt(this.minutesText, 10)
    if (mins !== mins || mins < 1 || mins > 600) {
      this.showToast('时长请填 1～600 分钟')
      return
    }
    if (this.dateKey.length < 8) {
      this.showToast('请选择日期')
      return
    }
    const seconds = mins * 60
    const clamped = DateHelper.clampRecordDates(DateHelper.normalizeKey(this.dateKey), Date.now())
    const normalizedDate = clamped.dateKey
    if (this.isCreate) {
      const rec = WorkoutRecord.createOnDate(this.typeKey, seconds, this.noteText.trim(), normalizedDate)
      rec.tagKey = this.tagKey
      rec.energyKey = this.energyKey
      rec.feeling = this.noteText.trim()
      await WorkoutStore.saveWorkout(rec)
    } else {
      const rec = WorkoutRecord.copyFrom(this.seed)
      rec.typeKey = this.typeKey
      rec.durationSeconds = seconds
      rec.note = this.noteText.trim()
      rec.dateKey = normalizedDate
      rec.tagKey = this.tagKey
      rec.energyKey = this.energyKey
      rec.feeling = this.noteText.trim()
      rec.distanceKm = WorkoutRecord.estimateDistance(this.typeKey, seconds)
      rec.timestamp = Date.now()
      await WorkoutStore.updateWorkout(rec)
    }
    await AchievementService.evaluateAndUnlock()
    this.onSaved()
  }

  @Builder
  TypeChip(opt: WorkoutTypeOption) {
    Text(opt.label)
      .fontSize(Theme.type.caption)
      .fontColor(this.typeKey === opt.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.typeKey === opt.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.typeKey = opt.key })
  }

  @Builder
  TagChip(opt: TagOption) {
    Text(opt.label)
      .fontSize(Theme.type.caption)
      .fontColor(this.tagKey === opt.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.tagKey === opt.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.tagKey = this.tagKey === opt.key ? '' : opt.key })
  }

  @Builder
  EnergyChip(opt: EnergyOption) {
    Text(opt.label)
      .fontSize(Theme.type.caption)
      .fontColor(this.energyKey === opt.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.energyKey === opt.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.energyKey = this.energyKey === opt.key ? '' : opt.key })
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
          Text(this.isCreate ? '补记一场运动' : '编辑运动痕迹')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('运动类型').fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary).width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(WorkoutTypeOption.all(), (opt: WorkoutTypeOption) => {
                this.TypeChip(opt)
              }, (opt: WorkoutTypeOption) => opt.key)
            }
            .width('100%')

            Text('标签（选填）').fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary).width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(TagOption.all(), (opt: TagOption) => {
                this.TagChip(opt)
              }, (opt: TagOption) => opt.key)
            }
            .width('100%')

            Text('运动后状态（选填）').fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary).width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(EnergyOption.all(), (opt: EnergyOption) => {
                this.EnergyChip(opt)
              }, (opt: EnergyOption) => opt.key)
            }
            .width('100%')

            if (this.isCreate) {
              AppDatePickerField({
                label: '运动日期',
                value: this.dateKey,
                placeholder: '选择日期',
                minDaysFromToday: -90,
                maxDaysFromToday: 0,
                onChange: (v: string): void => { this.dateKey = v }
              })
            }

            Text('时长（分钟）').fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary).width('100%')
            TextInput({ text: this.minutesText, placeholder: '例如 30' })
              .onChange((v: string): void => { this.minutesText = v })

            Text('备注（选填）').fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary).width('100%')
            TextInput({ text: this.noteText, placeholder: '今天感觉如何' })
              .onChange((v: string): void => { this.noteText = v })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s4
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)

        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: this.isCreate ? '保存痕迹' : '保存修改',
            variant: 'primary',
            onTap: (): void => { void this.save() }
          })
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.onClose() }
          })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s8
        })
      }
      .width('100%')
      .height('92%')
      .backgroundColor(Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      .onClick((): void => {})

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ top: 48 })
          .zIndex(90)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(70)
  }
}
