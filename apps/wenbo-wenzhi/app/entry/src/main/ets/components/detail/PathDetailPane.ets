import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { LearningPath, PathStep } from '../../models/PathModels'
import { AskMedia } from '../../services/AskMedia'
import { AskNav } from '../../services/AskNav'
import { PathStore } from '../../services/PathStore'

@Component
export struct PathDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop pathId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State path: LearningPath = new LearningPath()
  @State loaded: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    await PathStore.ensureReady()
    const found = PathStore.find(this.pathId)
    if (found === undefined) {
      this.loaded = false
      return
    }
    this.path = found
    this.loaded = true
  }

  private async markStep(step: PathStep): Promise<void> {
    await PathStore.markStepDone(this.pathId, step.id, step.title)
    await this.reload()
    AskNav.bumpRefresh()
    this.showToast('本节已标记完成')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '学习路径',
        showFavorite: false,
        favorited: false,
        onClose: (): void => { AskNav.closeDetail() },
        onFavorite: (): void => {}
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '路径加载中', description: '请返回后重试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(AskMedia.resource(this.path.coverKey))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(100)
                  .linearGradient({
                    direction: GradientDirection.Bottom,
                    colors: [['rgba(11,31,58,0)', 0], ['rgba(11,31,58,0.78)', 1]]
                  })
                Column({ space: 4 }) {
                  Text(this.path.title)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                  Text(`${this.path.doneCount()} / ${this.path.totalCount()} 节 · ${this.path.progressPercent()}%`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#E8EDF5')
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)

              Text(this.path.subtitle)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')

              Progress({
                value: this.path.doneCount(),
                total: this.path.totalCount() > 0 ? this.path.totalCount() : 1,
                type: ProgressType.Linear
              })
                .width('100%')
                .color(Theme.colors().brandPrimary)

              Text('路径章节')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .width('100%')

              ForEach(this.path.steps, (step: PathStep) => {
                Column({ space: Theme.space.s2 }) {
                  Row() {
                    Text(`第 ${step.order + 1} 节`)
                      .fontSize(Theme.type.caption)
                      .fontColor(step.done ? Theme.colors().brandPrimary : Theme.colorOf(this.themeEpoch).textSecondary)
                    Blank()
                    Text(step.done ? '已完成 ✓' : '待学习')
                      .fontSize(Theme.type.caption)
                      .fontColor(step.done ? Theme.colors().brandPrimary : Theme.colorOf(this.themeEpoch).textTertiary)
                  }
                  .width('100%')
                  Text(step.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                    .width('100%')
                  Text(step.summary)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                    .width('100%')
                    .maxLines(2)
                  Row({ space: Theme.space.s2 }) {
                    AppButton({
                      label: '阅读解答',
                      variant: 'secondary',
                      onTap: (): void => { AskNav.openDetail('insight', step.insightId) }
                    })
                      .layoutWeight(1)
                    if (!step.done) {
                      AppButton({
                        label: '标记完成',
                        onTap: (): void => { void this.markStep(step) }
                      })
                        .layoutWeight(1)
                    }
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
                .borderRadius(Theme.radius.card)
                .clip(true)
              }, (step: PathStep) => step.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }
}
