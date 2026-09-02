import { Theme } from '../design-system/Theme'
import { TopicCollection } from '../../models/InfoModels'
import { WanXiangMedia } from '../../services/WanXiangMedia'

@Component
export struct TopicStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop topics: TopicCollection[] = []
  onTapTopic: (topicId: string) => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('专题合辑')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text(`${this.topics.length} 个专题`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.topics, (topic: TopicCollection) => {
            Column() {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(WanXiangMedia.coverResource(topic.coverKey))
                  .width(200)
                  .height(112)
                  .objectFit(ImageFit.Cover)
                  .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })

                Column()
                  .width(200)
                  .height(112)
                  .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(0,0,0,0)', 0.2], ['rgba(0,0,0,0.82)', 1]]
                  })

                Text(`${topic.emoji} ${topic.title}`)
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .maxLines(2)
                  .padding(10)
              }

              Text(topic.description)
                .fontSize(10)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .maxLines(2)
                .lineHeight(16)
                .width(200)
                .padding({ left: 10, right: 10, top: 8, bottom: 10 })
            }
            .width(200)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .clip(true)
            .onClick((): void => this.onTapTopic(topic.id))
          }, (topic: TopicCollection) => topic.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(168)
    }
    .width('100%')
  }
}
