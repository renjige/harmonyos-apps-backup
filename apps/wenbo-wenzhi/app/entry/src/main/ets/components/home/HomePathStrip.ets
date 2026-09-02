import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { LearningPath } from '../../models/PathModels'
import { AskMedia } from '../../services/AskMedia'
import { AskNav } from '../../services/AskNav'
import { PathStore } from '../../services/PathStore'

@Component
export struct HomePathStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State paths: LearningPath[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await PathStore.ensureReady()
    const all = PathStore.all()
    const pick: LearningPath[] = []
    for (let i = 0; i < all.length && i < 2; i++) {
      pick.push(all[i])
    }
    this.paths = pick
  }

  build() {
    if (this.paths.length === 0) {
      Column()
    } else {
      Column({ space: Theme.space.s3 }) {
        Row() {
          Text('推荐学习路径')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          Blank()
          Text('全部')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
            .onClick((): void => { AskNav.switchTab(1) })
        }
        .width('100%')
        ForEach(this.paths, (path: LearningPath) => {
          Row({ space: Theme.space.s3 }) {
            Image(AskMedia.resource(path.coverKey))
              .width(64)
              .height(64)
              .borderRadius(Theme.radius.sm)
              .objectFit(ImageFit.Cover)
            Column({ space: 4 }) {
              Text(path.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .maxLines(1)
              Text(`${path.doneCount()}/${path.totalCount()} 节已完成`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.card)
          .onClick((): void => { AskNav.openPath(path.id) })
        }, (path: LearningPath) => path.id)
      }
      .width('100%')
    }
  }
}
