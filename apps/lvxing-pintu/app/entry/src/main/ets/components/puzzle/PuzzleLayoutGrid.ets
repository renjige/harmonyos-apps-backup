import { Theme } from '../design-system/Theme'
import { PuzzlePiece } from '../../models/PuzzleModels'

@Component
export struct PuzzleLayoutGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop layoutType: string = 'grid-4'
  @Prop pieces: PuzzlePiece[] = []
  @Prop compact: boolean = false

  private cellHeight(): number {
    if (this.compact) {
      return 72
    }
    return 110
  }

  @Builder
  cell(piece: PuzzlePiece, weight: number) {
    if (piece.imageUri.length > 0) {
      Image(piece.imageUri)
        .width('100%')
        .height(this.cellHeight())
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
        .layoutWeight(weight)
    } else {
      Column()
        .width('100%')
        .height(this.cellHeight())
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .layoutWeight(weight)
    }
  }

  build() {
    if (this.layoutType === 'classic-3' && this.pieces.length >= 3) {
      Column({ space: Theme.space.s1 }) {
        this.cell(this.pieces[0], 1)
        Row({ space: Theme.space.s1 }) {
          this.cell(this.pieces[1], 1)
          this.cell(this.pieces[2], 1)
        }
        .width('100%')
      }
      .width('100%')
    } else if (this.layoutType === 'grid-6' && this.pieces.length >= 6) {
      Column({ space: Theme.space.s1 }) {
        Row({ space: Theme.space.s1 }) {
          this.cell(this.pieces[0], 1)
          this.cell(this.pieces[1], 1)
          this.cell(this.pieces[2], 1)
        }
        Row({ space: Theme.space.s1 }) {
          this.cell(this.pieces[3], 1)
          this.cell(this.pieces[4], 1)
          this.cell(this.pieces[5], 1)
        }
      }
      .width('100%')
    } else if (this.layoutType === 'grid-9' && this.pieces.length >= 9) {
      Column({ space: Theme.space.s1 }) {
        Row({ space: Theme.space.s1 }) {
          this.cell(this.pieces[0], 1)
          this.cell(this.pieces[1], 1)
          this.cell(this.pieces[2], 1)
        }
        Row({ space: Theme.space.s1 }) {
          this.cell(this.pieces[3], 1)
          this.cell(this.pieces[4], 1)
          this.cell(this.pieces[5], 1)
        }
        Row({ space: Theme.space.s1 }) {
          this.cell(this.pieces[6], 1)
          this.cell(this.pieces[7], 1)
          this.cell(this.pieces[8], 1)
        }
      }
      .width('100%')
    } else {
      Column({ space: Theme.space.s1 }) {
        Row({ space: Theme.space.s1 }) {
          this.cell(this.pieces.length > 0 ? this.pieces[0] : new PuzzlePiece(), 1)
          this.cell(this.pieces.length > 1 ? this.pieces[1] : new PuzzlePiece(), 1)
        }
        Row({ space: Theme.space.s1 }) {
          this.cell(this.pieces.length > 2 ? this.pieces[2] : new PuzzlePiece(), 1)
          this.cell(this.pieces.length > 3 ? this.pieces[3] : new PuzzlePiece(), 1)
        }
      }
      .width('100%')
    }
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
