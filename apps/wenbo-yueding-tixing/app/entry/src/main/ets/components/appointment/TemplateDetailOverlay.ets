import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { AppointmentFormDraft, AppointmentTemplate } from '../../models/AppointmentModels'
import { AppointmentMedia } from '../../services/AppointmentMedia'
import { AppointmentLocalStore } from '../../services/AppointmentLocalStore'

@Component
export struct TemplateDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop template: AppointmentTemplate = new AppointmentTemplate()
  @State wizardTitle: string = ''
  @State wizardDate: string = ''
  @State wizardTime: string = ''
  @State wizardContact: string = ''
  @State wizardDuration: number = 60
  @State prepMask: string = ''
  onClose: () => void = () => {}
  onCreateDraft: (draft: AppointmentFormDraft) => void = () => {}

  aboutToAppear(): void {
    this.wizardTitle = this.template.title
    this.wizardDate = AppointmentLocalStore.today()
    this.wizardTime = this.template.defaultTime.length > 0 ? this.template.defaultTime : '09:00'
    this.wizardDuration = this.template.durationMin > 0 ? this.template.durationMin : 60
    const parts = this.template.prepLine.split('|')
    let mask = ''
    for (let i = 0; i < parts.length; i++) {
      mask = `${mask}1`
    }
    this.prepMask = mask
  }

  private prepNames(): string[] {
    if (this.template.prepLine.length === 0) {
      return []
    }
    return this.template.prepLine.split('|')
  }

  private buildDraft(): AppointmentFormDraft {
    const draft = new AppointmentFormDraft()
    draft.title = this.wizardTitle.trim()
    draft.dueDate = this.wizardDate
    draft.dueTime = this.wizardTime
    draft.contactName = this.wizardContact.trim()
    draft.durationMin = this.wizardDuration
    draft.templateId = this.template.id
    draft.scene = this.template.scene
    draft.note = this.template.summary.length > 0 ? this.template.summary : this.template.body
    draft.repeatType = this.template.repeatType.length > 0 ? this.template.repeatType : 'once'
    draft.remindBeforeKey = this.template.remindBeforeKey.length > 0 ? this.template.remindBeforeKey : '60'
    const names: string[] = []
    const list = this.prepNames()
    for (let i = 0; i < list.length; i++) {
      if (i < this.prepMask.length && this.prepMask.slice(i, i + 1) === '1') {
        names.push(list[i])
      }
    }
    draft.prepLine = names.length > 0 ? names.join('|') : this.template.prepLine
    return draft
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(AppointmentMedia.cover(this.template.coverKey))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(160)
              .linearGradient({
                angle: 180,
                colors: [['rgba(8,42,90,0.05)', 0], ['rgba(8,42,90,0.76)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Text('创建向导')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .padding(18)
          }
          Text(this.template.summary)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Column({ space: 6 }) {
            Text('约定标题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.wizardTitle, placeholder: '可改成你的具体事项' })
              .onChange((v: string) => { this.wizardTitle = v })
          }
          .width('100%')

          AppDatePickerField({
            label: '日期',
            value: this.wizardDate,
            minDaysFromToday: 0,
            maxDaysFromToday: 365,
            onChange: (v: string) => { this.wizardDate = v }
          })
          AppTimePickerField({
            label: '时间',
            value: this.wizardTime,
            onChange: (v: string) => { this.wizardTime = v }
          })

          Column({ space: 6 }) {
            Text('相关人（选填）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.wizardContact, placeholder: '例如：张经理 / 家人' })
              .onChange((v: string) => { this.wizardContact = v })
          }
          .width('100%')

          if (this.prepNames().length > 0) {
            Column({ space: 8 }) {
              Text('会前准备（勾选需要的项）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              ForEach(this.prepNames(), (name: string, index: number) => {
                Row({ space: 8 }) {
                  Text(index < this.prepMask.length && this.prepMask.slice(index, index + 1) === '1' ?
                    '已选' : '未选')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width(40)
                  Text(name)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                }
                .width('100%')
                .padding(10)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => {
                  let next = ''
                  for (let i = 0; i < this.prepNames().length; i++) {
                    let ch = i < this.prepMask.length ? this.prepMask.slice(i, i + 1) : '0'
                    if (i === index) {
                      ch = ch === '1' ? '0' : '1'
                    }
                    next = `${next}${ch}`
                  }
                  this.prepMask = next
                })
              }, (name: string, index: number) => `${index}_${name}`)
            }
            .width('100%')
          }

          AppButton({
            label: '下一步：确认细节',
            onTap: (): void => { this.onCreateDraft(this.buildDraft()) }
          })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
