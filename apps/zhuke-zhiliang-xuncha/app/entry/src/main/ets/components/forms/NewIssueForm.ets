import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { ChipSelectGroup } from '../quality/ChoiceChip'
import { QualityCatalog, IssueRecord } from '../../models/QualityModels'
import { QualityService } from '../../services/QualityService'
import { PhotoPickService } from '../../services/PhotoPickService'
import { QualityLocalStore } from '../../services/QualityLocalStore'
import { CoverImage } from '../quality/CoverImage'

@Component
export struct NewIssueForm {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop inspectId: string = ''
  @Prop presetTitle: string = ''
  @Prop issueId: string = ''
  @State title: string = ''
  @State projectId: string = ''
  @State projectName: string = ''
  @State location: string = ''
  @State category: string = '其他'
  @State severity: string = '一般'
  @State description: string = ''
  @State requirement: string = ''
  @State photos: string[] = []
  @State errorText: string = ''
  @State projectTitles: string[] = []
  @State categoryOptions: string[] = []
  @State severityOptions: string[] = []
  onCancel: () => void = () => {}
  onSaved: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.categoryOptions = QualityCatalog.categories()
    this.severityOptions = QualityCatalog.severities()
    const titles: string[] = []
    for (const p of QualityService.projects()) {
      titles.push(p.title)
    }
    this.projectTitles = titles
    this.hydrate()
  }

  private hydrate(): void {
    if (this.issueId.length > 0) {
      const found = QualityService.findIssue(this.issueId)
      if (found !== undefined) {
        this.title = found.title
        this.projectId = found.projectId
        this.projectName = found.projectName
        this.location = found.location
        this.category = found.category
        this.severity = found.severity
        this.description = found.description
        this.requirement = found.requirement
        this.photos = QualityLocalStore.parsePhotos(found.photosJson)
        return
      }
    }
    this.title = this.presetTitle
    const ins = QualityService.findInspection(this.inspectId)
    if (ins !== undefined) {
      this.projectId = ins.projectId
      this.projectName = ins.projectName
      this.location = ins.area
    } else if (this.projectTitles.length > 0 && this.projectName.length === 0) {
      this.projectName = this.projectTitles[0]
      this.applyProject(this.projectName)
    }
  }

  private applyProject(title: string): void {
    this.projectName = title
    for (const p of QualityService.projects()) {
      if (p.title === title) {
        this.projectId = p.id
      }
    }
  }

  private async pickPhoto(): Promise<void> {
    const host = this.getUIContext().getHostContext() as common.UIAbilityContext
    const uri = await PhotoPickService.pickOne(host)
    if (uri.length === 0) {
      this.errorText = '未选择照片，可稍后补充'
      return
    }
    const next: string[] = []
    for (const p of this.photos) {
      next.push(p)
    }
    next.push(uri)
    this.photos = next
    this.errorText = ''
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写问题名称'
      return
    }
    const draft = new IssueRecord()
    draft.title = this.title
    draft.projectId = this.projectId
    draft.projectName = this.projectName
    draft.location = this.location
    draft.category = this.category
    draft.severity = this.severity
    draft.description = this.description
    draft.requirement = this.requirement
    draft.photosJson = JSON.stringify(this.photos)
    draft.inspectionId = this.inspectId
    draft.coverKey = this.photos.length > 0 ? this.photos[0] : QualityCatalog.coverForCategory(this.category)
    if (this.issueId.length > 0) {
      draft.id = this.issueId
      const row = await QualityService.updateIssue(draft)
      this.onSaved(row.id)
      return
    }
    const row = await QualityService.createIssue(draft)
    this.onSaved(row.id)
  }

  build() {
    Column() {
      Row() {
        Text(this.issueId.length > 0 ? '编辑问题' : '新增问题')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .onClick(() => this.onCancel())
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })
      .width('100%')

      Scroll() {
        Column({ space: 12 }) {
          Text('问题名称')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.title, placeholder: '例如：墙面空鼓' })
            .height(46)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.title = v })
          ChipSelectGroup({
            title: '所属项目',
            options: this.projectTitles,
            selected: $projectName,
            onPicked: (v: string) => this.applyProject(v)
          })
          Text('问题位置')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.location, placeholder: '楼栋 / 房间 / 部位' })
            .height(46)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.location = v })
          ChipSelectGroup({
            title: '问题类别',
            options: this.categoryOptions,
            selected: $category
          })
          ChipSelectGroup({
            title: '严重程度',
            options: this.severityOptions,
            selected: $severity
          })
          Text('问题描述')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.description, placeholder: '描述现场情况' })
            .height(88)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.description = v })
          Text('整改要求')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.requirement, placeholder: '说明整改标准或时限' })
            .height(72)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.requirement = v })
          Text('现场照片')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 8 }) {
            ForEach(this.photos, (p: string) => {
              CoverImage({ coverKey: p, imgWidth: 64, imgHeight: 64, radius: 10 })
            }, (p: string) => p)
            Column() {
              AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
              Text('选择照片')
                .fontSize(10)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(10)
            .onClick((): void => { void this.pickPhoto() })
          }
          .width('100%')
          if (this.errorText.length > 0) {
            Text(this.errorText).fontSize(Theme.type.footnote).fontColor(Theme.colors().danger)
          }
        }
        .padding({ left: 20, right: 20, bottom: 24 })
      }
      .layoutWeight(1)

      Column() {
        AppButton({ label: '保存问题', onTap: (): void => { void this.save() } })
      }
      .padding({ left: 20, right: 20, bottom: 20, top: 8 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
