import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { LifeSceneDef } from '../../models/LifeSceneModels'

@Component
export struct SceneDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop scene: LifeSceneDef = new LifeSceneDef()
  onClose: () => void = () => {}
  onApply: () => void = () => {}

  @Builder
  PreviewBlock(title: string, lines: string[]) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      ForEach(lines, (line: string) => {
        Text(`· ${line}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }, (line: string) => line)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  build() {
    DetailShell({
      title: this.scene.title,
      onClose: (): void => { this.onClose() },
      body: (): void => { this.BodyContent() }
    })
  }

  @Builder
  BodyContent() {
    Scroll() {
      Column({ space: 12 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.home_hero'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text(this.scene.subtitle)
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFF8F5')
              .width('100%')
            Text('一键生成清单 + 备忘 + 家庭计划')
              .fontSize(Theme.type.caption)
              .fontColor('#FFF8F5')
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,58,92,0)', 0], ['rgba(26,58,92,0.88)', 1]]
          })
        }
        .width('100%')
        .borderRadius(Theme.radius.xl)
        .clip(true)

        Text('本场景将同步创建以下家庭内容，可在「生活」「物品」Tab 查看与编辑。')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        this.PreviewBlock('居家清单', [this.scene.checklistTitle, `分类：${this.scene.checklistKind}`])
        this.PreviewBlock('家庭备忘', [this.scene.memoTitle, this.scene.memoBody])
        this.PreviewBlock('关联计划', this.scene.taskTitles)

        Row() {
          AppButton({
            label: '一键应用到家庭',
            variant: 'primary',
            onTap: (): void => { this.onApply() }
          })
        }
        .width('100%')
        .onClick((): void => { this.onApply() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }
}
