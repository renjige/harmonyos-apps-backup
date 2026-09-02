import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { AtelierTrails, ReadingTrail } from '../../services/AtelierTrails'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'
import { AtelierProgress } from '../../services/AtelierProgress'
import { AtelierMedia } from '../../services/AtelierMedia'
import { AtelierBizService } from '../../services/AtelierBizService'

class TrailStepRow {
  cardId: string = ''
  title: string = ''
  done: boolean = false
  stepNo: number = 1
}

@Component
export struct TrailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop trailId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State trail: ReadingTrail = new ReadingTrail()
  @State steps: TrailStepRow[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = AtelierTrails.find(this.trailId)
    if (found === undefined) {
      this.loaded = false
      return
    }
    this.trail = found
    const rows: TrailStepRow[] = []
    let step = 1
    for (const id of found.cardIds) {
      const card = await AtelierBizService.findCard(id)
      const row = new TrailStepRow()
      row.cardId = id
      row.title = card !== undefined ? card.title : '知识卡'
      row.done = AtelierProgress.isCardRead(id)
      row.stepNo = step
      step = step + 1
      rows.push(row)
    }
    this.steps = rows
    this.loaded = true
  }

  private doneCount(): number {
    return AtelierProgress.trailDoneCount(this.trail.cardIds)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '专题路线',
        showFavorite: false,
        onClose: (): void => { AtelierDetailNav.close() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '路线暂时找不到', description: '请返回发现页刷新后再试。' })
        } else {
          this.BodyBlock()
        }
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BodyBlock() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(AtelierMedia.resource(this.trail.coverKey))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,42,108,0)', 0.2], ['rgba(26,42,108,0.82)', 1]]
            })
          Column({ space: 4 }) {
            Text(this.trail.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F8F9FA')
            Text(`${this.trail.subtitle} · 进度 ${this.doneCount()}/${this.trail.stepCount()}`)
              .fontSize(Theme.type.caption)
              .fontColor('#F8F9FA')
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
        }
        .width('100%')
        .borderRadius(Theme.radius.card)
        .clip(true)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text('按顺序读完三篇，再在工坊台做一页对应练习。进度保存在本机。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        ForEach(this.steps, (row: TrailStepRow) => {
          Row({ space: 12 }) {
            Text(row.done ? '已' : `${row.stepNo}`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(row.done ? Theme.colorOf(this.themeEpoch).brandPrimary :
                Theme.colorOf(this.themeEpoch).textSecondary)
              .width(28)
              .textAlign(TextAlign.Center)
            Column({ space: 2 }) {
              Text(row.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .maxLines(2)
                .width('100%')
              Text(row.done ? '已读' : '点此阅读')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(12)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { AtelierDetailNav.openCard(row.cardId) })
        }, (row: TrailStepRow) => row.cardId)

        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: `做一页${AtelierTrails.practiceLabel(this.trail.practiceKind)}`,
            onTap: (): void => {
              AtelierDetailNav.openWorkNew(this.trail.practiceKind, this.trail.cardIds[0])
            }
          })
          AppButton({
            label: '返回发现页继续浏览',
            variant: 'secondary',
            onTap: (): void => {
              AtelierDetailNav.close()
              AtelierDetailNav.switchTab(0)
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
