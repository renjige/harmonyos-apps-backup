import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { BookListItem } from '../models/InkModels'
import { InkBizService } from '../services/InkBizService'
import { InkDetailNav } from '../services/InkDetailNav'
import { InkMedia } from '../services/InkMedia'

@Component
export struct StudyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State lists: BookListItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.lists = await InkBizService.loadLists()
    this.loading = false
  }

  build() {
    Column() {
      Text('智慧书房')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s3
        })

      if (this.loading) {
        AppEmpty({ title: '正在整理书单…', description: '' })
      } else if (this.lists.length === 0) {
        AppEmpty({
          title: '暂无书单',
          description: '请检查网络后重试。',
          actionLabel: '重试',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.banner_study'))
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(140)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0)', 0.2], ['rgba(26,26,46,0.78)', 1]]
                })
              Column({ space: 4 }) {
                Text('按气质匹配长读书单')
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8D5A3')
                Text('先做一份匹配问卷，再打开对应书单。')
                  .fontSize(Theme.type.footnote)
                  .fontColor('#F4EFE4')
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s3 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)

            AppButton({
              label: '开始书房匹配',
              variant: 'primary',
              onTap: (): void => { InkDetailNav.openMatch() }
            })

            ForEach(this.lists, (item: BookListItem) => {
              Row({ space: Theme.space.s3 }) {
                Image(InkMedia.resource(item.coverKey))
                  .width(88)
                  .height(88)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
                Column({ space: 6 }) {
                  Text(item.title)
                    .fontSize(Theme.type.subtitleM)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(item.summary)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                  Text(item.theme)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandAccent)
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick((): void => { InkDetailNav.openList(item.id) })
            }, (item: BookListItem) => item.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
