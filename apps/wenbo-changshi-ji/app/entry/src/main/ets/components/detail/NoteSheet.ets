import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { FactItem } from '../../models/CommonSenseModels'
import { CommonSenseBizService } from '../../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../../services/CommonSenseDetailNav'
import { CommonSenseStore } from '../../services/CommonSenseStore'

@Component
export struct NoteSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop factId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State title: string = ''
  @State noteText: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onRefreshTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await CommonSenseBizService.findFact(this.factId)
    if (found !== undefined) {
      this.title = found.title
    }
    this.noteText = CommonSenseStore.noteFor(this.factId)
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    await CommonSenseStore.saveNote(this.factId, this.noteText)
    this.showToast('笔记已保存')
    setTimeout((): void => { CommonSenseDetailNav.close() }, 800)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Column({ space: 2 }) {
            Text('我的笔记')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.title)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Column({ space: Theme.space.s4 }) {
          TextArea({ text: this.noteText, placeholder: '写下你的理解、联想或待验证的问题…' })
            .width('100%')
            .height(280)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onChange((v: string): void => { this.noteText = v })
          AppButton({
            label: '保存笔记',
            onTap: (): void => { void this.save() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
