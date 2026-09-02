import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppNavBar } from '../design-system/AppNavBar'
import { VitalityNote, VitalityRecord, VitalityTopic } from '../../models/VitalityModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct TopicDetailOverlay {
  @Prop topic: VitalityTopic = new VitalityTopic()
  @Prop recordItems: VitalityRecord[] = []
  @Prop noteItems: VitalityNote[] = []
  onClose: () => void = () => {}
  onAddToday: () => void = () => {}
  onAddNote: () => void = () => {}
  onEditTopic: () => void = () => {}
  onOpenRecord: (dateKey: string) => void = () => {}
  onOpenNote: (noteId: string) => void = () => {}

  build() {
    Column() {
      AppNavBar({ title: '专题详情', onBack: (): void => this.onClose() })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s2 }) {
            Text(`${this.topic.emoji} ${this.topic.title}`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text(`${this.recordItems.length} 条记录 · ${this.noteItems.length} 篇笔记`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({ label: '加入今日记录', variant: 'primary', onTap: (): void => this.onAddToday() })
            }
            .layoutWeight(1)
            Column() {
              AppButton({ label: '添加笔记', variant: 'secondary', onTap: (): void => this.onAddNote() })
            }
            .layoutWeight(1)
          }
          .width('100%')

          Column() {
            AppButton({ label: '编辑专题', variant: 'secondary', onTap: (): void => this.onEditTopic() })
          }
          .width('100%')

          Text('关联打卡日')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          if (this.recordItems.length === 0) {
            Text('还没有打卡记录，完成今日打卡后可加入专题')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.recordItems, (r: VitalityRecord) => {
              Row() {
                Column({ space: 4 }) {
                  Text(DateHelper.displayDate(r.dateKey)).fontSize(Theme.type.bodyS)
                  Text(`活力 ${r.vitalityScore()} · ${DimensionLabel(r)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => this.onOpenRecord(r.dateKey))
            }, (r: VitalityRecord) => r.dateKey)
          }

          Text('关联笔记')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ top: Theme.space.s2 })
          if (this.noteItems.length === 0) {
            Text('点击「添加笔记」把纪行笔记收进本专题')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.noteItems, (n: VitalityNote) => {
              Row() {
                Column({ space: 4 }) {
                  Text(n.title).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textPrimary)
                  Text(n.body).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).maxLines(2)
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => this.onOpenNote(n.id))
            }, (n: VitalityNote) => n.id)
          }

          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(55)
  }
}

function DimensionLabel(r: VitalityRecord): string {
  if (r.moodKey.length > 0) {
    return r.moodKey === 'happy' ? '愉悦' : (r.moodKey === 'calm' ? '平静' : '疲惫')
  }
  return '已打卡'
}
