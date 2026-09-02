import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ChipSelectGroup } from '../quality/ChoiceChip'
import { QualityCatalog, QualityDates, InspectionRecord } from '../../models/QualityModels'
import { QualityService } from '../../services/QualityService'
import { QualityNav } from '../../services/QualityNav'

@Component
export struct StartInspectForm {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State projectId: string = ''
  @State projectName: string = ''
  @State area: string = '1号楼'
  @State inspectType: string = '主体结构'
  @State inspectDate: string = QualityDates.today()
  @State remark: string = ''
  @State errorText: string = ''
  @State projectTitles: string[] = []
  @State areaOptions: string[] = []
  @State typeOptions: string[] = []
  onCancel: () => void = () => {}
  onStarted: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.areaOptions = QualityCatalog.areas()
    this.typeOptions = QualityCatalog.types()
    const titles: string[] = []
    const list = QualityService.projects()
    for (const p of list) {
      titles.push(p.title)
    }
    this.projectTitles = titles
    if (list.length > 0 && this.projectId.length === 0) {
      this.projectId = list[0].id
      this.projectName = list[0].title
    }
    this.inspectDate = QualityDates.today()
  }

  private applyProject(title: string): void {
    this.projectName = title
    const list = QualityService.projects()
    for (const p of list) {
      if (p.title === title) {
        this.projectId = p.id
      }
    }
  }

  private async start(): Promise<void> {
    if (this.projectName.length === 0) {
      this.errorText = '请先新增项目'
      return
    }
    const draft = new InspectionRecord()
    draft.projectId = this.projectId
    draft.projectName = this.projectName
    draft.area = this.area
    draft.inspectType = this.inspectType
    draft.inspectDate = this.inspectDate
    draft.remark = this.remark
    const row = await QualityService.createInspection(draft)
    this.onStarted(row.id)
  }

  build() {
    Column() {
      Row() {
        Text('开始巡查')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .onClick(() => this.onCancel())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      Scroll() {
        Column({ space: 14 }) {
          ChipSelectGroup({
            title: '项目',
            options: this.projectTitles,
            selected: $projectName,
            onPicked: (v: string) => this.applyProject(v)
          })
          ChipSelectGroup({
            title: '巡查区域',
            options: this.areaOptions,
            selected: $area
          })
          ChipSelectGroup({
            title: '巡查类型',
            options: this.typeOptions,
            selected: $inspectType
          })
          AppDatePickerField({
            label: '巡查日期',
            value: $inspectDate,
            minDaysFromToday: -60,
            maxDaysFromToday: 0
          })
          Text('巡查备注')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.remark, placeholder: '选填，记录本次巡查要点' })
            .height(88)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.remark = v })
          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
        }
        .padding({ left: 20, right: 20, bottom: 24 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)

      Column({ space: 8 }) {
        AppButton({ label: '开始巡查', onTap: (): void => { void this.start() } })
        if (this.projectTitles.length === 0) {
          AppButton({
            label: '新增项目',
            variant: 'secondary',
            onTap: () => QualityNav.open('newProject')
          })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 8 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
