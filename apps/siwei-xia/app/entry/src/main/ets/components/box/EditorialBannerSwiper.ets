import { Theme } from '../design-system/Theme'
import { BoxMedia } from '../../services/BoxMedia'

class BannerSlide {
  key: string = ''
  imageKey: string = ''
  title: string = ''
  caption: string = ''
}

@Component
export struct EditorialBannerSwiper {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onThink: () => void = () => {}
  onMap: () => void = () => {}
  @State index: number = 0

  private slides(): BannerSlide[] {
    const list: BannerSlide[] = []
    const a = new BannerSlide()
    a.key = 'think'
    a.imageKey = 'banner_capture'
    a.title = '推进到思考工坊'
    a.caption = '拆解问题、写下笔记、留下观点'
    list.push(a)
    const b = new BannerSlide()
    b.key = 'mindmap'
    b.imageKey = 'banner_mindmap'
    b.title = '在导图里看见关联'
    b.caption = '按标签展开，碎片想法连成结构'
    list.push(b)
    return list
  }

  private openSlide(slide: BannerSlide): void {
    if (slide.key === 'mindmap') {
      this.onMap()
      return
    }
    this.onThink()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Swiper() {
        ForEach(this.slides(), (s: BannerSlide) => {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(BoxMedia.resource(s.imageKey))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [
                  ['rgba(15,23,42,0.06)', 0.0],
                  ['rgba(15,23,42,0.42)', 0.45],
                  ['rgba(15,23,42,0.88)', 1.0]
                ]
              })
            Column({ space: 4 }) {
              Text(s.title)
                .fontSize(Theme.type.titleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textOnInverse)
              Text(s.caption)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
            .width('100%')
            .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
          }
          .width('100%')
          .height(180)
          .borderRadius(Theme.radius.xl)
          .clip(true)
          .onClick((): void => { this.openSlide(s) })
        }, (s: BannerSlide) => s.key)
      }
      .width('100%')
      .height(180)
      .itemSpace(12)
      .indicator(false)
      .onChange((i: number) => { this.index = i })
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
