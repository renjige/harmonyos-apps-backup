import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppointmentItem, AppointmentTemplate } from '../../models/AppointmentModels'
import { AppointmentMedia } from '../../services/AppointmentMedia'
import { AppointmentRow, SectionTitle } from './AppointmentCards'

class SceneTab {
  key: string = ''
  label: string = ''

  static all(): SceneTab[] {
    const a = new SceneTab(); a.key = 'work'; a.label = '工作'
    const b = new SceneTab(); b.key = 'life'; b.label = '生活'
    const c = new SceneTab(); c.key = 'study'; c.label = '学习'
    const d = new SceneTab(); d.key = 'health'; d.label = '健康'
    return [a, b, c, d]
  }
}

@Component
export struct SceneHubOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop scene: string = 'work'
  @Prop items: AppointmentItem[] = []
  @Prop templates: AppointmentTemplate[] = []
  onClose: () => void = () => {}
  onSceneChange: (key: string) => void = () => {}
  onOpenItem: (id: string) => void = () => {}
  onOpenTemplate: (tpl: AppointmentTemplate) => void = () => {}
  onCreateScene: (scene: string) => void = () => {}

  private sceneItems(): AppointmentItem[] {
    const out: AppointmentItem[] = []
    for (const row of this.items) {
      if (row.scene === this.scene && !row.isDone()) {
        out.push(row)
      }
    }
    return out
  }

  private sceneTemplates(): AppointmentTemplate[] {
    const out: AppointmentTemplate[] = []
    for (const tpl of this.templates) {
      if (tpl.scene === this.scene) {
        out.push(tpl)
      }
    }
    return out
  }

  private sceneHint(): string {
    if (this.scene === 'work') {
      return '会议、汇报、客户对接——可设冲突检测、会前准备与相关人。'
    }
    if (this.scene === 'study') {
      return '课程、阅读、复习——适合重复约定与空档安排。'
    }
    if (this.scene === 'health') {
      return '运动、体检、康复——建议预留路上时间与提前提醒。'
    }
    return '生日、接送、聚餐、账单——生活类约定可置顶并设跟进。'
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('场景中心')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.sceneHint())
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Row({ space: 8 }) {
            ForEach(SceneTab.all(), (t: SceneTab) => {
              Text(t.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.scene === t.key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.scene === t.key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.onSceneChange(t.key) })
            }, (t: SceneTab) => t.key)
          }
          .width('100%')

          SectionTitle({ title: `待办 ${this.sceneItems().length} 条` })
          if (this.sceneItems().length === 0) {
            Text('该场景暂无待办，可从下方模板或新建开始')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            Column({ space: 4 }) {
              ForEach(this.sceneItems(), (row: AppointmentItem) => {
                AppointmentRow({
                  title: row.title,
                  timeLabel: row.dateTimeLabel(),
                  meta: row.contactName.length > 0 ? `与 ${row.contactName}` : row.sceneLabel(),
                  done: row.isDone(),
                  onTap: (): void => { this.onOpenItem(row.id) }
                })
              }, (row: AppointmentItem) => row.id)
            }
            .width('100%')
          }

          SectionTitle({ title: '推荐模板' })
          if (this.sceneTemplates().length === 0) {
            Text('暂无该场景模板')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            Grid() {
              ForEach(this.sceneTemplates(), (tpl: AppointmentTemplate) => {
                GridItem() {
                  Column({ space: 6 }) {
                    Image(AppointmentMedia.cover(tpl.coverKey))
                      .width('100%')
                      .height(64)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(Theme.radius.md)
                    Text(tpl.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textPrimary)
                      .maxLines(1)
                      .width('100%')
                  }
                  .padding(10)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => { this.onOpenTemplate(tpl) })
                }
              }, (tpl: AppointmentTemplate) => tpl.id)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)
            .width('100%')
          }

          AppButton({
            label: `新建${this.scene === 'work' ? '工作' : this.scene === 'study' ? '学习' :
              this.scene === 'health' ? '健康' : '生活'}约定`,
            onTap: (): void => { this.onCreateScene(this.scene) }
          })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
