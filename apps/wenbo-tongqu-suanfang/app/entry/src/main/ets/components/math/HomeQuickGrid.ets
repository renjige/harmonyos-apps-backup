import { Theme } from '../design-system/Theme'
import { MathMedia } from '../../services/MathMedia'

@Component
export struct HomeQuickGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop favCount: number = 0
  onWarm: () => void = () => {}
  onStory: () => void = () => {}
  onTable: () => void = () => {}
  onFav: () => void = () => {}
  onGame: () => void = () => {}
  onReview: () => void = () => {}
  onQuick: (mode: string) => void = (_m: string) => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        this.mini('热身 5 题', '先活动一下', () => this.onWarm())
        this.mini('应用题', '读一读再算', () => this.onStory())
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.mini('九九口诀表', '点一行专练', () => this.onTable())
        this.mini('我的收藏', this.favCount > 0 ? `${this.favCount} 题可复习` : '答题时收藏本题', () => this.onFav())
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.mini('趣味数学', '排序 · 图形 · 连线', () => this.onGame())
        this.mini('学习回顾', '今日 / 本周 / 本月', () => this.onReview())
      }
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        Text('快速练习')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s3 }) {
          this.quick('加法', 'add', 'cover_add')
          this.quick('减法', 'sub', 'cover_sub')
        }
        .width('100%')
        Row({ space: Theme.space.s3 }) {
          this.quick('比大小', 'compare', 'cover_mix')
          this.quick('找规律', 'sequence', 'hero_paper')
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  mini(title: string, hint: string, tap: () => void) {
    Column({ space: Theme.space.s1 }) {
      Text(title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(tap)
  }

  @Builder
  quick(label: string, mode: string, cover: string) {
    Column({ space: Theme.space.s2 }) {
      Image(MathMedia.resource(cover))
        .width('100%')
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Text(label)
        .fontSize(Theme.type.footnote)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .onClick(() => this.onQuick(mode))
  }
}
