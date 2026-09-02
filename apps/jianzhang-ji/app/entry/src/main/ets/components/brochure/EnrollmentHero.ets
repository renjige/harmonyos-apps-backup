import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

/** 首页 Hero 统计块 — Symbol + 玻璃质感 */
@Component
struct HeroStatPill {
  @Prop iconName: AppIconName = 'book'
  @Prop value: string = '0'
  @Prop label: string = ''

  build() {
    Column({ space: 4 }) {
      Column() {
        AppIcon({ name: this.iconName, iconSize: Theme.icon.md, color: '#FFFFFF' })
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(255,255,255,0.22)')
      .borderRadius(Theme.radius.pill)
      Text(this.value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      Text(this.label)
        .fontSize(Theme.type.overline)
        .fontColor('#E8F4FF')
    }
    .layoutWeight(1)
    .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })
    .backgroundColor('rgba(255,255,255,0.14)')
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: 'rgba(255,255,255,0.20)' })
    .alignItems(HorizontalAlign.Center)
  }
}

/** 首页品牌 Hero — 鸿蒙 Symbol 装饰 + 渐变，不依赖外部摄影图 */
@Component
export struct EnrollmentHero {
  @Prop appName: string = '简章集'
  @Prop tagline: string = ''
  @Prop brochureCount: number = 0
  @Prop articleCount: number = 0

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(200)
        .linearGradient({
          angle: 145,
          colors: [[0xFF007AFF, 0.0], [0xFF0051A8, 0.52], [0xFF0A2540, 1.0]]
        })
        .borderRadius(Theme.radius.xl)

      Column() {
        SymbolGlyph($r('sys.symbol.doc_text'))
          .fontSize(96)
          .fontColor(['rgba(255,255,255,0.10)'])
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
      }
      .width('100%')
      .height(200)
      .alignItems(HorizontalAlign.End)
      .padding({ top: 8, right: 12 })

      Column() {
        SymbolGlyph($r('sys.symbol.book'))
          .fontSize(56)
          .fontColor(['rgba(255,255,255,0.08)'])
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
      }
      .width('100%')
      .height(200)
      .alignItems(HorizontalAlign.End)
      .padding({ top: 72, right: 64 })

      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            SymbolGlyph($r('sys.symbol.doc_text'))
              .fontSize(Theme.icon.lg)
              .fontColor(['#FFFFFF'])
              .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(255,255,255,0.20)')
          .borderRadius(Theme.radius.pill)
          Column({ space: 2 }) {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(this.tagline.length > 0 ? this.tagline : '高校招生简章智慧检索与对比')
              .fontSize(Theme.type.footnote)
              .fontColor('#E8F4FF')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Row({ space: Theme.space.s2 }) {
          HeroStatPill({
            iconName: 'biz',
            value: `${this.brochureCount}`,
            label: '院校简章'
          })
          HeroStatPill({
            iconName: 'book',
            value: `${this.articleCount}`,
            label: '政策资讯'
          })
          HeroStatPill({
            iconName: 'chart',
            value: '2–4',
            label: '所可对比'
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s4
      })
    }
    .width('100%')
    .clip(true)
    .borderRadius(Theme.radius.xl)
    .shadow({
      radius: 20,
      color: 'rgba(0,81,168,0.22)',
      offsetX: 0,
      offsetY: 8
    })
  }
}
