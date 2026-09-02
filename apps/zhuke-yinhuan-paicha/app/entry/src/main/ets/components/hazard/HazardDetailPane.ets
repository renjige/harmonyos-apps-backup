import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { HazardItem } from '../../models/HazardModels'
import { HazardMedia } from '../../services/HazardMedia'

@Component
export struct HazardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: HazardItem = new HazardItem()
  onRectify: () => void = () => {}
  onReview: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(HazardMedia.cover(this.item.coverKey))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['#00000000', 0], ['#CC16324F', 1]]
            })
          Column({ space: 6 }) {
            Row({ space: 8 }) {
              Text(this.item.riskLabel())
                .fontSize(12)
                .fontColor('#FFFFFF')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(this.item.riskColor())
                .borderRadius(8)
              Text(this.item.statusLabel())
                .fontSize(12)
                .fontColor('#FFFFFF')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(this.item.statusColor())
                .borderRadius(8)
            }
            Text(this.item.title)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(this.item.location.length > 0 ? this.item.location : '位置待补充')
              .fontSize(13)
              .fontColor('#FFFFFF')
              .width('100%')
          }
          .padding({ left: 16, right: 16, bottom: 16 })
          .width('100%')
        }
        .width('100%')
        .height(200)
        .clip(true)

        Column({ space: 8 }) {
          this.Meta('类别', this.item.category)
          this.Meta('发现时间', this.item.foundLabel())
          this.Meta('责任人', this.item.ownerName.length > 0 ? this.item.ownerName : '待指定')
          this.Meta('整改期限', this.item.dueLabel())
        }
        .padding(16)
        .width('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        AppCard({ title: '问题描述' }) {
          Text(this.item.description.length > 0 ? this.item.description : '未填写描述')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }

        if (this.item.suggestion.length > 0) {
          AppCard({ title: '整改建议' }) {
            Text(this.item.suggestion)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }

        Column({ space: 10 }) {
          Text('状态时间线')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          this.Step('发现隐患', this.item.foundLabel(), true)
          this.Step('提交整改', this.item.rectifyAt.length > 0 ? HazardItem.shortTime(this.item.rectifyAt) : '待更新',
            this.item.rectifyAt.length > 0)
          this.Step('复查结果', this.item.reviewAt.length > 0 ? HazardItem.shortTime(this.item.reviewAt) : '待更新',
            this.item.reviewAt.length > 0)
          this.Step('已闭环', this.item.status === 'closed' ? '隐患已完成闭环' : '待更新',
            this.item.status === 'closed')
        }
        .padding(16)
        .width('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
        .alignItems(HorizontalAlign.Start)

        if (this.item.status === 'closed') {
          Text('✓ 隐患已完成闭环')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2D9B70')
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding(14)
            .backgroundColor('#E8F7F0')
            .borderRadius(14)
        } else if (this.item.status === 'pending_review') {
          AppButton({ label: '进行复查', onTap: (): void => { this.onReview() } })
        } else {
          AppButton({ label: '记录整改', onTap: (): void => { this.onRectify() } })
        }
      }
      .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  @Builder
  Meta(label: string, value: string) {
    Row() {
      Text(label).fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value).fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).layoutWeight(1).textAlign(TextAlign.End)
    }.width('100%')
  }

  @Builder
  Step(title: string, time: string, done: boolean) {
    Row({ space: 10 }) {
      Column()
        .width(10)
        .height(10)
        .borderRadius(5)
        .backgroundColor(done ? Theme.colors().brandAccent : Theme.colors().strokeStrong)
      Column({ space: 2 }) {
        Text(title).fontSize(14).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(time).fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }
}
