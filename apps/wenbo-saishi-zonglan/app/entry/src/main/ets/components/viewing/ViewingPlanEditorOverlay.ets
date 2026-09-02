import { Theme, ThemeColors } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CreateViewingPlanBody } from '../../models/ViewingModels'
import { SportsBizService } from '../../services/SportsBizService'

@Component
export struct ViewingPlanEditorOverlay {
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @Prop seedMatchId: string = ''
  @Prop seedMatchTitle: string = ''
  @Prop seedMatchSport: string = ''
  @Prop seedMatchLeague: string = ''
  @Prop seedMatchDate: string = ''
  @State title: string = ''
  @State note: string = ''
  @State saving: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    if (this.seedMatchId.length > 0 && this.seedMatchTitle.length > 0) {
      this.title = `观赛计划 · ${this.seedMatchTitle}`
    } else {
      this.title = '我的观赛计划'
    }
  }

  private palette(): ThemeColors {
    return Theme.palette(this.themeColorMode === 'dark')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async handleSave(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.title.trim().length === 0) {
      this.showToast('请输入计划标题')
      return
    }
    this.saving = true
    const body = new CreateViewingPlanBody()
    body.title = this.title.trim()
    body.note = this.note.trim()
    if (this.seedMatchId.length > 0) {
      body.matchIds = [this.seedMatchId]
      body.targetCount = 1
      body.sport = this.seedMatchSport
      body.leagueName = this.seedMatchLeague
      body.startDate = this.seedMatchDate
      body.endDate = this.seedMatchDate
    } else {
      body.targetCount = 3
    }
    const row = await SportsBizService.createViewingPlan(body)
    this.saving = false
    if (row === undefined) {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '创建失败')
      return
    }
    this.showToast('观赛计划已创建')
    this.onSaved()
    this.onClose()
  }

  build() {
    Stack() {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: this.palette().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('新建观赛计划')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.palette().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })

        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.title, placeholder: '计划标题' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.palette().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            .border({ width: 1, color: this.palette().strokeStrong })
            .fontColor(this.palette().textPrimary)
            .placeholderColor(this.palette().textTertiary)
            .onChange((v: string): void => { this.title = v })
          TextArea({ text: this.note, placeholder: '计划说明（选填）' })
            .height(96)
            .padding(12)
            .backgroundColor(this.palette().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            .border({ width: 1, color: this.palette().strokeStrong })
            .fontColor(this.palette().textPrimary)
            .placeholderColor(this.palette().textTertiary)
            .onChange((v: string): void => { this.note = v })
          if (this.seedMatchId.length > 0) {
            Text(`已加入：${this.seedMatchTitle}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.palette().textSecondary)
              .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')

        AppButton({
          label: this.saving ? '保存中…' : '创建计划',
          onTap: (): void => { void this.handleSave() }
        })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.palette().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(this.palette().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(this.palette().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
