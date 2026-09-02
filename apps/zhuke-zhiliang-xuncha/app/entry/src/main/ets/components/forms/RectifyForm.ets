import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CoverImage } from '../quality/CoverImage'
import { ChoiceChip } from '../quality/ChoiceChip'
import { IssueRecord } from '../../models/QualityModels'
import { QualityService } from '../../services/QualityService'
import { PhotoPickService } from '../../services/PhotoPickService'

@Component
export struct RectifyForm {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIssueId') issueId: string = ''
  @State issue: IssueRecord = new IssueRecord()
  @State note: string = ''
  @State photos: string[] = []
  @State done: boolean = true
  @State missing: boolean = false
  @State errorText: string = ''
  onCancel: () => void = () => {}
  onSubmitted: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onIssueId(): void {
    this.reload()
  }

  private reload(): void {
    const found = QualityService.findIssue(this.issueId)
    if (found === undefined) {
      this.missing = true
      return
    }
    this.missing = false
    this.issue = found
    this.done = true
    this.note = ''
    this.photos = []
    this.errorText = ''
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

  private async submit(): Promise<void> {
    if (this.note.trim().length === 0) {
      this.errorText = '请填写整改说明'
      return
    }
    await QualityService.submitRectify(this.issue, this.note.trim(), JSON.stringify(this.photos), this.done)
    this.onSubmitted()
  }

  build() {
    Column() {
      Row() {
        Text('整改处理')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .onClick(() => this.onCancel())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      if (this.missing) {
        Text('问题不存在或已删除')
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(20)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Text(this.issue.title)
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('整改说明')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.note, placeholder: '说明已采取的措施与结果' })
              .height(100)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(12)
              .onChange((v: string) => { this.note = v })
            Text('整改照片')
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
            Text('整改状态')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ChoiceChip({
                label: '整改中',
                active: !this.done,
                onPick: () => { this.done = false }
              })
              ChoiceChip({
                label: '完成整改',
                active: this.done,
                onPick: () => { this.done = true }
              })
            }
            .width('100%')
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
      }

      Column() {
        AppButton({ label: '提交整改结果', onTap: (): void => { void this.submit() } })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
