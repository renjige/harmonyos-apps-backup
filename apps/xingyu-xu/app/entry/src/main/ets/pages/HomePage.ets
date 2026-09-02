import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ArchiveStats, Narrative } from '../models/XingyuModels'
import { XingyuStore } from '../services/XingyuStore'
import { XingyuStats } from '../services/XingyuStats'
import { XingyuNav } from '../services/XingyuNav'
import { DateHelper } from '../services/DateHelper'
import { NarrativeCard } from '../components/xingyu/ArchiveCards'

@Component
export struct HomePage {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '星隅叙'
  @State stats: ArchiveStats = new ArchiveStats()
  @State recent: Narrative[] = []
  @State recall: Narrative = new Narrative()

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await XingyuStats.snapshot()
    const all = await XingyuStore.loadNarratives()
    const top: Narrative[] = []
    for (let i = 0; i < all.length && i < 3; i++) {
      top.push(all[i])
    }
    this.recent = top
    const rec = await XingyuStats.recallToday()
    if (rec !== undefined) {
      this.recall = rec
    } else {
      this.recall = new Narrative()
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_bg'))
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(18,24,43,0.05)', 0], ['rgba(18,24,43,0.86)', 1]]
            })
          Column({ space: 8 }) {
            Text(this.appName)
              .fontSize(Theme.type.caption)
              .fontColor('#C4A574')
            Text('今天值得留下什么？')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F6F3EC')
            Text('在生活的角落，收藏属于自己的星光时刻')
              .fontSize(Theme.type.footnote)
              .fontColor('#D4CFC4')
          }
          .padding(Theme.space.s5)
          .width('100%')
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.lg)

        Row({ space: Theme.space.s3 }) {
          Column({ space: 4 }) {
            Text(`${this.stats.narrativeCount}`)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('记录')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(2)
          Column({ space: 4 }) {
            Text(`${this.stats.favoriteCount}`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text('收藏')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          Column({ space: 4 }) {
            Text(`${this.stats.themeCount}`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text('主题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)

        Row({ space: Theme.space.s3 }) {
          Column({ space: 6 }) {
            AppIcon({ name: 'edit', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
            Text('新建叙事')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandOnPrimary)
          }
          .layoutWeight(1)
          .height(88)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.md)
          .onClick(() => XingyuNav.openEditor('narrative', ''))
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              AppIcon({ name: 'sparkle', iconSize: Theme.icon.md, color: Theme.colors().brandAccent })
              Text('收藏灵感')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onClick(() => XingyuNav.openEditor('spark', ''))
            Row({ space: 8 }) {
              AppIcon({ name: 'book', iconSize: Theme.icon.md, color: Theme.colors().brandAccent })
              Text('创建主题')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onClick(() => XingyuNav.openEditor('theme', ''))
          }
          .layoutWeight(1)
        }
        .width('100%')

        Row() {
          Text('查看回望')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick(() => XingyuNav.switchTab(3))

        Text(`连续记录 ${this.stats.streakDays} 天`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.banner_01'))
            .width('100%')
            .height(112)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(80)
            .linearGradient({
              angle: 180,
              colors: [['rgba(18,24,43,0)', 0], ['rgba(18,24,43,0.72)', 1]]
            })
          Column({ space: 4 }) {
            Text('阅读角 · 把书页收进主题')
              .fontSize(Theme.type.caption)
              .fontColor('#C4A574')
            Text('一段摘录、一次重读，都可以成为星隅里的档案。')
              .fontSize(Theme.type.footnote)
              .fontColor('#F6F3EC')
          }
          .padding(Theme.space.s4)
          .width('100%')
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.md)
        .onClick(() => XingyuNav.switchTab(2))

        Text('最近片段')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.recent.length === 0) {
          AppEmpty({
            title: '档案还是空的',
            description: '留下今天值得保存的一段叙事。',
            actionLabel: '留下此刻',
            onAction: () => XingyuNav.openEditor('narrative', '')
          })
        }
        ForEach(this.recent, (n: Narrative) => {
          NarrativeCard({
            title: n.title,
            dateKey: n.dateKey,
            statusLabel: n.statusLabel(),
            preview: n.preview(),
            coverKey: n.coverKey(),
            onOpen: () => XingyuNav.openNarrative(n.id)
          })
        }, (n: Narrative) => n.id)

        Text('今日回望')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.recall.id.length > 0) {
          Column({ space: 8 }) {
            Image($r('app.media.banner_02'))
              .width('100%')
              .height(96)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.sm)
            Text('往日的星光还在')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
              .width('100%')
            Text(this.recall.title)
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`${DateHelper.displayDate(this.recall.dateKey)} · ${this.recall.preview()}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(2)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick(() => XingyuNav.openNarrative(this.recall.id))
        } else {
          Text('再过些日子，这里会翻出往日的片段。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor(Theme.colors().surfacePage)
  }
}
