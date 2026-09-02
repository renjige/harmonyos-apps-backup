import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { AppTextField } from '../design-system/AppTextField'
import { DetailShell } from './DetailShell'
import { ContentCard } from '../ContentCard'
import { CardItem } from '../../models/AtelierModels'
import { AtelierBizService } from '../../services/AtelierBizService'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'

@Component
export struct SearchPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State keyword: string = ''
  @State shown: CardItem[] = AtelierBizService.packCards()
  @State all: CardItem[] = AtelierBizService.packCards()

  aboutToAppear(): void {
    this.all = AtelierBizService.packCards()
    this.apply()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.all = await AtelierBizService.loadCards()
    this.apply()
  }

  private apply(): void {
    this.shown = AtelierBizService.search(this.all, this.keyword)
  }

  build() {
    DetailShell({
      title: '搜索知识卡',
      onClose: (): void => { AtelierDetailNav.close() }
    }) {
      Column({ space: Theme.space.s3 }) {
        Row({ space: 8 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
          AppTextField({
            text: this.keyword,
            placeholder: '标题或正文关键词',
            transparentBg: true,
            onChange: (v: string): void => {
              this.keyword = v
              this.apply()
            }
          })
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.shown.length === 0) {
          AppEmpty({ title: '没有匹配的知识卡', description: '换个词再试试。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.shown, (row: CardItem) => {
                ContentCard({
                  item: row,
                  onOpen: (): void => { AtelierDetailNav.openCard(row.id) }
                })
              }, (row: CardItem) => row.id)
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
      .width('100%')
      .layoutWeight(1)
    }
  }
}
