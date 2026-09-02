import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SolidButton } from '../design-system/SolidButton'
import { MoveDraft } from '../../models/TrainingModels'
import { PracticeService } from '../../services/PracticeService'

@Component
export struct MoveFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop draft: MoveDraft = new MoveDraft()
  @Prop formTitle: string = '收藏动作'
  onClose: () => void = () => {}
  onSubmit: () => void = () => {}
  onDraftChange: (d: MoveDraft) => void = () => {}

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text(this.formTitle)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column({ space: Theme.space.s2 }) {
            Text('动作名称')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.title, placeholder: '例如 俯身转体' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = PracticeService.copyMoveDraft(this.draft)
                n.title = v
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Text('分类')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(PracticeService.MOVE_CATS, (cat: string) => {
              Text(cat)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.draft.category === cat ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.draft.category === cat ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  const n = PracticeService.copyMoveDraft(this.draft)
                  n.category = cat
                  this.onDraftChange(n)
                })
            }, (cat: string) => cat)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('要点（可选）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.tips, placeholder: '节奏、呼吸或注意事项' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = PracticeService.copyMoveDraft(this.draft)
                n.tips = v
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s2 }) {
            Text('训练目的（可选）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.purpose, placeholder: '例如：唤醒肩带' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = PracticeService.copyMoveDraft(this.draft)
                n.purpose = v
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s2 }) {
            Text('推荐组合（可选）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.combo, placeholder: '例如：可接肩部开合' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = PracticeService.copyMoveDraft(this.draft)
                n.combo = v
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      Column() {
        SolidButton({
          label: '保存到动作库',
          tone: 'primary',
          onTap: (): void => { this.onSubmit() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .onClick((): void => { this.onSubmit() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
