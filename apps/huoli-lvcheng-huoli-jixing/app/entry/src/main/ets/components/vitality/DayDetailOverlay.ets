import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { DimensionPicker } from './DimensionPicker'
import { RecipeList } from './RecipeList'
import { DimensionOption, MicroAction, VitalityRecord } from '../../models/VitalityModels'

@Component
export struct DayDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop dateLabel: string = ''
  @Prop record: VitalityRecord = new VitalityRecord()
  @Prop actions: MicroAction[] = []
  @Prop pinned: boolean = false
  onClose: () => void = () => {}
  onToggleAction: (id: string) => void = () => {}
  onTogglePin: () => void = () => {}
  onSave: (ex: string, mood: string, energy: string, note: string) => void = () => {}
  onDelete: () => void = () => {}

  @State editing: boolean = false
  @State confirmDelete: boolean = false
  @State exerciseKey: string = ''
  @State moodKey: string = ''
  @State energyKey: string = ''
  @State noteText: string = ''

  aboutToAppear(): void {
    this.syncForm()
  }

  private syncForm(): void {
    this.exerciseKey = this.record.exerciseKey
    this.moodKey = this.record.moodKey
    this.energyKey = this.record.energyKey
    this.noteText = this.record.note
  }

  build() {
    Column() {
      AppNavBar({ title: this.dateLabel, onBack: (): void => this.onClose() })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_ambient'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(140)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,42,58,0.08)', 0], ['rgba(26,42,58,0.72)', 1]]
              })
              .borderRadius(Theme.radius.lg)
            Text(`活力值 ${this.record.vitalityScore()} 分`)
              .fontSize(Theme.type.title3)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s3 })
          }
          .width('100%')

          if (this.editing) {
            DimensionPicker({
              title: '运动量',
              options: DimensionOption.exerciseOptions(),
              selectedKey: this.exerciseKey,
              onSelect: (k: string): void => { this.exerciseKey = k }
            })
            DimensionPicker({
              title: '心情',
              options: DimensionOption.moodOptions(),
              selectedKey: this.moodKey,
              onSelect: (k: string): void => { this.moodKey = k }
            })
            DimensionPicker({
              title: '精力',
              options: DimensionOption.energyOptions(),
              selectedKey: this.energyKey,
              onSelect: (k: string): void => { this.energyKey = k }
            })
            TextArea({ text: this.noteText, placeholder: '备注（选填）' })
              .height(72)
              .onChange((v: string): void => { this.noteText = v })
            AppButton({
              label: '保存修改',
              variant: 'primary',
              onTap: (): void => {
                this.editing = false
                this.onSave(this.exerciseKey, this.moodKey, this.energyKey, this.noteText)
              }
            })
          } else {
            Text(`运动 · ${DimensionOption.labelFor('exercise', this.record.exerciseKey)}`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`心情 · ${DimensionOption.labelFor('mood', this.record.moodKey)}`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`精力 · ${DimensionOption.labelFor('energy', this.record.energyKey)}`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.record.note.length > 0) {
              Text(this.record.note)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
            }
            RecipeList({
              actions: this.actions,
              onToggle: (id: string): void => this.onToggleAction(id)
            })
          }

          Row({ space: Theme.space.s2 }) {
            AppButton({
              label: this.editing ? '取消编辑' : '编辑记录',
              variant: 'secondary',
              onTap: (): void => {
                if (this.editing) {
                  this.editing = false
                  this.syncForm()
                } else {
                  this.editing = true
                }
              }
            }).layoutWeight(1)
            AppButton({
              label: this.pinned ? '取消高光' : '收藏高光日',
              variant: 'secondary',
              onTap: (): void => this.onTogglePin()
            }).layoutWeight(1)
          }
          .width('100%')

          if (this.confirmDelete) {
            Column({ space: Theme.space.s3 }) {
              Text('删除这一天的记录？不可恢复。')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().danger)
              Row({ space: Theme.space.s2 }) {
                AppButton({
                  label: '再想想',
                  variant: 'secondary',
                  onTap: (): void => { this.confirmDelete = false }
                }).layoutWeight(1)
                AppButton({
                  label: '确认删除',
                  variant: 'danger',
                  onTap: (): void => this.onDelete()
                }).layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
          } else {
            AppButton({
              label: '删除这一天',
              variant: 'ghost',
              onTap: (): void => { this.confirmDelete = true }
            })
          }

          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
