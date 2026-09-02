import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { TryItem } from '../models/DrinkModels'
import { DrinkBizService } from '../services/DrinkBizService'
import { DrinkDetailNav } from '../services/DrinkDetailNav'
import { DrinkMedia } from '../services/DrinkMedia'

@Component
export struct TriesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: TryItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await DrinkBizService.loadTries()
    this.loading = false
  }

  private async remove(id: string): Promise<void> {
    const ok = await DrinkBizService.deleteTry(id)
    if (ok) {
      await this.reload()
    }
  }

  build() {
    DetailShell({
      title: '试做记录',
      contentKey: `${this.items.length}`,
      onClose: () => DrinkDetailNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        if (this.loading) {
          AppLoading({ label: '正在打开试做' })
        } else if (this.items.length === 0) {
          AppEmpty({ title: '还没有试做', description: '新用户这里是空的。做完一杯可在详情记下。' })
        } else {
          ForEach(this.items, (t: TryItem) => {
            Column({ space: 8 }) {
              Row({ space: Theme.space.s3 }) {
                Image(DrinkMedia.resource(t.coverKey))
                  .width(64)
                  .height(64)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
                Column({ space: 4 }) {
                  Text(t.title)
                    .fontSize(Theme.type.subtitleS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(t.tryDate)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              AppButton({
                label: '删除这条',
                variant: 'ghost',
                onTap: (): void => { void this.remove(t.id) }
              })
            }
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .width('100%')
            .onClick(() => {
              if (t.drinkId.length > 0) {
                DrinkDetailNav.openDrink(t.drinkId)
              }
            })
          }, (t: TryItem) => t.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
