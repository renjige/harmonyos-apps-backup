import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { CatalogItem } from '../../models/SlipModels'
import { SlipBizService } from '../../services/SlipBizService'
import { SlipMedia } from '../../services/SlipMedia'
import { SlipNav } from '../../services/SlipNav'

@Component
export struct CatalogDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'cat'
  @Prop itemId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined

  aboutToAppear(): void {
    void this.loadItem()
  }

  onToken(): void {
    void this.loadItem()
  }

  private async loadItem(): Promise<void> {
    if (this.kind === 'scene') {
      this.item = await SlipBizService.findScene(this.itemId)
      return
    }
    this.item = await SlipBizService.findCategory(this.itemId)
  }

  private writeFromHere(): void {
    if (this.item === undefined) {
      return
    }
    const cat = this.item.category.length > 0 ? this.item.category : this.item.title
    SlipNav.hintCategory(cat)
    SlipNav.closeDetail()
    SlipNav.openWrite('')
  }

  build() {
    if (this.item === undefined) {
      Column() {
        AppEmpty({ title: '这条说明暂时看不到', description: '稍后再打开，或先记下今天的一件小事。' })
        AppButton({ label: '返回', variant: 'secondary', onTap: (): void => { SlipNav.closeDetail() } })
      }
      .width('100%')
      .height('100%')
      .padding(Theme.space.pageX)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else {
      DetailShell({ title: this.item.title, onClose: (): void => { SlipNav.closeDetail() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(SlipMedia.cover(this.item.coverKey))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(220)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(36,49,47,0)', 0.35], ['rgba(36,49,47,0.72)', 1]]
                })
              Column({ space: 6 }) {
                Text(this.kind === 'scene' ? '生活场景' : '备笺分类')
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                Text(this.item.title)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .width('100%')
              }
              .width('100%')
              .padding({ left: 20, right: 20, bottom: 18 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)

            AppCard() {
              Column({ space: 8 }) {
                Text(this.item.summary.length > 0 ? this.item.summary : this.item.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
            }

            Text(this.item.body.length > 0 ? this.item.body : '把这一类生活小事轻轻记下即可。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)

            AppButton({
              label: '按这个分类记一件事',
              onTap: (): void => { this.writeFromHere() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
  }
}
