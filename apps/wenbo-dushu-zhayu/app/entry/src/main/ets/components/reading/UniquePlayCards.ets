import { Theme } from '../design-system/Theme'
import { ReadingMedia } from '../../services/ReadingMedia'

/** 首页三种独有玩法 — 审核首屏即可见，非摘抄列表 */
@Component
export struct UniquePlayCards {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onOpenLamp: () => void = () => {}
  onOpenDialogue: () => void = () => {}
  onOpenBookAsk: () => void = () => {}
  onOpenStudioPlay: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('三种独有阅读方式')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('说明')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.linkForeground())
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .onClick((): void => { this.onOpenStudioPlay() })
      }
      .width('100%')

      Text('同类 App 多为「记一句、打一个卡」。本 App 必须完成思考动作才能记入书房。')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .lineHeight(20)

      this.PlayCard(
        '① 灯下共读',
        '计时结束须写「今日一句」',
        'lamp_session',
        (): void => { this.onOpenLamp() }
      )
      this.PlayCard(
        '② 对读札',
        '选两句金句写对照思考',
        'dialogue_pair',
        (): void => { this.onOpenDialogue() }
      )
      this.PlayCard(
        '③ 问书三札',
        '三问结构化反思，缺一不可',
        'hero_dialogue_books',
        (): void => { this.onOpenBookAsk() }
      )
    }
    .width('100%')
  }

  @Builder
  PlayCard(title: string, subtitle: string, coverKey: string, onTap: () => void) {
    Row({ space: 12 }) {
      Image(ReadingMedia.coverMedia(coverKey))
        .width(72)
        .height(72)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { onTap() })
  }
}
