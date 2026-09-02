import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SolidButton } from '../design-system/SolidButton'
import { GoalDraft } from '../../models/TrainingModels'

@Component
export struct GoalFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop draft: GoalDraft = new GoalDraft()
  onClose: () => void = () => {}
  onSubmit: () => void = () => {}
  onDraftChange: (d: GoalDraft) => void = () => {}

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
        Text('阶段目标')
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
            Text('目标名称')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.title, placeholder: '例如 30 天完成 20 次训练' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = this.copyDraft()
                n.title = v
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s2 }) {
            Text('目标数量')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.targetCount, placeholder: '20' })
              .type(InputType.Number)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = this.copyDraft()
                n.targetCount = v
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s2 }) {
            Text('单位')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.unit, placeholder: '次' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = this.copyDraft()
                n.unit = v
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Text('进度怎么算')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          this.SyncChip('sessions', '跟随训练次数')
          this.SyncChip('minutes', '跟随训练分钟')
          this.SyncChip('manual', '手动点 +1')
          Text('选「跟随训练次数」后，每保存一条训练，进度立刻 +1。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      Column() {
        SolidButton({
          label: '保存目标',
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

  private copyDraft(): GoalDraft {
    const n = new GoalDraft()
    n.title = this.draft.title
    n.targetCount = this.draft.targetCount
    n.unit = this.draft.unit
    n.syncKind = this.draft.syncKind
    return n
  }

  @Builder
  SyncChip(kind: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.draft.syncKind === kind ? '#FFFFFF' : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.draft.syncKind === kind ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .width('100%')
      .margin({ bottom: 8 })
      .onClick((): void => {
        const n = this.copyDraft()
        n.syncKind = kind
        this.onDraftChange(n)
      })
  }
}
