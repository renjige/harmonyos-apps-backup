import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { QualityService } from '../../services/QualityService'

@Component
export struct ProjectForm {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State location: string = ''
  @State summary: string = ''
  @State errorText: string = ''
  onCancel: () => void = () => {}
  onSaved: (id: string) => void = (_id: string) => {}

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写项目名称'
      return
    }
    const row = await QualityService.createProject(this.title.trim(), this.location.trim(), this.summary.trim())
    this.onSaved(row.id)
  }

  build() {
    Column() {
      Row() {
        Text('新增项目')
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
        Column({ space: 12 }) {
          Text('项目名称')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.title, placeholder: '例如：滨江住宅一期' })
            .height(46)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.title = v })
          Text('位置')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.location, placeholder: '片区或工点' })
            .height(46)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.location = v })
          Text('说明')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.summary, placeholder: '当前施工阶段与巡查重点' })
            .height(88)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.summary = v })
          if (this.errorText.length > 0) {
            Text(this.errorText).fontSize(Theme.type.footnote).fontColor(Theme.colors().danger)
          }
        }
        .padding({ left: 20, right: 20, bottom: 24 })
      }
      .layoutWeight(1)

      Column() {
        AppButton({ label: '保存项目', onTap: (): void => { void this.save() } })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
