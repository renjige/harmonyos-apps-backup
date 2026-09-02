import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { Journey } from '../../models/SaituModels'
import { SportEvent, TrainingLog } from '../../models/SaituSportModels'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituSportStore } from '../../services/SaituSportStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct TrainingLogEditor {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituTrainingEditorId') @Watch('onTargetChange') editorId: string = ''
  @Prop @Watch('onTargetChange') editorSession: number = 0
  onSaved: () => void = () => {}
  @State title: string = ''
  @State logDate: string = ''
  @State sportType: string = 'mixed'
  @State durationMin: number = 30
  @State intensity: number = 3
  @State body: string = ''
  @State journeys: Journey[] = []
  @State journeyId: string = ''
  @State toastText: string = ''
  @State isEdit: boolean = false
  private editing: TrainingLog = new TrainingLog()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onTargetChange(): void {
    void this.bootstrap()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async bootstrap(): Promise<void> {
    this.journeys = await SaituLocalStore.loadJourneys()
    const id = this.editorId
    if (id.length > 0) {
      const found = await SaituSportStore.findTraining(id)
      if (found !== undefined) {
        this.editing = found
        this.title = found.title
        this.logDate = found.logDate
        this.sportType = found.sportType
        this.durationMin = found.durationMin
        this.intensity = found.intensity
        this.body = found.body
        this.journeyId = found.journeyId
        this.isEdit = true
        return
      }
    }
    this.editing = TrainingLog.create()
    this.title = ''
    this.logDate = this.editing.logDate
    this.sportType = 'mixed'
    this.durationMin = 30
    this.intensity = 3
    this.body = ''
    this.journeyId = this.journeys.length > 0 ? this.journeys[0].id : ''
    this.isEdit = false
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写训练主题')
      return
    }
    this.editing.title = this.title.trim()
    this.editing.logDate = this.logDate
    this.editing.sportType = this.sportType
    this.editing.durationMin = this.durationMin
    this.editing.intensity = this.intensity
    this.editing.body = this.body.trim()
    this.editing.journeyId = this.journeyId
    await SaituSportStore.saveTraining(this.editing)
    SaituDetailNav.closeTrainingEditor()
    this.onSaved()
  }

  @Builder
  TypeChip(key: string) {
    Text(SportEvent.typeName(key))
      .fontSize(Theme.type.bodyS)
      .fontColor(this.sportType === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.sportType === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.sportType = key })
  }

  @Builder
  IntensityChip(level: number) {
    Text(`${level}`)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.intensity === level ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.intensity === level ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.intensity = level })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: this.isEdit ? '编辑训练日志' : '新建训练日志',
          onBack: (): void => SaituDetailNav.closeTrainingEditor()
        })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('记录自主训练、体能与专项练习，与观赛档案互补。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '训练主题，如 晨跑 5 公里' })
              .onChange((v: string): void => { this.title = v })
            AppDatePickerField({
              label: '训练日期',
              value: this.logDate,
              placeholder: '选择日期',
              minDaysFromToday: -4000,
              maxDaysFromToday: 30,
              onChange: (v: string): void => { this.logDate = v }
            })
            Text('项目')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(SportEvent.sportTypes(), (k: string) => {
                this.TypeChip(k)
              }, (k: string) => k)
            }
            TextInput({ text: `${this.durationMin}`, placeholder: '时长（分钟）' })
              .type(InputType.Number)
              .onChange((v: string): void => {
                const n = parseInt(v, 10)
                this.durationMin = isNaN(n) ? 30 : n
              })
            Text('强度 1-5')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              this.IntensityChip(1)
              this.IntensityChip(2)
              this.IntensityChip(3)
              this.IntensityChip(4)
              this.IntensityChip(5)
            }
            if (this.journeys.length > 0) {
              Text('关联赛途（可选）')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.journeys, (j: Journey) => {
                  Text(j.name)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.journeyId === j.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.journeyId === j.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.journeyId = j.id })
                }, (j: Journey) => j.id)
              }
            }
            TextArea({ text: this.body, placeholder: '训练内容、组数、心率感受、下次改进…' })
              .height(140)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => { this.body = v })
            AppButton({ label: this.isEdit ? '保存修改' : '保存', variant: 'primary', onTap: (): void => { void this.save() } })
            Blank().height(Theme.space.s10)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
