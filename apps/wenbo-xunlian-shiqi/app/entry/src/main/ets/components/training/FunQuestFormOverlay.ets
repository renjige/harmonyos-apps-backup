import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SolidButton } from '../design-system/SolidButton'
import { FunQuestDraft } from '../../models/TrainingModels'
import { FunQuestService } from '../../services/FunQuestService'
import { TrainingRecordService } from '../../services/TrainingRecordService'

@Component
export struct FunQuestFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop draft: FunQuestDraft = FunQuestService.emptyDraft()
  @Prop formError: string = ''
  @Prop formTitle: string = '新建拾趣挑战'
  onClose: () => void = () => {}
  onSubmit: () => void = () => {}
  onDraftChange: (d: FunQuestDraft) => void = () => {}

  private sportOptions(): string[] {
    const all: string[] = ['全部']
    for (const t of TrainingRecordService.PRESET_TYPES) {
      all.push(t)
    }
    return all
  }

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
            Text('挑战标题')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.title, placeholder: '例如：本周三次晨光跑' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const next = FunQuestService.copy(this.draft)
                next.title = v
                this.onDraftChange(next)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Text('趣味主题')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(FunQuestService.THEMES, (th: string) => {
              Text(th)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.draft.theme === th ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.draft.theme === th ? '#FF6B35' : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  const next = FunQuestService.copy(this.draft)
                  next.theme = th
                  this.onDraftChange(next)
                })
            }, (th: string) => th)
          }
          .width('100%')

          Text('计入的训练类型')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.sportOptions(), (sp: string) => {
              Text(sp)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.draft.sportType === sp ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.draft.sportType === sp ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  const next = FunQuestService.copy(this.draft)
                  next.sportType = sp
                  this.onDraftChange(next)
                })
            }, (sp: string) => sp)
          }
          .width('100%')

          Text('目标类型')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Column({ space: Theme.space.s2 }) {
            this.KindRow('sessions', '完成次数')
            this.KindRow('minutes', '累计分钟')
            this.KindRow('types', '尝试类型数')
            this.KindRow('days', '有记录的天数')
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('目标数值')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.targetValue, placeholder: '例如 3' })
              .type(InputType.Number)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const next = FunQuestService.copy(this.draft)
                next.targetValue = v
                this.onDraftChange(next)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s2 }) {
            Text('趣味备注（可选）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.note, placeholder: '这周想怎么玩得更有趣？' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const next = FunQuestService.copy(this.draft)
                next.note = v
                this.onDraftChange(next)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          if (this.formError.length > 0) {
            Text(this.formError)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      Column() {
        SolidButton({
          label: '保存挑战',
          tone: 'primary',
          onTap: (): void => { this.onSubmit() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s6 })
      .backgroundColor(Theme.colors().surfaceCard)
      .onClick((): void => { this.onSubmit() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  KindRow(kind: string, label: string) {
    Text(label)
      .fontSize(Theme.type.body)
      .fontColor(this.draft.targetKind === kind ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
      .width('100%')
      .padding(Theme.space.s3)
      .backgroundColor(this.draft.targetKind === kind ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.md)
      .onClick((): void => {
        const next = FunQuestService.copy(this.draft)
        next.targetKind = kind
        this.onDraftChange(next)
      })
  }
}
