import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { DimensionPicker } from './DimensionPicker'
import { RecipeList } from './RecipeList'
import { VitalityScoreBadge } from './VitalityScoreBadge'
import { DimensionSummaryChips } from './DimensionSummaryChips'
import { DimensionOption, MicroAction, VitalityRecord } from '../../models/VitalityModels'

@Component
export struct CheckInSheet {
  @Prop visible: boolean = false
  @Prop hasCheckedIn: boolean = false
  @Prop editing: boolean = false
  @Prop todayRecord: VitalityRecord = new VitalityRecord()
  @Prop exerciseKey: string = ''
  @Prop moodKey: string = ''
  @Prop energyKey: string = ''
  @Prop noteText: string = ''
  @Prop pinned: boolean = false
  @Prop actions: MicroAction[] = []
  @Prop actionRevision: number = 0
  onClose: () => void = () => {}
  onSelectExercise: (key: string) => void = () => {}
  onSelectMood: (key: string) => void = () => {}
  onSelectEnergy: (key: string) => void = () => {}
  onNoteChange: (text: string) => void = () => {}
  onSubmit: () => void = () => {}
  onEdit: () => void = () => {}
  onPin: () => void = () => {}
  onToggleAction: (id: string) => void = () => {}

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)
          .onClick((): void => this.onClose())

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row() {
              Text(this.hasCheckedIn && !this.editing ? '今日活力' : '记录今日活力')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Column() {
                AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => this.onClose())
            }
            .width('100%')

            if (this.hasCheckedIn && !this.editing) {
              this.DoneBody()
            } else {
              this.FormBody()
            }
          }
          .width('100%')
          .padding(Theme.space.s6)
        }
        .width('100%')
        .height('88%')
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      }
      .width('100%')
      .height('100%')
      .zIndex(50)
    }
  }

  @Builder
  DoneBody() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s4 }) {
        VitalityScoreBadge({ score: this.todayRecord.vitalityScore() })
        Column({ space: Theme.space.s2 }) {
          Text('今日已完成')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().success)
          Text('状态已同步到纪行与成长')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      DimensionSummaryChips({
        exerciseLabel: DimensionOption.labelFor('exercise', this.todayRecord.exerciseKey),
        moodLabel: DimensionOption.labelFor('mood', this.todayRecord.moodKey),
        energyLabel: DimensionOption.labelFor('energy', this.todayRecord.energyKey)
      })

      RecipeList({
        actions: this.actions,
        actionRevision: this.actionRevision,
        onToggle: (id: string): void => this.onToggleAction(id)
      })

      Row({ space: Theme.space.s2 }) {
        Column() {
          AppButton({ label: '修改', variant: 'secondary', onTap: (): void => this.onEdit() })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: this.pinned ? '已收藏' : '收藏高光',
            variant: 'secondary',
            onTap: (): void => this.onPin()
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  FormBody() {
    Column({ space: Theme.space.s5 }) {
      DimensionPicker({
        title: '今日运动量',
        options: DimensionOption.exerciseOptions(),
        selectedKey: this.exerciseKey,
        onSelect: (key: string): void => this.onSelectExercise(key)
      })
      DimensionPicker({
        title: '今日心情',
        options: DimensionOption.moodOptions(),
        selectedKey: this.moodKey,
        onSelect: (key: string): void => this.onSelectMood(key)
      })
      DimensionPicker({
        title: '今日精力',
        options: DimensionOption.energyOptions(),
        selectedKey: this.energyKey,
        onSelect: (key: string): void => this.onSelectEnergy(key)
      })
      Column({ space: Theme.space.s2 }) {
        Text('备注（选填）')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        TextArea({ text: this.noteText, placeholder: '一句话记录今日亮点…' })
          .height(88)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .onChange((v: string): void => this.onNoteChange(v))
      }
      .width('100%')
      Column() {
        AppButton({
          label: this.hasCheckedIn ? '保存修改' : '记录今日活力',
          variant: 'primary',
          onTap: (): void => this.onSubmit()
        })
      }
      .width('100%')
    }
    .width('100%')
  }
}
