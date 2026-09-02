import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextInputField } from '../design-system/AppTextInputField'
import { DetailShell } from '../detail/DetailShell'
import { ActionCategory, ArchiveDraft } from '../../models/TrainingModels'

@Component
export struct ArchiveEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = 'plan'
  onClose: () => void = () => {}
  onSave: (draft: ArchiveDraft) => void = () => {}
  @State titleText: string = ''
  @State extraText: string = ''
  @State extraNum: string = '30'
  @State category: string = 'warm'
  @State kind: string = 'count'

  private heading(): string {
    if (this.mode === 'plan') {
      return '新建训练计划'
    }
    if (this.mode === 'action') {
      return '新增训练动作'
    }
    if (this.mode === 'list') {
      return '新建训练清单'
    }
    if (this.mode === 'fav') {
      return '收藏训练心得'
    }
    return '新建目标挑战'
  }

  private handleSave(): void {
    const d = new ArchiveDraft()
    d.mode = this.mode
    d.title = this.titleText.trim()
    d.extra = this.extraText.trim()
    d.extraNum = this.extraNum
    d.category = this.category
    d.kind = this.kind
    if (d.title.length === 0) {
      return
    }
    this.onSave(d)
  }

  build() {
    Column() {
      DetailShell({
        title: this.heading(),
        onClose: (): void => this.onClose()
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s2 }) {
            Text('标题')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
            AppTextInputField({
              text: this.titleText,
              placeholder: this.placeholderTitle(),
              onChange: (v: string): void => { this.titleText = v }
            })
          }
          .width('100%')

          if (this.mode === 'plan') {
            Column({ space: Theme.space.s2 }) {
              Text('周期目标')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.extraText,
                placeholder: '例如：每周训练 3 次',
                onChange: (v: string): void => { this.extraText = v }
              })
              Text('周期天数')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.extraNum,
                placeholder: '30',
                numeric: true,
                onChange: (v: string): void => { this.extraNum = v }
              })
            }
            .width('100%')
          }

          if (this.mode === 'action') {
            Column({ space: Theme.space.s2 }) {
              Text('分类')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(ActionCategory.all(), (c: ActionCategory) => {
                  Text(c.label)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.category === c.key ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.category === c.key ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.category = c.key })
                }, (c: ActionCategory) => c.key)
              }
              Text('动作说明')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.extraText,
                placeholder: '要点、组数、注意事项',
                onChange: (v: string): void => { this.extraText = v }
              })
            }
            .width('100%')
          }

          if (this.mode === 'list') {
            Column({ space: Theme.space.s2 }) {
              Text('清单条目（用 | 分隔）')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.extraText,
                placeholder: '水壶|毛巾|训练鞋',
                onChange: (v: string): void => { this.extraText = v }
              })
            }
            .width('100%')
          }

          if (this.mode === 'fav') {
            Column({ space: Theme.space.s2 }) {
              Text('心得正文')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.extraText,
                placeholder: '值得保留的训练方法或感受',
                onChange: (v: string): void => { this.extraText = v }
              })
            }
            .width('100%')
          }

          if (this.mode === 'challenge') {
            Column({ space: Theme.space.s2 }) {
              Text('目标次数 / 天数')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.extraNum,
                placeholder: '21',
                numeric: true,
                onChange: (v: string): void => { this.extraNum = v }
              })
            }
            .width('100%')
          }

          AppButton({
            label: '保存',
            variant: 'primary',
            onTap: (): void => { this.handleSave() }
          })
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private placeholderTitle(): string {
    if (this.mode === 'plan') {
      return '例如：30 天体能提升计划'
    }
    if (this.mode === 'action') {
      return '例如：徒手深蹲'
    }
    if (this.mode === 'list') {
      return '例如：健身装备准备'
    }
    if (this.mode === 'fav') {
      return '例如：核心训练完成后的感受'
    }
    return '例如：连续训练 21 天'
  }
}
