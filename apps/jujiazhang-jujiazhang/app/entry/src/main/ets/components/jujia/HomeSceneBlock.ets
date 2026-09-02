import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { LifeSceneDef } from '../../models/LifeSceneModels'

@Component
export struct HomeSceneBlock {
  @Prop scenes: LifeSceneDef[] = []
  onApply: (code: string) => void = (_c: string) => {}

  @Builder
  SceneCard(scene: LifeSceneDef) {
    Column({ space: 6 }) {
      Row({ space: 6 }) {
        AppIcon({ name: 'check', iconSize: 16, color: Theme.colors().brandPrimary })
        Text(scene.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      Text(scene.subtitle)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text('一键生成')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandOnPrimary)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.sm)
    }
    .width(148)
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onApply(scene.code))
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Column({ space: 2 }) {
          Text('生活场景包')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text('一键生成清单 + 计划 + 备忘，覆盖真实家庭场景')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.scenes, (scene: LifeSceneDef) => {
            this.SceneCard(scene)
          }, (scene: LifeSceneDef) => scene.code)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
