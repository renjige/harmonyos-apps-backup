import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { KnowledgeItem } from '../models/KnowledgeModels'
import { KnowledgeStore } from '../services/KnowledgeStore'
import { KnowledgeNav } from '../services/KnowledgeNav'
import { KnowledgeMedia } from '../services/KnowledgeMedia'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State queue: KnowledgeItem[] = []
  @State index: number = 0
  @State finished: boolean = false
  @State doneCount: number = 0
  @State sessionTotal: number = 0

  aboutToAppear(): void {
    this.resetQueue()
  }

  onRefreshTokenChange(): void {
    if (!this.finished) {
      this.queue = KnowledgeStore.reviewQueue()
    }
  }

  private resetQueue(): void {
    this.queue = KnowledgeStore.reviewQueue()
    this.index = 0
    this.finished = this.queue.length === 0
    this.doneCount = 0
    this.sessionTotal = this.queue.length
  }

  private current(): KnowledgeItem {
    if (this.index >= 0 && this.index < this.queue.length) {
      return this.queue[this.index]
    }
    return new KnowledgeItem()
  }

  private next(): void {
    if (this.index + 1 >= this.queue.length) {
      this.finished = true
      return
    }
    this.index += 1
  }

  private async remember(): Promise<void> {
    const item = this.current()
    if (item.id.length === 0) {
      return
    }
    await KnowledgeStore.remember(item.id)
    this.doneCount += 1
    this.next()
  }

  private later(): void {
    this.next()
  }

  build() {
    Column() {
      Text('今日复习')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      if (this.finished) {
        this.DonePane()
      } else if (this.queue.length === 0) {
        AppEmpty({
          title: '今天的轻知已经看完了。',
          description: '在详情里点「加入复习」，明天再来。'
        })
      } else {
        Text(`今天还有 ${this.queue.length - this.index} 条值得再看`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(KnowledgeMedia.resource(this.current().coverKey))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(180)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(18,42,54,0)', 0.3], ['rgba(18,42,54,0.7)', 1]]
                })
              Text(this.current().category)
                .fontSize(Theme.type.caption)
                .fontColor('#F6F1EA')
                .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .onClick((): void => { KnowledgeNav.openDetail(this.current().id) })

            Text(this.current().title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.current().body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(26)
              .width('100%')

            AppButton({
              label: '记住了',
              variant: 'primary',
              onTap: (): void => { void this.remember() }
            })
            AppButton({
              label: '稍后再看',
              variant: 'secondary',
              onTap: (): void => { this.later() }
            })
            AppButton({
              label: '下一条',
              variant: 'ghost',
              onTap: (): void => { this.next() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  DonePane() {
    Column({ space: Theme.space.s5 }) {
      Image($r('app.media.hero_review'))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.card)
      Text(`今天完成了 ${this.sessionTotal} 条轻知复习`)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('再看一遍，知识会留下得更久。')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Column({ space: 4 }) {
          Text(`${KnowledgeStore.streakDays()}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('连续复习天数')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        Column({ space: 4 }) {
          Text(`${KnowledgeStore.reviewCount()}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('累计复习数量')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .padding(Theme.space.pageX)
  }
}
