import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { EssayItem } from '../../models/InkModels'
import { InkBizService } from '../../services/InkBizService'
import { InkDetailNav } from '../../services/InkDetailNav'
import { InkMedia } from '../../services/InkMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct EssayDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: EssayItem = new EssayItem()
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await InkBizService.findEssay(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  build() {
    DetailShell({
      title: '精选笺',
      onClose: (): void => { InkDetailNav.close() }
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '笺文不存在', description: '请返回后刷新。' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(InkMedia.resource(this.item.coverKey))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0)', 0.22], ['rgba(26,26,46,0.82)', 1]]
                })
              Column({ space: 6 }) {
                Text(this.item.authorName)
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8D5A3')
                Text(this.item.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F4EFE4')
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column() {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(24)
                .width('100%')
            }
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(26)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: '写一条书评',
                variant: 'primary',
                onTap: (): void => {
                  if (!AuthService.requireAuth('create_review')) {
                    this.onRequireAuth()
                    return
                  }
                  InkDetailNav.openEditor('review', '')
                }
              })
              if (this.item.excerptId.length > 0) {
                AppButton({
                  label: '去读相关书摘',
                  variant: 'secondary',
                  onTap: (): void => { InkDetailNav.openExcerpt(this.item.excerptId) }
                })
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
  }
}
