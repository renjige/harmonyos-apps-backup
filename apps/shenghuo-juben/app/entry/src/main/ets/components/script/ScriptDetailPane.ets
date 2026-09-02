import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppCard } from '../design-system/AppCard'
import { ConfirmSheet } from './ConfirmSheet'
import { LifeScript } from '../../models/ScriptModels'
import { DateHelper } from '../../services/DateHelper'
import { ScriptStore } from '../../services/ScriptStore'

@Component
export struct ScriptDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop script: LifeScript = new LifeScript()
  @State showDeleteConfirm: boolean = false
  onClose: () => void = () => {}
  onDeleted: () => void = () => {}
  onEdit: (script: LifeScript) => void = () => {}

  private confirmDelete(): void {
    void ScriptStore.deleteScript(this.script.id).then((): void => {
      this.showDeleteConfirm = false
      this.onDeleted()
    })
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('剧本详情')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              if (this.script.coverPath().length > 0) {
                Image(this.script.coverPath())
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
              } else {
                Image($r('app.media.hero_script_bg'))
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
              }
              Column() {
                Blank()
                Column({ space: 4 }) {
                  Text(this.script.title.length > 0 ? this.script.title : '未命名剧本')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text(`${DateHelper.displayDate(this.script.dateKey)} · ${this.script.moodTag}`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(44,62,80,0.82)', 1]]
                })
              }
              .width('100%')
              .height('100%')
              .borderRadius(Theme.radius.md)
            }
            .width('100%')

            if (this.script.prologue.length > 0) {
              AppCard({ title: '开场白', variant: 'plain' }) {
                Text(this.script.prologue)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(24)
              }
            }

            if (this.script.sceneDescription.length > 0) {
              AppCard({ title: '场景描述', variant: 'plain' }) {
                Text(this.script.sceneDescription)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(24)
              }
            }

            if (this.script.imagePaths.length > 0) {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.script.imagePaths, (path: string) => {
                    Image(path)
                      .width(120)
                      .height(120)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(Theme.radius.sm)
                  }, (path: string) => path)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }

            AppButton({
              label: '编辑剧本',
              variant: 'primary',
              onTap: (): void => { this.onEdit(this.script) }
            })

            AppButton({
              label: '删除此剧本',
              variant: 'secondary',
              onTap: (): void => { this.showDeleteConfirm = true }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('92%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      .align(Alignment.Bottom)

      if (this.showDeleteConfirm) {
        ConfirmSheet({
          title: '确认删除',
          message: '删除后无法恢复，确定要删除这部生活剧本吗？',
          confirmLabel: '删除',
          onCancel: (): void => { this.showDeleteConfirm = false },
          onConfirm: (): void => { this.confirmDelete() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(30)
  }
}
