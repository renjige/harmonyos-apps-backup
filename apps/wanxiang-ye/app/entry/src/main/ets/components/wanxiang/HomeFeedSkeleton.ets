import { Theme } from '../design-system/Theme'

@Component
struct SkeletonBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop blockWidth: string | number = '100%'
  @Prop blockHeight: number = 16
  @Prop radius: number = 8

  build() {
    Row()
      .width(this.blockWidth)
      .height(this.blockHeight)
      .borderRadius(this.radius)
      .backgroundColor(Theme.colors().surfaceSubtle)
      .opacity(0.55)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}

@Component
export struct HomeFeedSkeleton {
  build() {
    Column({ space: Theme.space.s4 }) {
      SkeletonBlock({ blockWidth: '100%', blockHeight: 196, radius: Theme.radius.lg })
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Row({ space: Theme.space.s2 }) {
        SkeletonBlock({ blockWidth: 72, blockHeight: 36, radius: Theme.radius.pill })
        SkeletonBlock({ blockWidth: 72, blockHeight: 36, radius: Theme.radius.pill })
        SkeletonBlock({ blockWidth: 72, blockHeight: 36, radius: Theme.radius.pill })
        SkeletonBlock({ blockWidth: 72, blockHeight: 36, radius: Theme.radius.pill })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: Theme.space.s3 }) {
        SkeletonBlock({ blockWidth: '100%', blockHeight: 168, radius: Theme.radius.lg })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Row({ space: 12 }) {
        SkeletonBlock({ blockWidth: 148, blockHeight: 168, radius: Theme.radius.md })
        SkeletonBlock({ blockWidth: 148, blockHeight: 168, radius: Theme.radius.md })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Grid() {
        ForEach([1, 2, 3, 4], (n: number) => {
          GridItem() {
            Column({ space: 8 }) {
              SkeletonBlock({ blockWidth: '100%', blockHeight: 140, radius: Theme.radius.sm })
              SkeletonBlock({ blockWidth: '80%', blockHeight: 14, radius: 6 })
              SkeletonBlock({ blockWidth: '60%', blockHeight: 12, radius: 6 })
            }
          }
        }, (n: number) => `${n}`)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
  }
}

@Component
export struct SearchResultSkeleton {
  build() {
    Column({ space: Theme.space.s3 }) {
      ForEach([1, 2, 3], (n: number) => {
        Row({ space: Theme.space.s3 }) {
          SkeletonBlock({ blockWidth: 88, blockHeight: 110, radius: Theme.radius.sm })
          Column({ space: 8 }) {
            SkeletonBlock({ blockWidth: 80, blockHeight: 12, radius: 6 })
            SkeletonBlock({ blockWidth: '100%', blockHeight: 16, radius: 6 })
            SkeletonBlock({ blockWidth: '90%', blockHeight: 14, radius: 6 })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }, (n: number) => `${n}`)
    }
    .width('100%')
  }
}
