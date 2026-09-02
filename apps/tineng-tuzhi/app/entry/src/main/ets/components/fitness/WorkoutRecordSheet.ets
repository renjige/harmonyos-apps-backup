import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextInputField } from '../design-system/AppTextInputField'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { AppIcon } from '../design-system/AppIcon'
import { CompleteStateOption, WorkoutRecord } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'
import { WorkoutStore } from '../../services/WorkoutStore'
import { FeelingChips } from './FeelingChips'
import { StarRating } from './StarRating'
import { TagChips } from './TagChips'
import { WorkoutTypeGrid } from './WorkoutTypeGrid'

@Component
export struct WorkoutRecordSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onSeedChange') editingId: string = ''
  @Prop @Watch('onSeedChange') seedDateKey: string = ''
  @Prop @Watch('onSeedChange') seedTypeKey: string = ''
  @Prop @Watch('onSeedChange') seedDurationMinutes: number = 0
  @Prop @Watch('onSeedChange') seedSessionTitle: string = ''
  onClose: () => void = () => {}
  onSave: (record: WorkoutRecord) => void = () => {}
  @State typeKey: string = 'running'
  @State durationInput: string = '30'
  @State distanceInput: string = ''
  @State caloriesInput: string = ''
  @State caloriesManual: boolean = false
  @State hrZone: string = ''
  @State noteText: string = ''
  @State feelingKey: string = ''
  @State tagKey: string = ''
  @State insightText: string = ''
  @State sessionTitle: string = ''
  @State starRating: number = 0
  @State completeKey: string = 'done'
  @State dateKey: string = ''
  @StorageLink('pendingTag') pendingTag: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadSeed()
  }

  onSeedChange(): void {
    void this.loadSeed()
  }

  private async loadSeed(): Promise<void> {
    if (this.editingId.length > 0) {
      const rec = await WorkoutStore.findById(this.editingId)
      if (rec !== undefined) {
        this.typeKey = rec.typeKey
        this.durationInput = `${rec.durationMinutes}`
        this.distanceInput = rec.distanceKm > 0 ? `${rec.distanceKm}` : ''
        this.caloriesInput = `${rec.calories}`
        this.caloriesManual = rec.caloriesManual
        this.hrZone = rec.heartRateZone
        this.noteText = rec.note
        this.feelingKey = rec.feeling
        this.tagKey = rec.tag
        this.insightText = rec.insight
        this.sessionTitle = rec.sessionTitle
        this.starRating = rec.starRating
        this.completeKey = rec.completeState.length > 0 ? rec.completeState : 'done'
        this.dateKey = rec.dateKey
        return
      }
    }
    this.typeKey = 'running'
    this.durationInput = '30'
    this.distanceInput = ''
    this.caloriesInput = ''
    this.caloriesManual = false
    this.hrZone = ''
    this.noteText = ''
    this.feelingKey = ''
    this.tagKey = this.pendingTag
    this.insightText = ''
    this.sessionTitle = ''
    this.starRating = 0
    this.completeKey = 'done'
    this.dateKey = this.seedDateKey.length > 0 ? this.seedDateKey : DateHelper.todayKey()
    if (this.seedTypeKey.length > 0) {
      this.typeKey = this.seedTypeKey
    }
    if (this.seedDurationMinutes > 0) {
      this.durationInput = `${this.seedDurationMinutes}`
      this.caloriesInput = `${WorkoutRecord.estimateCalories(this.typeKey, this.seedDurationMinutes)}`
    }
    if (this.seedSessionTitle.length > 0) {
      this.sessionTitle = this.seedSessionTitle
    }
    this.refreshCalories()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private refreshCalories(): void {
    if (this.caloriesManual) {
      return
    }
    const mins = parseInt(this.durationInput, 10)
    if (isNaN(mins) || mins <= 0) {
      this.caloriesInput = '0'
      return
    }
    this.caloriesInput = `${WorkoutRecord.estimateCalories(this.typeKey, mins)}`
  }

  private handleTypeSelect(key: string): void {
    this.typeKey = key
    this.refreshCalories()
  }

  private handleDurationChange(v: string): void {
    this.durationInput = v
    this.refreshCalories()
  }

  private handleCaloriesChange(v: string): void {
    this.caloriesInput = v
    this.caloriesManual = true
  }

  private handleSave(): void {
    const mins = parseInt(this.durationInput, 10)
    if (isNaN(mins) || mins <= 0) {
      this.showToast('请输入有效运动时长（分钟）')
      return
    }
    const cals = parseInt(this.caloriesInput, 10)
    const dist = this.distanceInput.length > 0 ? parseFloat(this.distanceInput) : 0
    const rec = WorkoutRecord.createNew(this.dateKey.length > 0 ? this.dateKey : DateHelper.todayKey())
    if (this.editingId.length > 0) {
      rec.id = this.editingId
    }
    rec.typeKey = this.typeKey
    rec.durationMinutes = mins
    rec.distanceKm = isNaN(dist) ? 0 : dist
    rec.calories = isNaN(cals) ? WorkoutRecord.estimateCalories(this.typeKey, mins) : cals
    rec.caloriesManual = this.caloriesManual
    rec.heartRateZone = this.hrZone.trim()
    rec.note = this.noteText.trim()
    rec.feeling = this.feelingKey
    rec.tag = this.tagKey
    rec.insight = this.insightText.trim()
    rec.sessionTitle = this.sessionTitle.trim()
    rec.starRating = this.starRating
    rec.completeState = this.completeKey
    rec.timestamp = Date.now()
    this.onSave(rec)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick((): void => this.onClose())
          Text(this.editingId.length > 0 ? '编辑训练日志' : '训练日志')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Row().width(28)
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4, bottom: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Column({ space: Theme.space.s2 }) {
              Text('训练名称')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.sessionTitle,
                placeholder: '例如：核心力量训练',
                onChange: (v: string): void => { this.sessionTitle = v }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('运动类型')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              WorkoutTypeGrid({
                selectedKey: this.typeKey,
                onSelect: (key: string): void => { this.handleTypeSelect(key) }
              })
            }
            .width('100%')

            AppDatePickerField({
              label: '运动日期',
              value: this.dateKey,
              placeholder: '选择日期',
              minDaysFromToday: -90,
              maxDaysFromToday: 0,
              onChange: (v: string): void => { this.dateKey = v }
            })

            Column({ space: Theme.space.s2 }) {
              Text('时长（分钟）')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.durationInput,
                placeholder: '例如 30',
                numeric: true,
                onChange: (v: string): void => { this.handleDurationChange(v) }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('距离（公里，可选）')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.distanceInput,
                placeholder: '例如 5.2',
                onChange: (v: string): void => { this.distanceInput = v }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Row() {
                Text('消耗（千卡）')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                Blank()
                Text(this.caloriesManual ? '手动' : '自动估算')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .width('100%')
              AppTextInputField({
                text: this.caloriesInput,
                placeholder: '自动估算',
                numeric: true,
                onChange: (v: string): void => { this.handleCaloriesChange(v) }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('心率区间（可选）')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.hrZone,
                placeholder: '例如 Zone 2',
                onChange: (v: string): void => { this.hrZone = v }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('完成状态')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(CompleteStateOption.all(), (o: CompleteStateOption) => {
                  Text(o.label)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.completeKey === o.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.completeKey === o.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.completeKey = o.key })
                }, (o: CompleteStateOption) => o.key)
              }
              .width('100%')
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('完成质量')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              StarRating({
                value: this.starRating,
                onChange: (n: number): void => { this.starRating = n }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('体感（可选）')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              FeelingChips({
                selectedKey: this.feelingKey,
                onSelect: (key: string): void => { this.feelingKey = key }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('训练标签（可选）')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              TagChips({
                selectedKey: this.tagKey,
                onSelect: (key: string): void => { this.tagKey = key }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('备注 / 训练内容')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.noteText,
                placeholder: '今天练了什么、完成情况',
                onChange: (v: string): void => { this.noteText = v }
              })
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('训练心得（可选）')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.insightText,
                placeholder: '训练后的身体感受',
                onChange: (v: string): void => { this.insightText = v }
              })
            }
            .width('100%')

            AppButton({
              label: this.editingId.length > 0 ? '保存修改' : '保存记录',
              variant: 'primary',
              onTap: (): void => { this.handleSave() }
            })

            Row().height(Theme.space.s10)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ top: 48 })
          .backgroundColor('#1A2332')
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
    .height('100%')
  }
}
