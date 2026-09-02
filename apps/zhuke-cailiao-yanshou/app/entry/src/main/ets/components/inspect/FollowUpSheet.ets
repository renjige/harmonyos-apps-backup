import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { InspectService } from '../../services/InspectService'
import { InspectNav } from '../../services/InspectNav'

@Component
export struct FollowUpSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recordId: string = ''
  @State note: string = ''
  @State closed: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    const row = InspectService.find(this.recordId)
    if (row !== null) {
      this.note = row.followUpNote
      this.closed = row.followUpDone === '1'
    }
  }

  private async save(): Promise<void> {
    const row = InspectService.find(this.recordId)
    if (row === null) {
      return
    }
    row.followUpNote = this.note.trim()
    row.followUpDone = this.closed ? '1' : '0'
    await InspectService.save(row)
    this.toastText = '跟进已保存'
    setTimeout(() => {
      this.toastText = ''
      InspectNav.closeExtra()
      InspectNav.openDetail(this.recordId)
    }, 400)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
              .rotate({ angle: 180 })
            Text('返回')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .margin({ left: 2 })
          }
          .height(44)
          .onClick(() => InspectNav.closeExtra())
          Text('异常跟进')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(56)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('记录整改措施、复验安排或退场说明，便于现场闭环。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.note, placeholder: '例如：已通知供应商换货，明日复验。' })
              .height(140)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(12)
              .onChange((v: string) => { this.note = v })
            Text(this.closed ? '已关闭跟进' : '跟进中')
              .fontSize(Theme.type.body)
              .fontColor(this.closed ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor(this.closed ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(14)
              .onClick(() => { this.closed = !this.closed })
            AppButton({
              label: '保存跟进',
              onTap: (): void => { void this.save() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
