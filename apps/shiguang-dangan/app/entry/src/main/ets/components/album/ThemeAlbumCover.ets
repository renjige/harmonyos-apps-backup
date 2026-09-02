import { Theme } from '../design-system/Theme'
import { ThemeAlbum } from '../../models/LifeModels'

export class AlbumToneColors {
  start: string = ''
  end: string = ''

  static forTone(tone: string): AlbumToneColors {
    const c = new AlbumToneColors()
    if (tone === 'cool') {
      c.start = '#5B8DEF'
      c.end = '#3D5A80'
    } else if (tone === 'earth') {
      c.start = '#C4A574'
      c.end = '#8B6914'
    } else if (tone === 'violet') {
      c.start = '#9B7EDE'
      c.end = '#6B4E9B'
    } else if (tone === 'dawn') {
      c.start = '#F4A261'
      c.end = '#E76F51'
    } else {
      c.start = '#E8B86D'
      c.end = '#C17817'
    }
    return c
  }
}

@Component
export struct ThemeAlbumCover {
  @Prop album: ThemeAlbum = new ThemeAlbum()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  private toneColors(): AlbumToneColors {
    return AlbumToneColors.forTone(this.album.coverTone)
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height(this.compact ? 100 : 140)
        .linearGradient({
          angle: 135,
          colors: [[this.toneColors().start, 0], [this.toneColors().end, 1]]
        })
        .borderRadius(Theme.radius.lg)
      Column()
        .width('100%')
        .height(this.compact ? 100 : 140)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(24,35,51,0.55)', 1]]
        })
        .borderRadius(Theme.radius.lg)
      Column({ space: 4 }) {
        Text(this.album.title)
          .fontSize(this.compact ? Theme.type.subhead : Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .maxLines(2)
        if (this.album.summary.length > 0) {
          Text(this.album.summary)
            .fontSize(Theme.type.caption)
            .fontColor('#F7F6F2')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        Text(`${this.album.refList().length} 条关联`)
          .fontSize(Theme.type.overline)
          .fontColor('#E8E4DC')
      }
      .padding(Theme.space.s4)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .onClick((): void => { this.onTap() })
  }
}
