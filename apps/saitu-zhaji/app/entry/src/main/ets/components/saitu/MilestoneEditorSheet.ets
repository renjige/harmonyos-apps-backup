import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { Journey, JourneyMilestone } from '../../models/SaituModels'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituTrackStore } from '../../services/SaituTrackStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct MilestoneEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEditorArgsChange') milestoneId: string = ''
  @Prop @Watch('onEditorArgsChange') journeyId: string = ''
  onSaved: () => void = () => {}
  @State title: string = ''
  @State note: string = ''
  @State dueDate: string = ''
  @State journeys: Journey[] = []
  @State selectedJourneyId: string = ''
  @State toastText: string = ''
  private editing: JourneyMilestone = new JourneyMilestone()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onEditorArgsChange(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.journeys = await SaituLocalStore.loadJourneys()
    if (this.milestoneId.length > 0) {
      const found = await SaituTrackStore.findMilestone(this.milestoneId)
      if (found !== undefined) {
        this.editing = found
        this.title = found.title
        this.note = found.note
        this.dueDate = found.dueDate
        this.selectedJourneyId = found.journeyId
        return
      }
    }
    this.editing = JourneyMilestone.createNew(this.journeyId)
    this.selectedJourneyId = this.journeyId
    if (this.selectedJourneyId.length === 0 && this.journeys.length > 0) {
      this.selectedJourneyId = this.journeys[0].id
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async save(): Promise<void> {
    const t = this.title.trim()
    if (t.length === 0) {
      this.showToast('请填写节点名称')
      return
    }
    if (this.selectedJourneyId.length === 0) {
      this.showToast('请先创建旅途，再添加节点')
      return
    }
    this.editing.title = t
    this.editing.note = this.note.trim()
    this.editing.dueDate = this.dueDate
    this.editing.journeyId = this.selectedJourneyId
    await SaituTrackStore.saveMilestone(this.editing)
    SaituDetailNav.closeMilestoneEditor()
    this.onSaved()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: this.milestoneId.length > 0 ? '编辑节点' : '新建赛途节点',
          onBack: (): void => SaituDetailNav.closeMilestoneEditor()
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '例如：完成 5km 配速突破' })
              .onChange((v: string): void => { this.title = v })
            TextArea({ text: this.note, placeholder: '达成标准、训练要点或备注' })
              .height(100)
              .onChange((v: string): void => { this.note = v })
            AppDatePickerField({
              label: '目标日期',
              value: this.dueDate,
              placeholder: '选择节点日期',
              minDaysFromToday: 0,
              maxDaysFromToday: 365,
              onChange: (v: string): void => { this.dueDate = v }
            })
            Text('归属旅途')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.journeys, (j: Journey) => {
                Text(j.name)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.selectedJourneyId === j.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.selectedJourneyId === j.id ? j.color : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.selectedJourneyId = j.id })
              }, (j: Journey) => j.id)
            }
            AppButton({ label: '保存节点', variant: 'primary', onTap: (): void => { void this.save() } })
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
